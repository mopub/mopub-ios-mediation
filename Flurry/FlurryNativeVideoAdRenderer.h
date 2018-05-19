//
//  FlurryNativeVideoAdRenderer.m
//  MoPub Mediates Flurry
//
//  Created by Flurry.
//  Copyright (c) 2016 Yahoo, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPNativeAdRenderer.h"

@class MPNativeAdRendererConfiguration;
@class MPStaticNativeAdRendererSettings;


@interface FlurryNativeVideoAdRenderer : NSObject <MPNativeAdRenderer>

@property (nonatomic, readonly) MPNativeViewSizeHandler viewSizeHandler;

+ (MPNativeAdRendererConfiguration *)rendererConfigurationWithRendererSettings:(id<MPNativeAdRendererSettings>)rendererSettings;

@end
