//
//  FlurryInterstitialCustomEvent.h
//  MoPub Mediates Flurry
//
//  Created by Flurry.
//  Copyright (c) 2015 Yahoo, Inc. All rights reserved.
//

#if __has_include(<Flurry_iOS_SDK/FlurryAdInterstitial.h>)
    #import <Flurry_iOS_SDK/FlurryAdInterstitial.h>
    #import <Flurry_iOS_SDK/FlurryAdInterstitialDelegate.h>
#else
    #import "FlurryAdInterstitial.h"
    #import "FlurryAdInterstitialDelegate.h"
#endif

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
    #import <MoPubSDKFramework/MoPub.h>
#else
    #import "MPInterstitialCustomEvent.h"
#endif


@interface FlurryInterstitialCustomEvent : MPInterstitialCustomEvent<FlurryAdInterstitialDelegate>

@end
