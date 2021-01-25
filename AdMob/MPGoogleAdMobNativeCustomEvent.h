#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
#import <MoPubSDK/MoPub.h>
#else
#import "MPNativeCustomEvent.h"
#endif

#import <GoogleMobileAds/GoogleMobileAds.h>
#import "MPGoogleGlobalMediationSettings.h"

@interface MPGoogleAdMobNativeCustomEvent : MPNativeCustomEvent

/// Sets the preferred location of the AdChoices icon.
+ (void)setAdChoicesPosition:(GADAdChoicesPosition)position;

@end
