//
//  InMobiBannerAd.m
//  InMobiMopubAdvancedBiddingPlugin
//  InMobi
//
//  Created by Akshit Garg on 23/11/20.
//  Copyright © 2020 InMobi. All rights reserved.
//

#import "InMobiBannerAd.h"
#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
    #import <MoPubSDKFramework/MoPub.h>
#else
    #import "MPConstants.h"
    #import "MPLogging.h"
#endif

#import "IMMPABConstants.h"
#import "IMMPABUtilities.h"

@interface InMobiBannerAd ()

@property (nonatomic, strong) IMBanner* bannerAd;

@end

@implementation InMobiBannerAd

#pragma mark - MPInlineAdapter Overriden Methods

- (void)requestAdWithSize:(CGSize)size adapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    MPLogEvent([MPLogEvent adLoadAttemptForAdapter:IMMPAdapterName dspCreativeId:nil dspName:nil]);
    
    // Create and load a IMBanner instance
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    long long placementId = [[info valueForKey:kIMMPPlacementID] longLongValue];

    IMCompletionBlock compBlock = ^{
        self.bannerAd = [[IMBanner alloc] initWithFrame:frame
                                            placementId:placementId
                                               delegate:self];
        if (!self.bannerAd) {
            NSError* error = [NSError errorWithDomain:kIMMPErrorDomain
                                                 code:0
                                             userInfo:@{NSLocalizedDescriptionKey : kIMMPLoadFailed}];
            MPLogEvent([MPLogEvent adLoadFailedForAdapter:IMMPAdapterName error:error]);
            IMCompletionBlock completionBlock = ^{
                [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
            };
            [IMMPABUtilities invokeOnMainThreadAsSynced:NO withCompletionBlock:completionBlock];
            return;
        }
        
        [self.bannerAd shouldAutoRefresh:NO];
        //Mandatory params to be set by the publisher to identify the supply source type
        NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
        [paramsDict setObject:@"c_mopub" forKey:@"tp"];
        [paramsDict setObject:MP_SDK_VERSION forKey:@"tp-ver"];
        self.bannerAd.extras = paramsDict;
        
        [self.bannerAd load:[adMarkup dataUsingEncoding:NSUTF8StringEncoding]];
    };
    [IMMPABUtilities invokeOnMainThreadAsSynced:YES withCompletionBlock:compBlock];
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

- (void)didDisplayAd {
    [self.delegate inlineAdAdapterDidTrackImpression:self];
}

#pragma mark - IMBannerDelegate Methods

- (void)bannerDidFinishLoading:(IMBanner *)banner {
    MPLogEvent([MPLogEvent adLoadSuccessForAdapter:IMMPAdapterName]);
    [self.delegate inlineAdAdapter:self didLoadAdWithAdView:banner];
}

- (void)banner:(IMBanner *)banner didFailToLoadWithError:(IMRequestStatus *)error {
    MPLogEvent([MPLogEvent adLoadFailedForAdapter:IMMPAdapterName error:error]);
    [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)banner:(IMBanner *)banner didInteractWithParams:(NSDictionary *)params {
    MPLogEvent([MPLogEvent adTappedForAdapter:IMMPAdapterName]);
    [self.delegate inlineAdAdapterDidTrackClick:self];
}

- (void)userWillLeaveApplicationFromBanner:(IMBanner *)banner {
    MPLogEvent([MPLogEvent adWillLeaveApplicationForAdapter:IMMPAdapterName]);
    [self.delegate inlineAdAdapterWillLeaveApplication:self];
}

- (void)bannerWillPresentScreen:(IMBanner *)banner {
    MPLogEvent([MPLogEvent adWillAppearForAdapter:IMMPAdapterName]);
    [self.delegate inlineAdAdapterWillExpand:self];
    [self.delegate inlineAdAdapterWillBeginUserAction:self];
}

- (void)bannerDidPresentScreen:(IMBanner *)banner {
    MPLogEvent([MPLogEvent adDidAppearForAdapter:IMMPAdapterName]);
}

- (void)bannerWillDismissScreen:(IMBanner *)banner {
    MPLogEvent([MPLogEvent adWillDisappearForAdapter:IMMPAdapterName]);
}

- (void)bannerDidDismissScreen:(IMBanner *)banner {
    MPLogEvent([MPLogEvent adDidAppearForAdapter:IMMPAdapterName]);
    [self.delegate inlineAdAdapterDidCollapse:self];
    [self.delegate inlineAdAdapterDidEndUserAction:self];
}

- (void)banner:(IMBanner *)banner rewardActionCompletedWithRewards:(NSDictionary *)rewards {
    if (rewards != nil) {
        MPLogInfo(IMMPRewardActionCompleted([rewards description]));
    }
}

@end
