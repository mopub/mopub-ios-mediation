//
//  FlurryMPConfig.h
//  MoPub Mediates Flurry
//
//  Created by Flurry.
//  Copyright (c) 2015 Yahoo, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Flurry.h"

#define FlurryMediationOrigin @"Flurry_Mopub_iOS"
#define FlurryAdapterVersion @"7.6.4"

@interface FlurryMPConfig : NSObject

+ (void)startSessionWithApiKey:(NSString *) apiKey;

@end
