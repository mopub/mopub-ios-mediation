//
//  MPNativeAdConfigValues.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "MPNativeAdConfigValues.h"
#import "MPNativeAdConfigValues+Internal.h"

@implementation MPNativeAdConfigValues

- (instancetype)initWithImpressionMinVisiblePercent:(NSInteger)impressionMinVisiblePercent
                        impressionMinVisibleSeconds:(NSTimeInterval)impressionMinVisibleSeconds {
    if (self = [super init]) {
        _impressionMinVisiblePercent = impressionMinVisiblePercent;
        _impressionMinVisibleSeconds = impressionMinVisibleSeconds;
    }
    
    return self;
}

- (BOOL)isImpressionMinVisibleSecondsValid {
    return [self isValidTimeInterval:self.impressionMinVisibleSeconds];
}

- (BOOL)isImpressionMinVisiblePercentValid {
    return [self isValidPercentage:self.impressionMinVisiblePercent];
}

@end
