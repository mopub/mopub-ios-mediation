//
//  FlurryNativeAdAdapter.h
//  MoPub Mediates Flurry
//
//  Created by Flurry.
//  Copyright (c) 2015 Yahoo, Inc. All rights reserved.
//

#if __has_include(<Flurry_iOS_SDK/FlurryAdNative.h>)
    #import <Flurry_iOS_SDK/FlurryAdNative.h>
    #import <Flurry_iOS_SDK/FlurryAdNativeDelegate.h>
#else
    #import "FlurryAdNative.h"
    #import "FlurryAdNativeDelegate.h"
#endif

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
    #import <MoPubSDKFramework/MoPub.h>
#else
    #import "MPNativeAdAdapter.h"
#endif

@interface FlurryNativeAdAdapter : NSObject <MPNativeAdAdapter>

@property (nonatomic, weak) id<MPNativeAdAdapterDelegate> delegate;
@property (nonatomic, strong) UIView *videoViewContainer;

- (instancetype)initWithFlurryAdNative:(FlurryAdNative *)adNative;

@end
