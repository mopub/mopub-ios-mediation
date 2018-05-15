//
//  FlurryNativeCustomEvent.m
//  MoPub Mediates Flurry
//
//  Created by Flurry.
//  Copyright (c) 2015 Yahoo, Inc. All rights reserved.
//

#import "FlurryNativeCustomEvent.h"
#import "FlurryAdNative.h"
#import "FlurryNativeAdAdapter.h"
#import "MPNativeAd.h"
#import "MPNativeAdError.h"
#import "MPLogging.h"
#import "FlurryMPConfig.h"


NSString *const kFlurryApiKey = @"apiKey";
NSString *const kFlurryAdSpaceName = @"adSpaceName";

@interface FlurryNativeCustomEvent () <FlurryAdNativeDelegate>

@property (nonatomic, retain) FlurryAdNative *adNative;

@end

@implementation FlurryNativeCustomEvent

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info
{
    MPLogInfo(@"Requesting Flurry native ad");
    NSString *apiKey = [info objectForKey:kFlurryApiKey];
    NSString *adSpaceName = [info objectForKey:kFlurryAdSpaceName];

    if (!apiKey || !adSpaceName) {
        MPLogError(@"Failed native ad fetch. Missing required server extras [FLURRY_APIKEY and/or FLURRY_ADSPACE]");
        [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:[NSError errorWithDomain:MoPubNativeAdsSDKDomain code:MPNativeAdErrorInvalidServerResponse userInfo:nil]];
        return;
    } else {
        MPLogInfo(@"Server info fetched from MoPub for Flurry. API key: %@. Ad space name: %@", apiKey, adSpaceName);
    }

    [FlurryMPConfig startSessionWithApiKey:apiKey];

    self.adNative = [[FlurryAdNative alloc] initWithSpace:adSpaceName];
    self.adNative.adDelegate = self;
    [self.adNative fetchAd];
}

#pragma mark - Flurry Ad Delegates

- (void) adNativeDidFetchAd:(FlurryAdNative *)flurryAd
{
    MPLogDebug(@"Flurry native ad fetched (customEvent)");
    FlurryNativeAdAdapter *adAdapter = [[FlurryNativeAdAdapter alloc] initWithFlurryAdNative:flurryAd];
    MPNativeAd *interfaceAd = [[MPNativeAd alloc] initWithAdAdapter:adAdapter];

    [self.delegate nativeCustomEvent:self didLoadAd:interfaceAd];
}

- (void) adNative:(FlurryAdNative *)flurryAd adError:(FlurryAdError)adError errorDescription:(NSError *)errorDescription
{
    MPLogDebug(@"Flurry native ad failed to load with error (customEvent): %@", errorDescription.description);
    [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:errorDescription];
}

@end
