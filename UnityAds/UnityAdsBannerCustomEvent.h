#import <UnityAds/UADSBanner.h>

#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MPBannerCustomEvent.h>)
#import <MoPubSDKFramework/MPBannerCustomEvent.h>
#else
#import "MPBannerCustomEvent.h"
#endif

@interface UnityAdsBannerCustomEvent : MPBannerCustomEvent<UnityAdsBannerDelegate>

@end