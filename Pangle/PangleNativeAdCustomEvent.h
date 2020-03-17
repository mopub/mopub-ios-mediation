//
//  BUDMopub_NativeAdCustomEvent.h
//  BUDemo
//
//  Created by liudonghui on 2020/1/8.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
#import <MoPubSDKFramework/MoPub.h>
#else
#import "MPNativeAdAdapter.h"
#import "MPNativeCustomEvent.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface PangleNativeAdCustomEvent : MPNativeCustomEvent 

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup;
- (void)requestAdWithCustomEventInfo:(NSDictionary *)info;

@end

NS_ASSUME_NONNULL_END
