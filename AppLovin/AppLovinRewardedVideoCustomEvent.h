#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
    #import <MoPubSDK/MoPub.h>
#else
    #import "MPFullscreenAdAdapter.h"
#endif

// PLEASE NOTE: We have renamed this class from "AppLovinRewardedCustomEvent" to "AppLovinRewardedVideoCustomEvent", you can use either classname in your MoPub account.
@interface AppLovinRewardedVideoCustomEvent : MPFullscreenAdAdapter <MPThirdPartyFullscreenAdAdapter>
@end

// AppLovinRewardedCustomEvent is deprecated but kept here for backwards-compatibility purposes.
@interface AppLovinRewardedCustomEvent : AppLovinRewardedVideoCustomEvent
@end
