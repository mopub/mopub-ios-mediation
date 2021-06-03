//
//  ReferenceFullscreenAdapter.m
//  MoPub-Reference-Adapters
//
//  Created by Kelly Dun on 3/2/21.
//

#import "ReferenceFullscreenAdapter.h"

// Network SDK imports
#import "ReferenceNetworkFullscreenAd.h"

// Private state for the adapter that also specifies conformance to `ReferenceNetworkInlineAdDelegate`.
@interface ReferenceFullscreenAdapter() <ReferenceNetworkFullscreenAdDelegate>
@property (nonatomic, strong) ReferenceNetworkFullscreenAd *fullscreenAd;
@property (nonatomic, assign) BOOL isCurrentRequestRewarded;
@end

@implementation ReferenceFullscreenAdapter

#pragma mark - Required MPFullscreenAdAdapter Implementation

// Let the `MPInlineAdAdapter` base class handle the implementation of `delegate`, and `localExtras`.
@dynamic delegate;
@dynamic localExtras;

// To opt-out of the MoPub SDK automatic impression and click counting, this method should return `NO`.
// When opted out, it is the network SDK's responsibility to track their own impressions and clicks.
- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

// Indicates whether the network SDK has an ad available now.
- (BOOL)hasAdAvailable {
    return self.fullscreenAd.isLoaded;
}

- (BOOL)isRewardExpected {
    // For networks that have distinct rewarded vs non-rewarded fullscreen
    // APIs, this can be hard-coded to `YES` or `NO`.
    return self.isCurrentRequestRewarded;
}

// Ad load entry point.
- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString * _Nullable)adMarkup {
    // `info` contains a combination of MoPubSDK passed in information and
    // network SDK-sepcific information from the MoPub UI. Parse out the information
    // that is needed to create the appropriate network SDK classes.
    // One example is provided below showing logic to determine if the fullscreen ad is rewarded
    // or not.
    
    // Determine if the inline ad format is a banner or medium rectangle.
    NSString *format = info[@"adunit_format"];
    self.isCurrentRequestRewarded = [format.lowercaseString containsString:@"rewarded"];
    
    // Retrieve the placement
    NSString *placement = info[@"placement"];
    
    // Initialize an instance of the network SDK's fullscreen ad.
    self.fullscreenAd = [[ReferenceNetworkFullscreenAd alloc] initWithPlacement:placement isRewarded:self.isCurrentRequestRewarded];
    self.fullscreenAd.delegate = self;
    
    // Load the ad.
    [self.fullscreenAd load];
}

// Ad show entry point.
- (void)presentAdFromViewController:(UIViewController *)viewController {
    // Check that there is an ad available, or else signal back an error to show.
    if (self.hasAdAvailable == NO) {
        NSError *error = [NSError errorWithDomain:@"com.mopub-ios-mediation.reference-adapters" code:-1 userInfo:nil];
        [self fullscreenAdDidFailToShow:error];
        return;
    }
    
    // Show the available ad.
    [self.fullscreenAd showFromViewController:viewController];
}

#pragma mark - ReferenceNetworkFullscreenAdDelegate

/// Ad Clickthrough
- (void)fullscreenAdClicked {
    [self.delegate fullscreenAdAdapterDidReceiveTap:self];          // A user tap was received.
    [self.delegate fullscreenAdAdapterDidTrackClick:self];          // Click was tracked by the network SDK.
    [self.delegate fullscreenAdAdapterWillLeaveApplication:self];   // The clickthrough will leave the app to open the native browser.
}

/// Fullscreen ad has been dismissed by the user.
- (void)fullscreenAdDidDismiss {
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
    [self.delegate fullscreenAdAdapterAdDidDismiss:self];
}

/// Failed fullscreen load.
- (void)fullscreenAdDidFailToLoad:(NSError *)error {
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

/// Failed fullscreen show.
- (void)fullscreenAdDidFailToShow:(NSError *)error {
    [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:error];
}

/// Successful fullscreen load.
- (void)fullscreenAdDidLoad {
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
}

/// Fullscreen ad presented to the user.
- (void)fullscreenAdDidPresent {
    [self.delegate fullscreenAdAdapterAdDidPresent:self];
}

/// Impression fired.
- (void)fullscreenAdImpressionTracked {
    [self.delegate fullscreenAdAdapterDidTrackImpression:self];
}

/// Fullscreen ad will be dismissed by the user.
- (void)fullscreenAdWillDismiss {
    [self.delegate fullscreenAdAdapterAdWillDismiss:self];
}

/// Fullscreen ad will be presented to the user.
- (void)fullscreenAdWillPresent {
    [self.delegate fullscreenAdAdapterAdWillPresent:self];
}

/// Fullscreen ad will reward user.
- (void)fullscreenAdWillRewardUser {
    // Most mediation networks do not have an SDK API reward selection
    // mechanism since it is typically handled server side or in the
    // MoPub UI.
    // In these cases we use `kMPRewardCurrencyAmountUnspecified`.
    MPReward *reward = [[MPReward alloc] initWithCurrencyAmount:@(kMPRewardCurrencyAmountUnspecified)];
    [self.delegate fullscreenAdAdapter:self willRewardUser:reward];
}

@end
