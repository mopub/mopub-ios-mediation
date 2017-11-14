//
//  MPViewabilityAdapter.h
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPWebView.h"
#import "MPWebView+Viewability.h"

@protocol MPViewabilityAdapter <NSObject>
@property (nonatomic, readonly) BOOL isTracking;

- (instancetype)initWithAdView:(MPWebView *)webView isVideo:(BOOL)isVideo startTrackingImmediately:(BOOL)startTracking;
- (void)startTracking;
- (void)stopTracking;
- (void)registerFriendlyObstructionView:(UIView *)view;

@end
