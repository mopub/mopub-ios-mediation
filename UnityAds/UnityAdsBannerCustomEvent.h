#import <UnityAds/UADSBannerViewDelegate.h>

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
    #import <MoPubSDK/MoPub.h>
#else
    #import "MPInlineAdAdapter.h"
#endif

@interface UnityAdsBannerCustomEvent : MPInlineAdAdapter <MPThirdPartyInlineAdAdapter, UADSBannerViewDelegate>
@end
