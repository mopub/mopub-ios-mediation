//
//  BUDMopub_BannerCustomEvent.h
//  BUAdSDKDemo
//
//  Created by bytedance_yuanhuan on 2018/10/24.
//  Copyright © 2018年 bytedance. All rights reserved.
//
#import <Foundation/Foundation.h>
#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
#import <MoPubSDKFramework/MoPub.h>
#else
#import "MPBannerCustomEvent.h"
#import "MoPub.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface PangleBannerCustomEvent : MPBannerCustomEvent

@end

NS_ASSUME_NONNULL_END
