//
//  MPViewabilityAdapterMoat.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "MPLogging.h"
#import "MPViewabilityAdapterMoat.h"

#if __has_include(<MPUBMoatMobileAppKit/MPUBMoatMobileAppKit.h>)
#import <MPUBMoatMobileAppKit/MPUBMoatMobileAppKit.h>
#define __HAS_MOAT_FRAMEWORK_
#endif

#ifdef __HAS_MOAT_FRAMEWORK_
static NSString *const kMOATSendAdStoppedJavascript = @"MoTracker.sendMoatAdStoppedEvent()";
#endif

@interface MPViewabilityAdapterMoat()
@property (nonatomic, readwrite) BOOL isTracking;

#ifdef __HAS_MOAT_FRAMEWORK_
@property (nonatomic, strong) MPUBMoatWebTracker * moatWebTracker;
@property (nonatomic, strong) MPWebView *webView;
@property (nonatomic, assign) BOOL isVideo;
#endif
@end

@implementation MPViewabilityAdapterMoat

- (instancetype)initWithAdView:(MPWebView *)webView isVideo:(BOOL)isVideo startTrackingImmediately:(BOOL)startTracking {
    if (self = [super init]) {
        _isTracking = NO;

#ifdef __HAS_MOAT_FRAMEWORK_
        static dispatch_once_t sMoatSharedInstanceStarted;
        dispatch_once(&sMoatSharedInstanceStarted, ^{
            // explicitly disable location tracking and IDFA tracking
            MPUBMoatOptions *options = [[MPUBMoatOptions alloc] init];
            options.locationServicesEnabled = NO;
            options.IDFACollectionEnabled = NO;
            options.debugLoggingEnabled = NO;

            // start with options
            [[MPUBMoatAnalytics sharedInstance] startWithOptions:options];
        });

        // While the viewability SDKs have features that allow the developer to pass in a container view, WKWebView is
        // not always in MPWebView's view hierarchy. Pass in the contained web view to be safe, as we don't know for
        // sure *how* or *when* MPWebView is traversed.
        UIView *view = webView.containedWebView;

        _moatWebTracker = [MPUBMoatWebTracker trackerWithWebComponent:view];
        _webView = webView;
        _isVideo = isVideo;
        if (_moatWebTracker == nil) {
            NSString * adViewClassName = NSStringFromClass([view class]);
            MPLogError(@"Couldn't attach Moat to %@.", adViewClassName);
        }

        if (startTracking) {
            [_moatWebTracker startTracking];
            _isTracking = YES;
            MPLogInfo(@"[Viewability] MOAT tracking started");
        }
#endif
    }

    return self;
}

- (void)startTracking {
#ifdef __HAS_MOAT_FRAMEWORK_
    // Only start tracking if:
    // 1. Moat is not already tracking
    // 2. Moat is allocated
    if (!self.isTracking && self.moatWebTracker != nil) {
        [self.moatWebTracker startTracking];
        self.isTracking = YES;
        MPLogInfo(@"[Viewability] MOAT tracking started");
    }
#endif
}

- (void)stopTracking {
#ifdef __HAS_MOAT_FRAMEWORK_
    // Only stop tracking if:
    // 1. Moat is currently tracking
    if (self.isTracking) {
        void (^moatEndTrackingBlock)(void) = ^{
            [self.moatWebTracker stopTracking];
            if (self.moatWebTracker) {
                MPLogInfo(@"[Viewability] MOAT tracking stopped");
            }
        };
        // If video, as a safeguard, dispatch `AdStopped` event before we stop tracking.
        // (MoTracker makes sure AdStopped is only dispatched once no matter how many times
        // this function is called)
        if (self.isVideo) {
            [self.webView evaluateJavaScript:kMOATSendAdStoppedJavascript
                           completionHandler:^(id result, NSError *error){
                               moatEndTrackingBlock();
                           }];
        } else {
            moatEndTrackingBlock();
        }

        // Mark Moat as not tracking
        self.isTracking = NO;
    }
#endif
}

- (void)registerFriendlyObstructionView:(UIView *)view {
    // Nothing to do
}

@end
