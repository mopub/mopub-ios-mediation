//
//  PangleBannerCustomEvent.h
//  BUAdSDKDemo
//
//  Created by Pangle on 2018/10/24.
//  Copyright © 2018年 Pangle. All rights reserved.
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
