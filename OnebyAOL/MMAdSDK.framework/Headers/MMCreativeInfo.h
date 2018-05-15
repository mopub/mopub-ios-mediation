//
//  MMCreativeInfo.h
//  MMAdSDK
//
//
//  Copyright (c) 2017 Millennial Media, Inc. All rights reserved.
//

#ifndef MMCreativeInfo_Header_h
#define MMCreativeInfo_Header_h

#import <Foundation/Foundation.h>

/**
 * An object containing the source and identification
 * of the ad content within a placement. This class should not be
 * directly instantiated.
 */
@interface MMCreativeInfo : NSObject

/**
 * The Creative ID associated with the ad content.
 */
@property (nonatomic, readonly, nullable) NSString *creativeId;

/**
 * An identifier for the demand source.
 */
@property (nonatomic, readonly, nullable) NSString *demandSource;

@end

#endif
