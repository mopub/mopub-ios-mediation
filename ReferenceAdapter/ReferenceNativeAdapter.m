//
//  ReferenceNativeAdapter.m
//  MoPub-Reference-Adapters
//
//  Created by Kelly Dun on 3/3/21.
//

#import "ReferenceNativeAdapter.h"
#import "ReferenceToMoPubNativeAdAdapter.h"
#import "MPNativeAd.h"

// Network SDK imports
#import "ReferenceNetworkNativeAd.h"

// Private state for the adapter that also specifies conformance to `ReferenceNetworkNativeAdDelegate`.
@interface ReferenceNativeAdapter() <ReferenceNetworkNativeAdDelegate>
@property (nonatomic, strong) ReferenceNetworkNativeAd *nativeAd;
@end

@implementation ReferenceNativeAdapter

#pragma mark - Required MPNativeCustomEvent Implementation

// Ad load entry point.
- (void)requestAdWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    // `info` contains a combination of MoPubSDK passed in information and
    // network SDK-sepcific information from the MoPub UI. Parse out the information
    // that is needed to create the appropriate network SDK classes.
    
    // Retrieve the placement
    NSString *placement = info[@"placement"];
    
    // Initialize an instance of the network SDK's inline ad.
    self.nativeAd = [[ReferenceNetworkNativeAd alloc] initWithPlacement:placement];
    self.nativeAd.delegate = self;
    
    // Load the ad.
    [self.nativeAd load];
}

#pragma mark - ReferenceNetworkNativeAdDelegate

- (void)nativeAdDidClick {
    // no op
}

- (void)nativeAdDidFailToLoad:(NSError *)error {
    // Report the failure to load back to the MoPub SDK.
    [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)nativeAdDidLoad:(ReferenceNetworkNativeAssets *)assets {
    // Generate a MoPub native ad object using `ReferenceToMoPubNativeAdAdapter`
    // as a translation between the Reference network's native assets to the
    // MoPub SDK's native assets.
    ReferenceToMoPubNativeAdAdapter *adapter = [[ReferenceToMoPubNativeAdAdapter alloc] initWithAssets:assets];
    MPNativeAd *mopubNativeAd = [[MPNativeAd alloc] initWithAdAdapter:adapter];
    
    // Report the success of the load.
    [self.delegate nativeCustomEvent:self didLoadAd:mopubNativeAd];
}

@end
