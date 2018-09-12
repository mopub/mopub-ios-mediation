//
//  AppLovinBannerCustomEvent.h
//  
//
//  Created by Thomas So on 7/6/17.
//
//

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
    #import <MoPubSDKFramework/MoPub.h>
#else
    #import "MPBannerCustomEvent.h"
#endif

@interface AppLovinBannerCustomEvent : MPBannerCustomEvent

@end
