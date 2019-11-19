//
//  MintegralNativeAdAdapter.h
//  MoPubSampleApp
//
//  Copyright © 2016年 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
    #import <MoPubSDKFramework/MoPub.h>
#else
    #import "MPNativeAdAdapter.h"
#endif

@class  MTGNativeAdManager;

extern NSString *const kMTGVideoAdsEnabledKey;

@interface MintegralNativeAdAdapter : NSObject <MPNativeAdAdapter>
@property (nonatomic, weak) id<MPNativeAdAdapterDelegate> delegate;
@property (nonatomic, readonly) NSArray *nativeAds;

- (instancetype)initWithNativeAds:(NSArray *)nativeAds nativeAdManager:(MTGNativeAdManager *)nativeAdManager withUnitId:(NSString *)unitId videoSupport:(BOOL)videoSupport;

@end
