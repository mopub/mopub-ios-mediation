//
//  FlurryNativeAdAdapter.h
//  MoPub Mediates Flurry
//
//  Created by Flurry.
//  Copyright (c) 2015 Yahoo, Inc. All rights reserved.
//
#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#else
#import "MPNativeAdAdapter.h"
#endif

@class FlurryAdNative;

@interface FlurryNativeAdAdapter : NSObject <MPNativeAdAdapter>

@property (nonatomic, weak) id<MPNativeAdAdapterDelegate> delegate;
@property (nonatomic, strong) UIView *videoViewContainer;

- (instancetype)initWithFlurryAdNative:(FlurryAdNative *)adNative;

@end
