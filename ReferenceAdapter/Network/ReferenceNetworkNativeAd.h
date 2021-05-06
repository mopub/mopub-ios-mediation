//
//  ReferenceNativeAd.h
//  MoPub-Reference-Adapters
//
//  Created by Kelly Dun on 3/3/21.
//

#import <UIKit/UIKit.h>
#import "ReferenceNetworkBase.h"
#import "ReferenceNetworkNativeAssets.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ReferenceNetworkNativeAdDelegate <NSObject>
- (void)nativeAdDidClick;
- (void)nativeAdDidFailToLoad:(NSError *)error;
- (void)nativeAdDidLoad:(ReferenceNetworkNativeAssets *)assets;
@end

@interface ReferenceNetworkNativeAd : ReferenceNetworkBase
/// Callback delegate.
@property (nonatomic, weak) id<ReferenceNetworkNativeAdDelegate> delegate;

/// Initializes a native ad instance.
/// @param placement Placement identifier.
- (instancetype)initWithPlacement:(NSString *)placement NS_DESIGNATED_INITIALIZER;

/// Load a native ad.
- (void)load;

#pragma mark - Unavailable Initializers

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
