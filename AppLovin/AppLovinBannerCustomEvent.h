//
//  AppLovinBannerCustomEvent.h
//  
//
//

#if __has_include(<MoPub/MoPub.h>)
    #import "MPBannerCustomEvent.h"
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
    #import <MoPubSDKFramework/MPBannerCustomEvent.h>
#endif

@interface AppLovinBannerCustomEvent : MPBannerCustomEvent

@end
