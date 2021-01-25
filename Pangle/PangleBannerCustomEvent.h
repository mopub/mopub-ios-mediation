#import <Foundation/Foundation.h>
#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
    #import <MoPubSDK/MoPub.h>
#else
    #import "MPInlineAdAdapter.h"
    #import "MoPub.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface PangleBannerCustomEvent : MPInlineAdAdapter <MPThirdPartyInlineAdAdapter>

@end

NS_ASSUME_NONNULL_END
