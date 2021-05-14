#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
#import <MoPubSDK/MoPub.h>
#else
#import <MoPub.h>
#endif

/**
 *  @brief Interstitial Custom Event Class for MoPub SDK.
 *
 *  @discussion Use in order to implement mediation with Inneractive Interstitial Ads.
 */
@interface FyberInterstitialCustomEvent : MPFullscreenAdAdapter <MPThirdPartyFullscreenAdAdapter>

@end
