//
//  IMMPABUtilities.h
//  InMobiMopubAdvancedBiddingPlugin
//  InMobi
//
//  Created by Akshit Garg on 24/11/20.
//  Copyright © 2020 InMobi. All rights reserved.
//

#import "IMMPABUtilities.h"

@implementation IMMPABUtilities

+ (void)invokeOnMainThreadAsSynced:(BOOL)sync withCompletionBlock:(IMCompletionBlock)compBlock {
    if (sync) {
        if ([[NSThread currentThread] isMainThread]) {
            compBlock();
        } else {
            dispatch_sync(dispatch_get_main_queue(), compBlock);
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), compBlock);
    }
}

@end
