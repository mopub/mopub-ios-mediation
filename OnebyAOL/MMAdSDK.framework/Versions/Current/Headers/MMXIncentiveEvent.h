//
//  MMXIncentiveEvent.h
//  MMAdSDK
//
//  Created on 3/15/16.
//  Copyright © 2016 Millennial Media. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kMMXIncentiveVideoCompleteEventId;

// Experimental, see MIK-1090.
// Generalized events from incentivized ads.
// Put at the adapter level because used at this level as well
// as levels above and below.
@interface MMXIncentiveEvent: NSObject

@property (nonatomic) NSString* eventId;
@property (nonatomic) NSString* args;

-(instancetype)initWithEventId:(NSString*)eventId andArgs:(NSString *)args;

@end
