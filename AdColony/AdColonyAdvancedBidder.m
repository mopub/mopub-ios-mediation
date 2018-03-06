//
//  AdColonyAdvancedBidder.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "AdColonyAdvancedBidder.h"

@implementation AdColonyAdvancedBidder

+ (void)initialize {
    NSLog(@"Initialized Ad Colony advanced bidder");
}

- (NSString *)creativeNetworkName {
    return @"adcolony";
}

- (NSString *)token {
    return @"1";
}

@end
