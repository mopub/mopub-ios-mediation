#import <Foundation/Foundation.h>
#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
#import <MoPubSDKFramework/MoPub.h>
#else
#import "MoPub.h"
#endif

@class VASInlineAdSize, VASErrorInfo, VASBid;

@interface MPVerizonBannerCustomEvent: MPBannerCustomEvent

+ (void)requestBidWithPlacementId:(nonnull NSString *)placementId
                          adSizes:(nonnull NSArray<VASInlineAdSize *> *)adSizes
                       completion:(void (^_Nonnull)(VASBid * _Nullable bid, VASErrorInfo * _Nullable error))completion;
@end


@interface MPMillennialBannerCustomEvent: MPVerizonBannerCustomEvent
@end
