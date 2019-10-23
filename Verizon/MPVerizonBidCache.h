#import <Foundation/Foundation.h>
#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
#import <MoPubSDKFramework/MoPub.h>
#else
#import "MoPub.h"
#endif

@class VASBid;

NS_ASSUME_NONNULL_BEGIN

@interface MPVerizonBidCache : NSObject

@property (class, nonatomic, readonly) MPVerizonBidCache *sharedInstance;

- (nullable VASBid *)bidForPlacementId:(NSString *)placementId;
- (void)storeBid:(VASBid *)bid forPlacementId:(NSString *)placementId untilDate:(NSDate *)expirationDate;

@end

NS_ASSUME_NONNULL_END
