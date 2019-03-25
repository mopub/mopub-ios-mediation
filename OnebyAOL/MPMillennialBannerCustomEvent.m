//
//  MPMillennialBannerCustomEvent.m
//
//  Copyright (c) 2015 Millennial Media, Inc. All rights reserved.
//

#import "MPMillennialBannerCustomEvent.h"
#if __has_include("MoPub.h")
    #import "MPLogging.h"
#endif
#import "MMAdapterVersion.h"

static NSString *const kMoPubMMAdapterAdUnit = @"adUnitID";
static NSString *const kMoPubMMAdapterDCN = @"dcn";

@interface MPMillennialBannerCustomEvent ()

@property (nonatomic, assign) BOOL didTrackClick;
@property (nonatomic, strong) MMInlineAd *mmInlineAd;

@end

@implementation MPMillennialBannerCustomEvent

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

- (id)init {
    self = [super init];
    if (self) {
        if([[UIDevice currentDevice] systemVersion].floatValue >= 8.0) {
            MMSDK *mmSDK = [MMSDK sharedInstance];
            if(![mmSDK isInitialized]) {
                MMAppSettings *appSettings = [[MMAppSettings alloc] init];
                [mmSDK initializeWithSettings:appSettings withUserSettings:nil];
                MPLogInfo(@"Millennial adapter version: %@", self.version);
            }
        } else {
            self = nil; // No support below minimum OS.
        }
    }
    return self;
}

- (void)dealloc {
    self.mmInlineAd = nil;
    self.delegate = nil;
}

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info {
    __strong __typeof__(self.delegate) delegate = self.delegate;
    MMSDK *mmSDK = [MMSDK sharedInstance];

    if (![mmSDK isInitialized]) {
        NSError *error = [NSError errorWithDomain:MMSDKErrorDomain
                                             code:MMSDKErrorNotInitialized
                                         userInfo:@{
                                                    NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Millennial adapter not properly intialized yet."]
                                                    }];
        
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        [delegate bannerCustomEvent:self didFailToLoadAdWithError:error];

        return;
    }

    NSString *placementId = info[kMoPubMMAdapterAdUnit];
    if (placementId == nil) {
        NSError *error = [NSError errorWithDomain:MMSDKErrorDomain
                                             code:MMSDKErrorServerResponseNoContent
                                         userInfo:@{
                                                    NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Millennial received no placement ID. Request failed."]
                                                    }];
        
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        [delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
        return;
    }

    [mmSDK appSettings].mediator = @"MPMillennialBannerCustomEvent";
    if (info[kMoPubMMAdapterDCN]) {
        [mmSDK appSettings].siteId = info[kMoPubMMAdapterDCN];
    } else {
        [mmSDK appSettings].siteId = nil;
    }

    self.mmInlineAd = [[MMInlineAd alloc] initWithPlacementId:placementId size:size];
    self.mmInlineAd.delegate = self;
    self.mmInlineAd.refreshInterval = -1;

    [self.mmInlineAd.view setFrame:CGRectMake(0, 0, size.width, size.height)];
    [self.mmInlineAd request:nil];

    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getAdNetworkId]);
}

-(MMCreativeInfo*)creativeInfo
{
    return self.mmInlineAd.creativeInfo;
}

-(NSString*)version
{
    return kMMAdapterVersion;
}

#pragma mark - MMInlineAdDelegate methods

- (UIViewController *)viewControllerForPresentingModalView {
    return [self.delegate viewControllerForPresentingModalView];
}

- (void)inlineAdContentTapped:(MMInlineAd *)ad {
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);

    if (!self.didTrackClick) {
        [self.delegate trackClick];
        self.didTrackClick = YES;
    }
}

- (void)inlineAdWillPresentModal:(MMInlineAd *)ad {
    MPLogInfo(@"Millennial banner %@ will present modal.", ad);
    [self.delegate bannerCustomEventWillBeginAction:self];
}

- (void)inlineAdDidCloseModal:(MMInlineAd *)ad {
    MPLogInfo(@"Millennial banner %@ did dismiss modal.", ad);
    [self.delegate bannerCustomEventDidFinishAction:self];
}

-(void)inlineAdWillLeaveApplication:(MMInlineAd *)ad
{
    [self.delegate bannerCustomEventWillLeaveApplication:self];
}

- (void)inlineAdRequestDidSucceed:(MMInlineAd *)ad {
    __strong __typeof__(self.delegate) delegate = self.delegate;
    MPLogInfo(@"Millennial banner %@ did load, creative ID %@", ad, self.creativeInfo.creativeId);
    [delegate bannerCustomEvent:self didLoadAd:ad.view];
    [delegate trackImpression];
    
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

- (void)inlineAd:(MMInlineAd *)ad requestDidFailWithError:(NSError *)error {
    MPLogInfo(@"Millennial banner %@ failed with error (%ld) %@", ad, (long)error.code, error.description);
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
    
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
}

- (NSString *) getAdNetworkId {
    return kMoPubMMAdapterAdUnit;
}

@end
