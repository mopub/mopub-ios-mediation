//
//  AdColonyAdvancedBidder.h
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPAdvancedBidder.h"

@interface AdColonyAdvancedBidder : NSObject<MPAdvancedBidder>
@property (nonatomic, copy, readonly) NSString * creativeNetworkName;
@property (nonatomic, copy, readonly) NSString * token;
@end
