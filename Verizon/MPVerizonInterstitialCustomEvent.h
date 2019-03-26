#import "MoPub.h"

@class VASErrorInfo, VASBid;

@interface MPVerizonInterstitialCustomEvent : MPInterstitialCustomEvent

+ (void)requestBidWithPlacementId:(nonnull NSString *)placementId
                       completion:(void (^)(VASBid * _Nullable bid, VASErrorInfo * _Nullable error))completion;

@end
