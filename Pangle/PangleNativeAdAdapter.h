//
//  BUDMopub_MPNativeCustomEvent.h
//  BUDemo
//
//  Created by liudonghui on 2020/1/8.
//  Copyright © 2020 bytedance. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
#import <MoPubSDKFramework/MoPub.h>
#else
#import "MPNativeAdAdapter.h"
#endif

#import <BUAdSDK/BUNativeAd.h>

NS_ASSUME_NONNULL_BEGIN

@interface PangleNativeAdAdapter : NSObject  <MPNativeAdAdapter>

- (instancetype)initWithBUNativeAd:(BUNativeAd *)nativeAd;
@property (nonatomic, strong) NSDictionary *properties;
@property (nonatomic, strong) NSURL *defaultActionURL;

@end

NS_ASSUME_NONNULL_END

