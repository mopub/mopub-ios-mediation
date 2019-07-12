///
///  @file
///  @brief Definitions for VerizonBidCache
///
///  @copyright Copyright (c) 2019 Verizon. All rights reserved.
///

#import <Foundation/Foundation.h>

@class VASBid;

NS_ASSUME_NONNULL_BEGIN

@interface VerizonBidCache : NSObject

@property (class, nonatomic, readonly) VerizonBidCache *sharedInstance;

- (nullable VASBid *)bidForPlacementId:(NSString *)placementId;
- (void)storeBid:(VASBid *)bid forPlacementId:(NSString *)placementId untilDate:(NSDate *)expirationDate;

@end

NS_ASSUME_NONNULL_END
