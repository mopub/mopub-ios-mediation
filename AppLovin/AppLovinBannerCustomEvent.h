#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
    #import <MoPubSDK/MoPub.h>
#else
    #import "MPInlineAdAdapter.h"
#endif

@interface AppLovinBannerCustomEvent : MPInlineAdAdapter <MPThirdPartyInlineAdAdapter>

@end
