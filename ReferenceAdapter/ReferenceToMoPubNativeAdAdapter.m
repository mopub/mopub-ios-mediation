//
//  ReferenceToMoPubNativeAdAdapter.m
//  MoPub-Reference-Adapters
//
//  Created by Kelly Dun on 3/3/21.
//

#import "ReferenceToMoPubNativeAdAdapter.h"
#if __has_include("MoPub.h")
#import "MPNativeAdConstants.h"
#endif

@interface ReferenceToMoPubNativeAdAdapter()
@property (nonatomic, strong) ReferenceNetworkNativeAssets *assets;
@end

@implementation ReferenceToMoPubNativeAdAdapter

#pragma mark - Initialization

- (instancetype)initWithAssets:(ReferenceNetworkNativeAssets *)assets {
    if (self = [super init]) {
        _assets = assets;
        
        // Populate the `properties` dictionary with the asset entries.
        NSMutableDictionary *assetDictionary = [NSMutableDictionary dictionary];
        
        if (assets.callToActionText.length > 0) {
            assetDictionary[kAdCTATextKey] = assets.callToActionText;
        }
        
        if (assets.creative != nil) {
            assetDictionary[kAdMainMediaViewKey] = assets.creative;
        }
        
        if (assets.text.length > 0) {
            assetDictionary[kAdTextKey] = assets.text;
        }
        
        if (assets.title.length > 0) {
            assetDictionary[kAdTitleKey] = assets.title;
        }
        
        _properties = assetDictionary;
    }
    
    return self;
}

#pragma mark - MPNativeAdAdapter

// Synthesize the backing storage for the properties specified in the
// `MPNativeAdAdapter` protocol.
@synthesize delegate = _delegate;
@synthesize properties = _properties;

/**
 The default click-through URL for the ad.

 This may safely be set to nil if your network doesn't expose this value (for example, it may only
 provide a method to handle a click, lacking another for retrieving the URL itself).
 */
- (NSURL *)defaultActionURL {
    return (self.assets.clickthrough.length > 0 ? [NSURL URLWithString:self.assets.clickthrough] : nil);
}

/**
 Tells the object to open the specified URL using an appropriate mechanism.

 @param URL The URL to be opened.
 @param controller The view controller that should be used to present the modal view controller.

 Your implementation of this method should either forward the request to the underlying
 third-party ad object (if it has built-in support for handling ad interactions), or open an
 in-application modal web browser or a modal App Store controller.
 */
- (void)displayContentForURL:(NSURL *)URL rootViewController:(UIViewController *)controller {
    // No op
}

/**
 Determines whether MPNativeAd should track clicks

 If not implemented, this will be assumed to return NO, and MPNativeAd will track clicks.
 If this returns YES, then MPNativeAd will defer to the MPNativeAdAdapterDelegate callbacks to
 track clicks.
 */
- (BOOL)enableThirdPartyClickTracking {
    // To opt-out of the MoPub SDK automatic impression counting, this method should return `YES`.
    // When opted out, it is the network SDK's responsibility to track their own impressions.
    return YES;
}

/**
 Tracks a click for this ad.

 To avoid reporting discrepancies, you should only implement this method if the third-party ad
 network requires clicks to be reported manually.
 */
- (void)trackClick {
    // No op
}

/** @name Responding to an Ad Being Attached to a View */

/**
 This method will be called when your ad's content is about to be loaded into a view.

 @param view A view that will contain the ad content.

 You should implement this method if the underlying third-party ad object needs to be informed
 of this event.
 */
- (void)willAttachToView:(UIView *)view {
    // No op
}

/**
 This method will be called when your ad's content is about to be loaded into a view; subviews which contain ad
 contents are also included.

 Note: If both this method and `willAttachToView:` are implemented, ONLY this method will be called.

 @param view A view that will contain the ad content.
 @param adContentViews Array of views that contains the ad's content views.

 You should implement this method if the underlying third-party ad object needs to be informed of this event.
 */
- (void)willAttachToView:(UIView *)view withAdContentViews:(NSArray *)adContentViews {
    // No op
}

/**
 This method will be called if your implementation provides a privacy icon through the properties dictionary
 and the user has tapped the icon.
 */
- (void)displayContentForDAAIconTap {
    // No implementation because there is no custom privacy information icon.
}

/**
 Return your ad's privacy information icon view.

 You should implement this method if your ad supplies its own view for its privacy information icon.
 */
- (UIView *)privacyInformationIconView {
    // No custom privacy information icon.
    return nil;
}

/**
 Return your ad's main media view.

 You should implement this method if your ad supplies its own view for the main media view which is typically
 an image or video. If you implement this method, the SDK will not make any other attempts at retrieving
 the main media asset.
 */
- (UIView *)mainMediaView {
    return self.assets.creative;
}

/**
 Return your ad's icon view.

 You should implement this method if your ad supplies its own view for the icon view which is typically
 an image. If you implement this method, the SDK will not make any other attempts at retrieving
 the icon asset.
 */
- (UIView *)iconMediaView {
    return nil;
}

@end
