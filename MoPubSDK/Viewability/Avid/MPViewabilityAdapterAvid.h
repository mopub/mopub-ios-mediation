//
//  MPViewabilityAdapterAvid.h
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPViewabilityAdapter.h"

__attribute__((weak_import)) @interface MPViewabilityAdapterAvid : NSObject <MPViewabilityAdapter>
@property (nonatomic, readonly) BOOL isTracking;

- (instancetype)initWithAdView:(MPWebView *)webView isVideo:(BOOL)isVideo startTrackingImmediately:(BOOL)startTracking;
- (void)startTracking;
- (void)stopTracking;
- (void)registerFriendlyObstructionView:(UIView *)view;

@end
