//
//  InMobiRewardedVideoCustomEvent.h
//  MoPub
//
//  Copyright © 2021 MoPub. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
    #import <MoPubSDK/MoPub.h>
#else
    #import "MPFullscreenAdAdapter.h"
#endif

#import <InMobiSDK/IMInterstitial.h>

@interface InMobiRewardedVideoCustomEvent : MPFullscreenAdAdapter <IMInterstitialDelegate>

@end
