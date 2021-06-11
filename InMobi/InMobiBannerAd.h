//
//  InMobiBannerAd.h
//  InMobiMopubAdvancedBiddingPlugin
//  InMobi
//
//  Created by Akshit Garg on 23/11/20.
//  Copyright © 2020 InMobi. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
    #import <MoPubSDKFramework/MoPub.h>
#else
    #import "MPInlineAdAdapter.h"
#endif

#import <InMobiSDK/IMBanner.h>

NS_ASSUME_NONNULL_BEGIN

@interface InMobiBannerAd : MPInlineAdAdapter <MPThirdPartyInlineAdAdapter, IMBannerDelegate>

@end

NS_ASSUME_NONNULL_END
