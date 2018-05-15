//
//  MMNativeWrapper.h
//  MMAdSDK
//
//  Created by Stephen Tramer on 5/16/17.
//  Copyright © 2017 Millennial Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMNativeAsset.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * This protocol should be used by any objects which represent a data container for Native information returned
 * by a mediator. Because the Millennial SDK is responsible for layout and display of individual components,
 * the SDK being mediated to must offer these values.
 * 
 * For more details on native mediation, including configuring which properties are required to present a
 * correct impression of
 */
@protocol MMNativeWrapper <NSObject>

/**
 * Name of the native type.
 */
@property (nonatomic, readonly) NSString* nativeType;

/**
 * The header title for the native content. If this value is unavailble, `nil` should be returned.
 */
@property (nonatomic, readonly, nullable) MMNativeTextAsset* title;

/**
 * The text for a "call to action" button presented as part of the native ad. If this value is unavailable,
 * `nil` should be returned.
 */
@property (nonatomic, readonly, nullable) MMNativeTextAsset* callToAction;

/**
 * The disclaimer text indicating that the presented content is an advertisement. If this value is unavailable,
 * `nil` should be returned. If no value is provided, the SDK will use preset default text as the required
 * disclaimer.
 */
@property (nonatomic, readonly, nullable) MMNativeTextAsset* disclaimer;

/**
 * The icon (small image) associated with the native content. If this value is unavailable, `nil` should be
 * returned.
 */
@property (nonatomic, readonly, nullable) MMNativeImageAsset* icon;

/**
 * The main image associated with the native content. If this value is unavailable, `nil` should be returned.
 */
@property (nonatomic, readonly, nullable) MMNativeImageAsset* mainImage;

/**
 * The body text associated with the native content. If this value is unavailable, `nil` should be returned.
 */
@property (nonatomic, readonly, nullable) MMNativeTextAsset* body;

/**
 * Rating information for the presented content, as a text value. If this value is unavailable or cannot be
 * represented as text, `nil` should be returned.
 */
@property (nonatomic, readonly, nullable) MMNativeTextAsset* rating;

@end

NS_ASSUME_NONNULL_END
