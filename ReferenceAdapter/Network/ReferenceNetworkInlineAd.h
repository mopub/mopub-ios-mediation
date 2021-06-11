//
//  ReferenceNetworkBanner.h
//  MoPub-Reference-Adapters
//
//  Created by Kelly Dun on 3/1/21.
//

#import <UIKit/UIKit.h>
#import "ReferenceNetworkBase.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ReferenceNetworkInlineAdDelegate <NSObject>
/// Ad Clickthrough
- (void)inlineAdClicked;

/// Failed banner load.
- (void)inlineAdDidFailToLoad:(NSError *)error;

/// Failed banner show.
- (void)inlineAdDidFailToShow:(NSError *)error;

/// Successful banner load.
- (void)inlineAdDidLoad;

/// Successful banner show.
- (void)inlineAdDidShow:(UIImageView *)creative;

/// Impression fired.
- (void)inlineAdImpressionTracked;

@end

@interface ReferenceNetworkInlineAd : ReferenceNetworkBase
/// Callback delegate.
@property (nonatomic, weak) id<ReferenceNetworkInlineAdDelegate> delegate;

/// Indicates that a banner has been loaded and is ready to show.
@property (nonatomic, readonly) BOOL isLoaded;

/// Initializes the inline ad placement.
/// @param placement Placement identifier.
/// @param isMediumRectangle Specifies that the placement is a medium rectangle. Otherwise it is
/// assumed that the placement is a banner.
- (instancetype)initWithPlacement:(NSString *)placement isMediumRectangle:(BOOL)isMediumRectangle NS_DESIGNATED_INITIALIZER;

/// Load a banner ad.
- (void)load;

/// Show the banner ad.
- (void)show;

#pragma mark - Unavailable Initializers

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
