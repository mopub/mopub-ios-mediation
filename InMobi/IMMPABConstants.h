//
//  IMMPABConstants.h
//  InMobiMopubAdvancedBiddingPlugin
//  InMobi
//
//  Created by Akshit Garg on 24/11/20.
//  Copyright © 2020 InMobi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define IMMPAdapterName NSStringFromClass(self.class)
#define IMMPRewardActionCompleted(reward) @"InMobi banner reward action completed with rewards: %@", reward

@interface IMMPABConstants : NSObject

extern NSString* const kIMMPLoadFailed;
extern NSString* const kIMMPInterstitialReceived;
extern NSString * const kIMMPErrorDomain;
extern NSString * const kIMMPPlacementID;
extern NSString * const kIMMPAccountID;

@end

NS_ASSUME_NONNULL_END
