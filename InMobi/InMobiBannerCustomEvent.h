//
//  InMobiBannerCustomEvent.h
//  MoPub
//
//  Copyright © 2021 MoPub. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
    #import <MoPubSDK/MoPub.h>
#else
    #import "MPInlineAdAdapter.h"
#endif

#import <InMobiSDK/IMBanner.h>

@interface InMobiBannerCustomEvent : MPInlineAdAdapter <IMBannerDelegate>

@end
