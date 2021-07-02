//
//  InMobiBannerCustomEvent.m
//  MoPub
//
//  Copyright © 2021 MoPub. All rights reserved.
//

#import "InMobiBannerCustomEvent.h"
#import "InMobiAdapterConfiguration.h"
#import <InMobiSDK/IMSdk.h>

#if __has_include("MoPub.h")
    #import "MPLogging.h"
    #import "MPConstants.h"
#endif


@interface InMobiBannerCustomEvent ()

@property (nonatomic, strong) IMBanner * bannerAd;
@property (nonatomic, copy)   NSString * placementId;

@end

@implementation InMobiBannerCustomEvent

#pragma mark - MPInlineAdAdapter Subclass Methods

- (NSString *) getAdNetworkId {
    return _placementId;
}

// Override this method to return NO to perform impression and click tracking manually.
- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

- (void)requestAdWithSize:(CGSize)size adapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    NSString * const accountId   = info[kIMAccountIdKey];
    NSString * const placementId = info[kIMPlacementIdKey];
    
    NSError * accountIdError = [InMobiAdapterConfiguration validateAccountId:accountId forOperation:@"banner ad request"];
    if (accountIdError) {
        [self failLoadWithError:accountIdError];
        return;
    }
    
    [InMobiAdapterConfiguration setCachedInitializationParameters: info];

    NSError * placementIdError = [InMobiAdapterConfiguration validatePlacementId:placementId forOperation:@"banner ad request"];
    if (placementIdError) {
        [self failLoadWithError:placementIdError];
        return;
    }
    
    self.placementId = placementId;
    long long placementIdLong = [placementId longLongValue];
       
    // InMobi supports flex banner sizes. No size standardization logic required.
    if (size.height == 0 || size.width == 0) {
        NSError * zeroSizeError = [InMobiAdapterConfiguration createErrorWith:@"Aborting InMobi banner ad request"
                                                                    andReason:@"Requested banner ad with zero size (0x0) is not valid"
                                                                andSuggestion:@"Ensure requested banner ad size is not (0x0)."];
        [self failLoadWithError:zeroSizeError];
        return;
    }
    CGRect bannerAdFrame = CGRectMake(0, 0, size.width, size.height);
        
    if (![InMobiAdapterConfiguration isInMobiSDKInitialized]) {
        [self failLoadWithError: [InMobiAdapterConfiguration createInitializationError:@"interstitial ad request"]];
        [InMobiAdapterConfiguration initializeInMobiSDK:accountId];
        return;
    }
    
    self.bannerAd = [[IMBanner alloc] initWithFrame:bannerAdFrame placementId:placementIdLong delegate:self];
    if (!self.bannerAd) {
        NSError * bannerFailedToInitialize = [InMobiAdapterConfiguration createErrorWith:@"Aborting InMobi banner ad request"
                                                                               andReason:@"InMobi SDK was unable to initialize a banner object"
                                                                           andSuggestion:@""];
        [self failLoadWithError:bannerFailedToInitialize];
        return;
    }

    // Mandatory params to be set by the publisher to identify the supply source type
    NSMutableDictionary *mandatoryInMobiExtrasDict = [[NSMutableDictionary alloc] init];
    [mandatoryInMobiExtrasDict setObject:@"c_mopub" forKey:@"tp"];
    [mandatoryInMobiExtrasDict setObject:MP_SDK_VERSION forKey:@"tp-ver"];
    self.bannerAd.extras = mandatoryInMobiExtrasDict;
    
    [InMobiAdapterConfiguration setupInMobiSDKDemographicsParams:accountId];
    
    [self.bannerAd shouldAutoRefresh:NO];
    
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class)
                                       dspCreativeId:nil
                                             dspName:nil], [self getAdNetworkId]);
    
    IMCompletionBlock completionBlock = ^{
        if ([adMarkup isKindOfClass:[NSString class]] && adMarkup.length > 0) {
            [self.bannerAd load:[adMarkup dataUsingEncoding:NSUTF8StringEncoding]];
        } else {
            [self.bannerAd load];
        }
    };
    [InMobiAdapterConfiguration invokeOnMainThreadAsSynced:YES withCompletionBlock:completionBlock];
}

- (void)failLoadWithError:(NSError *)error {
    IMCompletionBlock completionBlock = ^{
        [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
    };
    [InMobiAdapterConfiguration invokeOnMainThreadAsSynced:NO withCompletionBlock:completionBlock];
}

#pragma mark - InMobi Banner Delegate Methods

-(void)bannerDidFinishLoading:(IMBanner*)banner {
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)],
                 [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)],
                 [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)],
                 [self getAdNetworkId]);

    [self.delegate inlineAdAdapter:self didLoadAdWithAdView:banner];
    [self.delegate inlineAdAdapterDidTrackImpression:self];
}

-(void)banner:(IMBanner*)banner didFailToLoadWithError:(IMRequestStatus*)error {
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error],
               [self getAdNetworkId]);
    [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:(NSError *)error];
}

-(void)banner:(IMBanner*)banner didInteractWithParams:(NSDictionary*)params {
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)],
                 [self getAdNetworkId]);
    [self.delegate inlineAdAdapterDidTrackClick:self];
}

-(void)userWillLeaveApplicationFromBanner:(IMBanner*)banner {
    MPLogAdEvent([MPLogEvent adWillLeaveApplicationForAdapter:NSStringFromClass(self.class)],
                 [self getAdNetworkId]);
    [self.delegate inlineAdAdapterWillLeaveApplication:self];
}

-(void)bannerWillPresentScreen:(IMBanner*)banner {
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)],
                 [self getAdNetworkId]);
    [self.delegate inlineAdAdapterWillBeginUserAction:self];
}

-(void)bannerDidPresentScreen:(IMBanner*)banner {
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)],
                 [self getAdNetworkId]);
}

-(void)bannerWillDismissScreen:(IMBanner*)banner {
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)],
                 [self getAdNetworkId]);
}

-(void)bannerDidDismissScreen:(IMBanner*)banner {
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)],
                 [self getAdNetworkId]);
    [self.delegate inlineAdAdapterDidEndUserAction:self];
}

// -- Unsupported by MoPub --
// No rewards on Banners
-(void)banner:(IMBanner *)banner rewardActionCompletedWithRewards:(NSDictionary*)rewards {
    // No-op
}

@end
