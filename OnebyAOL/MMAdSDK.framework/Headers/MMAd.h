//
//  MMAd.h
//  MMAdSDK
//
//
//  Copyright (c) 2015 Millennial Media, Inc. All rights reserved.
//

#ifndef MMAd_Header_h
#define MMAd_Header_h

#import <Foundation/Foundation.h>
#import "MMCreativeInfo.h"

/**
 * The base class for all ad placement types. This class should not be directly instantiated.
 */
@interface MMAd : NSObject
/**
 * Initializes a newly created ad. This method must be invoked from the main thread.
 *
 * @param placementId The ID of the placement to be loaded.
 */
-(nullable instancetype)initWithPlacementId:(nonnull NSString*)placementId;

/**
 * The placement ID provided at the time of initialization. This value cannot be changed.
 */
@property (nonatomic, readonly, nonnull) NSString* placementId;

/**
 * Contains identification and source of the ad creative when available.
 */
@property (nonatomic, readonly, nullable) MMCreativeInfo* creativeInfo;

@end

#endif
