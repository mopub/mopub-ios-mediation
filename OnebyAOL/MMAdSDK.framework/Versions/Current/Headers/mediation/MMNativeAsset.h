//
//  MMNativeAsset.h
//  MMAdSDK
//
//  Created by Stephen Tramer on 5/16/17.
//  Copyright © 2017 Millennial Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MMAdSDK/MMNativeAd.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * The base class for containing native asset information. You should never instantiate this class directly;
 * instead use a subclass which is guaranteed to contain a specific type of native content.
 */
@interface MMNativeAsset : NSObject

/**
 * Instantiate a native asset container.
 *
 * @param   componentID     The component ID for the asset.
 */
-(instancetype)initWithComponentID:(MMNativeComponentTypeID)componentID;

/**
 * The component type ID of the asset.
 */
@property (nonatomic, readonly) MMNativeComponentTypeID componentID;

/**
 * The instance index of the asset. This value is used internally by the SDK,
 * and should not be relied upon for any mediation actions.
 */
@property (nonatomic, readonly) NSInteger instance;

@end

/**
 * A container for text assets of a native ad.
 */
@interface MMNativeTextAsset : MMNativeAsset

/**
 * Constructs a new text asset with the provided data.
 *
 * @param   text    The text assocated with the asset.
 * @param   componentID The component ID of the asset.
 */
-(instancetype)initWithText:(NSString*)text
                componentID:(MMNativeComponentTypeID)componentID;

/**
 * The text assocciated with the asset.
 */
@property (nonatomic, readonly) NSString* text;

@end

/**
 * A container for image assets of a native ad.
 */
@interface MMNativeImageAsset : MMNativeAsset

/**
 * Constructs a new image asset with the provided data.
 *
 * @param   image   The image associated with the asset.
 * @param   componentID The component ID of the asset.
 */
-(instancetype)initWithImage:(UIImage*)image
                 componentID:(MMNativeComponentTypeID)componentID;

/**
 * The image associated with this asset.
 */
@property (nonatomic, readonly) UIImage* image;

@end

NS_ASSUME_NONNULL_END
