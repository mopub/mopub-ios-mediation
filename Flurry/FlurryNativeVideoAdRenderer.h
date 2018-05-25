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
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
    #import <MoPubSDKFramework/MoPub.h>
#else
    #import "MPNativeAdRenderer.h"
#endif


@class MPNativeAdRendererConfiguration;
@class MPStaticNativeAdRendererSettings;


@interface FlurryNativeVideoAdRenderer : NSObject <MPNativeAdRenderer>

@property (nonatomic, readonly) MPNativeViewSizeHandler viewSizeHandler;

+ (MPNativeAdRendererConfiguration *)rendererConfigurationWithRendererSettings:(id<MPNativeAdRendererSettings>)rendererSettings;

@end
