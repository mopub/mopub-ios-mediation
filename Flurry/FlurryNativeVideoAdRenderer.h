//
//  FlurryNativeVideoAdRenderer.m
//  MoPub Mediates Flurry
//
//  Created by Flurry.
//  Copyright (c) 2016 Yahoo, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#else
#import "MPNativeAdRenderer.h"
#endif

@class MPNativeAdRendererConfiguration;
@class MPStaticNativeAdRendererSettings;

/*
 * Certified with Flurry 8.2.2
 */
@interface FlurryNativeVideoAdRenderer : NSObject <MPNativeAdRenderer>

@property (nonatomic, readonly) MPNativeViewSizeHandler viewSizeHandler;

+ (MPNativeAdRendererConfiguration *)rendererConfigurationWithRendererSettings:(id<MPNativeAdRendererSettings>)rendererSettings;

@end
