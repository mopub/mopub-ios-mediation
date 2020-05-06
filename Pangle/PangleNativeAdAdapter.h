//
//  BUDMopub_MPNativeCustomEvent.h
//  BUDemo
//
//  Created by Pangle on 2020/1/8.
//  Copyright © 2020 Pangle. All rights reserved.
//

#import <BUAdSDK/BUNativeAd.h>
#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
#import <MoPubSDKFramework/MoPub.h>
#else
#import "MPNativeAdAdapter.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface PangleNativeAdAdapter : NSObject  <MPNativeAdAdapter>

- (instancetype)initWithBUNativeAd:(BUNativeAd *)nativeAd;
@property (nonatomic, strong) NSDictionary *properties;
@property (nonatomic, strong) NSURL *defaultActionURL;

@end

NS_ASSUME_NONNULL_END

