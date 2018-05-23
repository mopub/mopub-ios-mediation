//
//  MPMillennialBannerCustomEvent.h
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

@interface MPMillennialBannerCustomEvent : MPBannerCustomEvent <MMInlineDelegate>

@property (nonatomic, readonly) MMCreativeInfo* creativeInfo;

@end
