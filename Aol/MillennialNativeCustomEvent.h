//
//  MillennialNativeCustomEvent.h
//
//  Copyright (c) 2015 Millennial Media, Inc. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#else
#import "MoPub.h"
#endif

#import <Foundation/Foundation.h>
#import <MMAdSDK/MMAdSDK.h>

/*
 * Certified with Millennial Media 6.6.0
 */
@interface MillennialNativeCustomEvent : MPNativeCustomEvent

@property (nonatomic, readonly) MMCreativeInfo* creativeInfo;
@property (nonatomic, readonly) NSString* version;

@end
