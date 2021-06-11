//
//  ReferenceNetworkNativeAssets.h
//  MoPub-Reference-Adapters
//
//  Created by Kelly Dun on 3/3/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReferenceNetworkNativeAssets : NSObject
/// The call to action text.
@property (nonatomic, copy, nullable) NSString *callToActionText;

/// Clickthrough.
@property (nonatomic, copy, nullable) NSString *clickthrough;

/// Main creative view.
@property (nonatomic, strong) UIView *creative;

/// Native text.
@property (nonatomic, copy, nullable) NSString *text;

/// Title text.
@property (nonatomic, copy, nullable) NSString *title;

@end

NS_ASSUME_NONNULL_END
