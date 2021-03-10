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
#endif // special endif

/**
 *  @brief Rewarded Video Custom Event Class for MoPub SDK.
 *
 *  @discussion Use in order to implement mediation with Inneractive Rewarded Video Ads.
 */
@interface FyberRewardedVideoCustomEvent : MPFullscreenAdAdapter <MPThirdPartyFullscreenAdAdapter>

@end
