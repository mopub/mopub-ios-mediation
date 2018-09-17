//
//  MillennialNativeAdAdapter.h
//
//  Copyright (c) 2015 Millennial Media, Inc. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
    #import <MoPubSDKFramework/MoPub.h>
#else
    #import "MoPub.h"
#endif

#import <MMAdSDK/MMAdSDK.h>
#import <Foundation/Foundation.h>

// <MPNativeAdRendering> custom asset properties.
extern NSString * const kAdMainImageViewKey;      // UIImageView *
extern NSString * const kMMAdIconImageViewKey;    // UIImageView *
extern NSString * const kDisclaimerKey;           // NSString *

@interface MillennialNativeAdAdapter : NSObject <MPNativeAdAdapter>

@property (nonatomic, weak) id<MPNativeAdAdapterDelegate> delegate;

- (instancetype)initWithMMNativeAd:(MMNativeAd *)ad;

@end
