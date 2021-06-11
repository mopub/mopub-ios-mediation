//
//  ReferenceNetworkFullscreenViewController.h
//  MoPub-Reference-Adapters
//
//  Created by Kelly Dun on 3/1/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ReferenceNetworkFullscreenViewControllerDelegate <NSObject>
- (void)didAppear;
- (void)didTapClose;
- (void)timerDidComplete;
@end

@interface ReferenceNetworkFullscreenViewController : UIViewController
/// The amount of time in seconds from presenting the view controller to when the close button should be
/// displayed to the user. A duration of zero indicates that the close button should be available immediately.
@property (nonatomic, assign) NSTimeInterval closeButtonDelay;

/// Callback handler.
@property (nonatomic, weak) id<ReferenceNetworkFullscreenViewControllerDelegate> delegate;

/// Initializes the fullscreen view controller with the creative.
- (instancetype)initWithCreative:(UIImageView *)creative;
@end

NS_ASSUME_NONNULL_END
