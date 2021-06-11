//
//  IMMPABConstants.h
//  InMobiMopubAdvancedBiddingPlugin
//  InMobi
//
//  Created by Akshit Garg on 24/11/20.
//  Copyright © 2020 InMobi. All rights reserved.
//

#import "IMMPABConstants.h"

@implementation IMMPABConstants

NSString * const kIMMPLoadFailed = @"Inmobi's adapter failed to initialize/load because of invalid PlacementId or invalid Banner Size or IMSDK not initialized.";
NSString * const kIMMPInterstitialReceived = @"[InMobi] InMobi Ad Server responded with an Interstitial ad.";
NSString * const kIMMPErrorDomain = @"com.inmobi.mopubcustomevent.iossdk";
NSString * const kIMMPPlacementID = @"placementid";
NSString * const kIMMPAccountID = @"accountid";

@end
