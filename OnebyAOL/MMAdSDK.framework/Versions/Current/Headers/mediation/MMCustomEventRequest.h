//
//  MMCustomEventRequest.h
//  MMAdSDK
//
//  Copyright © 2017 Millennial Media. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MMPlacementType) {
    MMPlacementTypeInline,
    MMPlacementTypeInterstitial,
    MMPlacementTypeNative
};

@class MMAd;

/**
 * A wrapper which contains information relevant to mediators regarding the custom event request.
 */
@interface MMCustomEventRequest : NSObject

-(nonnull instancetype)initWithSiteID:(nullable NSString*)siteID
                          placementID:(NSString*)placementID
                        placementType:(MMPlacementType)placementType;

/**
 * The siteID information which was provided in the custom event request information from the Millennial server.
 */
@property (nonatomic, nullable, readonly) NSString* siteID;

/**
 * The client SDK placement ID which was provided in the custom event request information from the Millennial server.
 */
@property (nonatomic, nullable, readonly) NSString* placementID;

/**
 * The type of placement for which content is being requested.
 */
@property (nonatomic, readonly) MMPlacementType placementType;

@end

NS_ASSUME_NONNULL_END
