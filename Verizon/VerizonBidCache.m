///
///  @file
///  @brief Implementation for VerizonBidCache
///
///  @copyright Copyright (c) 2019 Verizon. All rights reserved.
///

#import "VerizonBidCache.h"
#import <VerizonAdsInlinePlacement/VerizonAdsInlinePlacement.h>
#if __has_include("MoPub.h")
#import "MoPub.h"
#endif

#pragma mark - Timer

@implementation NSTimer (VerizonBidCacheAdditions)

+ (NSTimer *)bidCacheScheduledTimerWithTimeInterval:(NSTimeInterval)interval block:(void (^)(NSTimer *timer))block
{
    return [self scheduledTimerWithTimeInterval:interval
                                         target:self
                                       selector:@selector(bidCacheTimerFired:)
                                       userInfo:block
                                        repeats:NO];
}

+ (void)bidCacheTimerFired:(NSTimer *)timer
{
    void(^timerBlock)(NSTimer *) = timer.userInfo;
    if (timerBlock != nil) {
        timerBlock(timer);
    }
}

@end


@interface VerizonBidCache ()

@property (nonatomic, nonnull, readonly) NSCache<NSString*, VASBid *> *cache;

@end

@implementation VerizonBidCache

+ (instancetype)sharedInstance
{
    static VerizonBidCache *_bidCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _bidCache = [[VerizonBidCache alloc] init];
    });
    return _bidCache;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _cache = [[NSCache alloc] init];
    }
    return self;
}

- (nullable VASBid *)bidForPlacementId:(nonnull NSString *)placementId {
    return [self.cache objectForKey:placementId];
}

- (void)storeBid:(nonnull VASBid *)bid
          forPlacementId:(nonnull NSString *)placementId
               untilDate:(nonnull NSDate *)expirationDate {
    MPLogDebug(@"Store bid %@-%@ in the cache, expiration date %@", bid, placementId, expirationDate);
    
    [self.cache setObject:bid forKey:placementId];
    
    __weak VerizonBidCache *weakSelf = self;
    __weak VASBid *weakBid = bid;
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSTimer bidCacheScheduledTimerWithTimeInterval:[expirationDate timeIntervalSinceNow] block:^(NSTimer *timer) {
            [weakSelf expirationTimerFiredForBid:weakBid withPlacementId:placementId];
        }];
    });
}

- (void)removeBidForPlacement:(nonnull NSString *)placementId {
    MPLogDebug(@"Remove playlist with placement id %@ from the cache.", placementId);
    [self.cache removeObjectForKey:placementId];
}

#pragma mark - Private

- (void)expirationTimerFiredForBid:(VASBid *)bid
                   withPlacementId:(NSString *)placementId {
    //process only items in the cache
    if (bid != nil && bid == [self bidForPlacementId:placementId]) {
        MPLogDebug(@"%s (%@)", __PRETTY_FUNCTION__, placementId);
        [self removeBidForPlacement:placementId];
    }
}

@end
