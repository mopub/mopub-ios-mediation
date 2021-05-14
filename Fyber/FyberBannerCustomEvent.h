#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
#import <MoPubSDK/MoPub.h>
#else
#import <MoPub.h>
#endif

/**
 *  @brief Banner Custom Event Class for MoPub SDK.
 *
 *  @discussion Use in order to implement mediation with Inneractive Banner Ads.
 */
@interface FyberBannerCustomEvent : MPInlineAdAdapter <MPThirdPartyInlineAdAdapter>

@end
