//
//  FlurryNativeCustomEvent.m
//  MoPub Mediates Flurry
//
//  Created by Flurry.
//  Copyright (c) 2015 Yahoo, Inc. All rights reserved.
//

#import "FlurryNativeCustomEvent.h"
#import "FlurryNativeAdAdapter.h"
#import "FlurryAdapterConfiguration.h"
#if __has_include("MoPub.h")
    #import "MPNativeAd.h"
    #import "MPNativeAdError.h"
    #import "MPLogging.h"
#endif
#import "FlurryMPConfig.h"

NSString *const kFlurryApiKey = @"apiKey";
NSString *const kFlurryAdSpaceName = @"adSpaceName";

@interface FlurryNativeCustomEvent () <FlurryAdNativeDelegate>

@property (nonatomic, retain) FlurryAdNative *adNative;

@end

@implementation FlurryNativeCustomEvent

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info
{
    NSString *apiKey = [info objectForKey:kFlurryApiKey];
    NSString *adSpaceName = [info objectForKey:kFlurryAdSpaceName];

    if (!apiKey || !adSpaceName) {
        MPLogInfo(@"Failed native ad fetch. Missing required server extras [FLURRY_APIKEY and/or FLURRY_ADSPACE]");
        NSError *error = [NSError errorWithDomain:MoPubNativeAdsSDKDomain code:MPNativeAdErrorInvalidServerResponse userInfo:nil];

        [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:error];
        
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], nil);
        return;
    } else {
        MPLogInfo(@"Server info fetched from MoPub for Flurry. API key: %@. Ad space name: %@", apiKey, adSpaceName);
    }
    
    // Cache the initialization parameters
    [FlurryAdapterConfiguration updateInitializationParameters:info];

    [FlurryMPConfig startSessionWithApiKey:apiKey];

    self.adNative = [[FlurryAdNative alloc] initWithSpace:adSpaceName];
    self.adNative.adDelegate = self;
    [self.adNative fetchAd];
    
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], nil);
}

#pragma mark - Flurry Ad Delegates

- (void) adNativeDidFetchAd:(FlurryAdNative *)flurryAd
{
    FlurryNativeAdAdapter *adAdapter = [[FlurryNativeAdAdapter alloc] initWithFlurryAdNative:flurryAd];
    MPNativeAd *interfaceAd = [[MPNativeAd alloc] initWithAdAdapter:adAdapter];

    [self.delegate nativeCustomEvent:self didLoadAd:interfaceAd];
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

- (void) adNative:(FlurryAdNative *)flurryAd adError:(FlurryAdError)adError errorDescription:(NSError *)errorDescription
{
    MPLogInfo(@"Flurry native ad failed to load with error (customEvent): %@", errorDescription.description);
    [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:errorDescription];
    
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:errorDescription], [self getAdNetworkId]);
}

- (NSString *) getAdNetworkId {
    return kFlurryApiKey;
}

@end
