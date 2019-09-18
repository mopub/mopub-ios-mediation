//
//  FacebookNativeCustomEvent.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//
#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import "FacebookNativeCustomEvent.h"
#import "FacebookNativeAdAdapter.h"
#import "FacebookAdapterConfiguration.h"
#if __has_include("MoPub.h")
    #import "MoPub.h"
    #import "MPNativeAd.h"
    #import "MPLogging.h"
    #import "MPNativeAdError.h"
#endif

static const NSInteger FacebookNoFillErrorCode = 1001;

@interface FacebookNativeCustomEvent () <FBNativeAdDelegate>

@property (nonatomic, readwrite, strong) FBNativeAd *fbNativeAd;
@property (nonatomic, copy) NSString *fbPlacementId;

@end

@implementation FacebookNativeCustomEvent

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info
{
    [self requestAdWithCustomEventInfo:info adMarkup:nil];
}

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
     self.fbPlacementId = [info objectForKey:@"placement_id"];

    if (self.fbPlacementId) {
        self.fbNativeAd = [[FBNativeAd alloc] initWithPlacementID:self.fbPlacementId];
        self.fbNativeAd.delegate = self;
        [FBAdSettings setMediationService:[FacebookAdapterConfiguration mediationString]];
        
        // Load the advanced bid payload.
        if (adMarkup != nil) {
            MPLogInfo(@"Loading Facebook native ad markup for Advanced Bidding");
            [self.fbNativeAd loadAdWithBidPayload:adMarkup];

            MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], self.fbPlacementId);
        }
        else {
            MPLogInfo(@"Loading Facebook native ad");
            [self.fbNativeAd loadAd];

            MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], self.fbPlacementId);
        }
    } else {
        [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:MPNativeAdNSErrorForInvalidAdServerResponse(@"Invalid Facebook placement ID")];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:MPNativeAdNSErrorForInvalidAdServerResponse(@"Invalid Facebook placement ID")], self.fbPlacementId);
    }
}

#pragma mark - FBNativeAdDelegate

- (void)nativeAdDidLoad:(FBNativeAd *)nativeAd
{
    FacebookNativeAdAdapter *adAdapter = [[FacebookNativeAdAdapter alloc] initWithFBNativeAd:nativeAd adProperties:nil];
    MPNativeAd *interfaceAd = [[MPNativeAd alloc] initWithAdAdapter:adAdapter];

    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], self.fbPlacementId);
    [self.delegate nativeCustomEvent:self didLoadAd:interfaceAd];
}

- (void)nativeAd:(FBNativeAd *)nativeAd didFailWithError:(NSError *)error
{
    if (error.code == FacebookNoFillErrorCode) {
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:MPNativeAdNSErrorForNoInventory()], self.fbPlacementId);
        [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:MPNativeAdNSErrorForNoInventory()];
        
    } else {
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:MPNativeAdNSErrorForInvalidAdServerResponse(@"Facebook ad load error")], self.fbPlacementId);
        [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:MPNativeAdNSErrorForInvalidAdServerResponse(@"Facebook ad load error")];
        
    }
}

@end
