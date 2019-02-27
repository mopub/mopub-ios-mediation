///
///  @file
///  @brief Definitions for MPVerizonBannerCustomEvent
///
///  @copyright Copyright (c) 2019 Verizon. All rights reserved.
///

#import "MoPub.h"

@class VASInlineAdSize, VASErrorInfo, VASBid;

@interface MPVerizonBannerCustomEvent: MPBannerCustomEvent

+ (void)requestBidWithPlacementId:(nonnull NSString *)placementId
                          adSizes:(nonnull NSArray<VASInlineAdSize *> *)adSizes
                       completion:(void (^)(VASBid * _Nullable bid, VASErrorInfo * _Nullable error))completion;
@end


@interface MPMillennialBannerCustomEvent: MPVerizonBannerCustomEvent
@end
