//
//  ReferenceInlineAdapter.m
//  MoPub-Reference-Adapters
//
//  Created by Kelly Dun on 3/1/21.
//

#import "ReferenceInlineAdapter.h"

// Network SDK imports
#import "NSError+ReferenceNetwork.h"
#import "ReferenceNetworkInlineAd.h"

// Private state for the adapter that also specifies conformance to `ReferenceNetworkInlineAdDelegate`.
@interface ReferenceInlineAdapter() <ReferenceNetworkInlineAdDelegate>
@property (nonatomic, strong) ReferenceNetworkInlineAd *inlineAd;
@end

@implementation ReferenceInlineAdapter

#pragma mark - Required MPInlineAdAdapter Implementation

// Let the `MPInlineAdAdapter` base class handle the implementation of `delegate` and `localExtras`.
@dynamic delegate;
@dynamic localExtras;

// To opt-out of the MoPub SDK automatic impression and click counting, this method should return `NO`.
// When opted out, it is the network SDK's responsibility to track their own impressions.
- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

// Ad load entry point.
- (void)requestAdWithSize:(CGSize)size adapterInfo:(NSDictionary *)info adMarkup:(NSString * _Nullable)adMarkup {
    // `info` contains a combination of MoPubSDK passed in information and
    // network SDK-sepcific information from the MoPub UI. Parse out the information
    // that is needed to create the appropriate network SDK classes.
    // One example is provided below showing logic to determine if the inline ad is a banner
    // or medium rectangle format.
    
    // Determine if the inline ad format is a banner or medium rectangle.
    NSString *format = info[@"adunit_format"];
    BOOL isMediumRectangleFormat = (format != nil ? ![[format lowercaseString] containsString:@"banner"] : NO);
    
    // Retrieve the required placement. If it's not present or empty, fail the load.
    NSString *placement = info[@"placement"];
    if (placement.length == 0) {
        NSError *error = [NSError noPlacementId];
        [self inlineAdDidFailToLoad:error];
        return;
    }
    
    // Initialize an instance of the network SDK's inline ad.
    self.inlineAd = [[ReferenceNetworkInlineAd alloc] initWithPlacement:placement isMediumRectangle:isMediumRectangleFormat];
    self.inlineAd.delegate = self;
    
    // Load the ad.
    [self.inlineAd load];
}

#pragma mark - ReferenceNetworkInlineAdDelegate

/// Ad Clickthrough
- (void)inlineAdClicked {
    // Notify that the clickthrough was tapped and tracked
    [self.delegate inlineAdAdapterDidTrackClick:self];
    
    // Notify that the app will navigate to the clickthrough destination.
    [self.delegate inlineAdAdapterWillLeaveApplication:self];
}

/// Failed banner load.
- (void)inlineAdDidFailToLoad:(NSError *)error {
    // Report the failure to load back to the MoPub SDK.
    [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
}

/// Failed banner show.
- (void)inlineAdDidFailToShow:(NSError *)error {
    // Report the failure to show back to the MoPub SDK.
    [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
}

/// Successful banner load.
- (void)inlineAdDidLoad {
    // Inline ad loading and showing for this Reference Network SDK are seperate.
    // Currently the MoPub SDK combines load and show into a single action.
    
    // This may change in the future, but for now a successful load must
    // trigger a show attempt, and the result of the show will report
    // the final status back to the MoPub SDK.
    [self.inlineAd show];
}

/// Successful banner show.
- (void)inlineAdDidShow:(UIImageView *)creative {
    // Report the success of the show and give back the creative view to
    // the MoPub SDK for rendering onscreen.
    [self.delegate inlineAdAdapter:self didLoadAdWithAdView:creative];
}

/// Impression fired.
- (void)inlineAdImpressionTracked {
    // Notify that the impression was tracked by the network.
    [self.delegate inlineAdAdapterDidTrackImpression:self];
}

@end
