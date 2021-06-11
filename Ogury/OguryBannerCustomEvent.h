#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
#import <MoPubSDK/MoPub.h>
#else
#import "MPInlineAdAdapter.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface OguryBannerCustomEvent : MPInlineAdAdapter <MPThirdPartyInlineAdAdapter>

@end

NS_ASSUME_NONNULL_END
