//
//  FlurryMPConfig.h
//  MoPub Mediates Flurry
//
//  Created by Flurry.
//  Copyright (c) 2015 Yahoo, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_include(<Flurry_iOS_SDK/Flurry.h>)
    #import <Flurry_iOS_SDK/Flurry.h>
    #import <Flurry_iOS_SDK/FlurryAdError.h>
#else
    #import "Flurry.h"
    #import "FlurryAdError.h"
#endif

#define FlurryMediationOrigin @"Flurry_Mopub_iOS"
#define FlurryAdapterVersion @"9.3.1.0"

@interface FlurryMPConfig : NSObject

+ (void)startSessionWithApiKey:(NSString *) apiKey;

@end
