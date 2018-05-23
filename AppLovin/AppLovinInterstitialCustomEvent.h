//
//  AppLovinInterstitialCustomEvent.h
//

#if __has_include(<MoPub/MoPub.h>)
    #import "MPInterstitialCustomEvent.h"
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
    #import <MoPubSDKFramework/MPInterstitialCustomEvent.h>
#endif

@interface AppLovinInterstitialCustomEvent : MPInterstitialCustomEvent

@end
