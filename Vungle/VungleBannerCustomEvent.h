//
//  VungleBannerCustomEvent.h
//  MoPubSDK
//
//  Copyright © 2019 MoPub. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
    #import <MoPubSDK/MoPub.h>
#else
    #import "MPInlineAdAdapter.h"
#endif

@interface VungleBannerCustomEvent : MPInlineAdAdapter <MPThirdPartyInlineAdAdapter>

@end

