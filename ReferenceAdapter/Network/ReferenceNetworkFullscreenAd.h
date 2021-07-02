//
//  ReferenceNetworkFullscreenAd.h
//  MoPub-Reference-Adapters
//
//  Created by Kelly Dun on 3/1/21.
//

#import <Foundation/Foundation.h>
#import "ReferenceNetworkBase.h"

// Forward declaration for protocol
@class ReferenceNetworkFullscreenAd;

NS_ASSUME_NONNULL_BEGIN

@protocol ReferenceNetworkFullscreenAdDelegate <NSObject>
/// Ad Clickthrough
- (void)fullscreenAdClicked;

/// Fullscreen ad has been dismissed by the user.
- (void)fullscreenAdDidDismiss;

/// Failed fullscreen load.
- (void)fullscreenAdDidFailToLoad:(NSError *)error;

/// Failed fullscreen show.
- (void)fullscreenAdDidFailToShow:(NSError *)error;

/// Successful fullscreen load.
- (void)fullscreenAdDidLoad;

/// Fullscreen ad presented to the user.
- (void)fullscreenAdDidPresent;

/// Impression fired.
- (void)fullscreenAdImpressionTracked;

/// Fullscreen ad will be dismissed by the user.
- (void)fullscreenAdWillDismiss;

/// Fullscreen ad will be presented to the user.
- (void)fullscreenAdWillPresent;

/// Fullscreen ad will reward user.
- (void)fullscreenAdWillRewardUser;
@end

@interface ReferenceNetworkFullscreenAd : ReferenceNetworkBase
/// Callback delegate.
@property (nonatomic, weak) id<ReferenceNetworkFullscreenAdDelegate> delegate;

/// Indicates that a fullscreen ad has been loaded and is ready to show.
@property (nonatomic, readonly) BOOL isLoaded;

/// Initializes the fullscreen ad placement.
/// @param placement Placement identifier.
/// @param isRewarded Specifies that the placement is rewarded.
- (instancetype)initWithPlacement:(NSString *)placement isRewarded:(BOOL)isRewarded NS_DESIGNATED_INITIALIZER;

/// Load a fullscreen ad.
- (void)load;

/// Show the fullscreen ad.
/// @param presentingViewController ViewController used to present the fullscreen ad.
- (void)showFromViewController:(UIViewController *)presentingViewController;

#pragma mark - Unavailable Initializers

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
