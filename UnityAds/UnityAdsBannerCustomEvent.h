#import <UnityAds/UADSBannerViewDelegate.h>

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
    #import <MoPubSDKFramework/MoPub.h>
#else
    #import "MPInlineAdAdapter.h"
#endif

@interface UnityAdsBannerCustomEvent : MPInlineAdAdapter <MPThirdPartyInlineAdAdapter, UADSBannerViewDelegate>
@end
