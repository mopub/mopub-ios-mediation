//
//  FyberRewardedVideoCustomEvent.h
//  FyberMarketplaceTestApp
//
//  Created by Fyber 10/03/2021.
//  Copyright (c) 2021 Fyber. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
#import <MoPubSDK/MoPub.h>
#else
#import <MoPub.h>
#endif

@interface FyberRewardedVideoCustomEvent : MPFullscreenAdAdapter <MPThirdPartyFullscreenAdAdapter>

@end
