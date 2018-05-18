//
//  MPMillennialBannerCustomEvent.m
//
//  Copyright (c) 2015 Millennial Media, Inc. All rights reserved.
//

#import "MPMillennialBannerCustomEvent.h"
#import "MPLogging.h"
#import "MPAdConfiguration.h"
#import "MPInstanceProvider.h"
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
                MPLogDebug(@"Millennial adapter version: %@", self.version);
            }
            
            // Collect and pass the user's consent from MoPub onto the One by AOL SDK
            if ( [MoPub sharedInstance].isGDPRApplicable == MPBoolYes )
                [mmSDK setConsentRequired: TRUE];
            else
                [mmSDK setConsentRequired: FALSE];
            
            if ( [[MoPub sharedInstance] currentConsentStatus] == MPConsentStatusConsented ) {
                [mmSDK setConsentDataValue: @"1" forKey:@"mopub"];
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
        MPLogError(@"%@", [error localizedDescription]);
        [delegate bannerCustomEvent:self didFailToLoadAdWithError:error];

        return;
    }

    MPLogDebug(@"Requesting Millennial banner with event info %@.", info);

    NSString *placementId = info[kMoPubMMAdapterAdUnit];
    if (!placementId) {
        NSError *error = [NSError errorWithDomain:MMSDKErrorDomain
                                             code:MMSDKErrorServerResponseNoContent
                                         userInfo:@{
                                                    NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Millennial received no placement ID. Request failed."]
                                                    }];
        MPLogError(@"%@", [error localizedDescription]);
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
    if (!self.didTrackClick) {
        MPLogDebug(@"Millennial banner %@ was clicked.", ad);
        [self.delegate trackClick];
        self.didTrackClick = YES;
    }
}

- (void)inlineAdWillPresentModal:(MMInlineAd *)ad {
    MPLogDebug(@"Millennial banner %@ will present modal.", ad);
    [self.delegate bannerCustomEventWillBeginAction:self];
}

- (void)inlineAdDidCloseModal:(MMInlineAd *)ad {
    MPLogDebug(@"Millennial banner %@ did dismiss modal.", ad);
    [self.delegate bannerCustomEventDidFinishAction:self];
}

-(void)inlineAdWillLeaveApplication:(MMInlineAd *)ad
{
    MPLogDebug(@"Millennial banner %@ will leave application", ad);
    [self.delegate bannerCustomEventWillLeaveApplication:self];
}

- (void)inlineAdRequestDidSucceed:(MMInlineAd *)ad {
    __strong __typeof__(self.delegate) delegate = self.delegate;
    MPLogDebug(@"Millennial banner %@ did load, creative ID %@", ad, self.creativeInfo.creativeId);
    [delegate bannerCustomEvent:self didLoadAd:ad.view];
    [delegate trackImpression];
}

- (void)inlineAd:(MMInlineAd *)ad requestDidFailWithError:(NSError *)error {
    MPLogWarn(@"Millennial banner %@ failed with error (%d) %@", ad, error.code, error.description);
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
}

@end
