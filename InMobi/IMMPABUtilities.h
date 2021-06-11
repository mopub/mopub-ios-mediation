//
//  IMMPABUtilities.h
//  InMobiMopubAdvancedBiddingPlugin
//  InMobi
//
//  Created by Akshit Garg on 24/11/20.
//  Copyright © 2020 InMobi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^IMCompletionBlock)(void);

@interface IMMPABUtilities : NSObject

+ (void)invokeOnMainThreadAsSynced:(BOOL)sync withCompletionBlock:(IMCompletionBlock)compBlock;

@end

NS_ASSUME_NONNULL_END
