//
//  ReferenceNetworkSDK.m
//  MoPub-Reference-Adapters
//
//  Created by Kelly Dun on 3/1/21.
//

#import "ReferenceNetworkSDK.h"

@implementation ReferenceNetworkSDK

#pragma mark - Properties

/// Backing storage for @c isInitialized
static BOOL _isInitialized = NO;

+ (BOOL)isInitialized {
    return _isInitialized;
}

+ (NSString *)token {
    return (_isInitialized == YES ? @"good_token" : @"reference_sdk_not_initialized_token");
}

+ (NSString *)version {
    return @"1.0.0";
}

+ (void)initializeNetworkWithPlacementIds:(NSArray<NSString *> * _Nullable)placements
                               completion:(void(^)(void))complete {
    // Already initialized, do nothing.
    if (_isInitialized == YES) {
        return;
    }
    
    _isInitialized = YES;
    complete();
}

@end
