#import <Foundation/Foundation.h>
#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
#import <MoPubSDK/MoPub.h>
#else
#import "MoPub.h"
#endif

@class VASCreativeInfo, VASErrorInfo, VASBid;

@interface MPVerizonRewardedVideoCustomEvent : MPFullscreenAdAdapter <MPThirdPartyFullscreenAdAdapter>

@property (nonatomic, readonly, nullable) VASCreativeInfo* creativeInfo;

+ (void)requestBidWithPlacementId:(nonnull NSString *)placementId
                       completion:(void (^_Nonnull)(VASBid * _Nullable bid, VASErrorInfo * _Nullable error))completion;

@end
