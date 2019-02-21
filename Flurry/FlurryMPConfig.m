//
//  FlurryMPConfig.m
//  MoPub Mediates Flurry
//
//  Created by Flurry.
//  Copyright (c) 2015 Yahoo, Inc. All rights reserved.
//

#import "FlurryMPConfig.h"

@implementation FlurryMPConfig

+ (void)startSessionWithApiKey:(NSString *)apiKey
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![Flurry activeSessionExists]) {
            [Flurry setLogLevel:FlurryLogLevelDebug];
            [Flurry startSession:apiKey];
        }
        [Flurry addOrigin:FlurryMediationOrigin withVersion:FlurryAdapterVersion];
    });
}

@end
