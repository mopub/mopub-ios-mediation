//
// Created by Pooja Shashidhar on 4/16/18.
// Copyright (c) 2018 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MoPubMediationLogger : NSObject

typedef enum {
    AdColony,
    AppLovin,
    AdMob,
    Chartboost,
    Facebook,
    Flurry,
    IronSource,
    OneByAOL,
    Tapjoy,
    UnityAds,
    Vungle
} Network;


typedef enum {
    Banner,
    Interstitial,
    RewardedVideo,
    Native
} AdFormat;

typedef enum {
    AD_REQUESTED,
    AD_ERROR,
    AD_UNAVAILABLE,
    AD_WILLSHOW,
    AD_SHOWN,
    AD_LOADED,
    AD_IMPRESSED,
    AD_CLICKED,
    AD_DISMISSED,
    AD_WILLDISMISS,
    AD_EXPIRED,
    AD_COMPLETED
} Event;

extern NSDictionary *eventDictionary;
extern NSDictionary *networkDictionary;
extern NSDictionary *adFormatDictionary;

//@property (strong, nonatomic)NSDictionary *eventDictionary;

- (instancetype)initWithNetworkType:(Network )networkType AndAdFormat:(AdFormat )adFormat ;
- (instancetype)initWithClassName:(NSString *)className;
- (void)log:(Event) eventKey;

@end





