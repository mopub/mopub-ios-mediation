//
//  MPMillennialRewardedVideoCustomEvent.h
//
//  Created by Terence Worley on 8/25/16
//  Copyright (c) 2016 MillennialMedia. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#else
#import "MoPub.h"
#endif

#import <MMAdSDK/MMAdSDK.h>

/*
 * Certified with Millennial Media 6.6.0
 */
@interface MPMillennialRewardedVideoCustomEvent : MPRewardedVideoCustomEvent

@property (nonatomic, readonly) MMCreativeInfo* creativeInfo;

@end
