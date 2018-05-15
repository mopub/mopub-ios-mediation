//
//  MMRequestInfo.h
//  MMAdSDK
//
//  Copyright (c) 2015 Millennial Media, Inc. All rights reserved.
//

#ifndef MMRequestInfo_Header_h
#define MMRequestInfo_Header_h

#import <Foundation/Foundation.h>

/**
 * The object used to configure per-request settings. This object should only be constructed if the context in
 * which your ad placement request is made can be used to imply any additional information useful for targeting.
 */
@interface MMRequestInfo : NSObject

/** Keywords relevant to this individual request, e.g. `["videotapes"]`
 *
 * Please note that this API must not be used to send personal data about your users. Use the UserSettings object to send user profile information in your ad requests.
 */
@property (nonatomic, copy, nullable) NSArray* keywords;

/**
 * The impression group ID for sites that are enabled to group traffic in this way.
 */
@property (nonatomic, copy, nullable) NSString* impressionGroup;

/**
 * Add custom targeting key value pairs.  These values are passed on each ad request.
 *
 * Please note that this API must not be used to send personal data about your users. Use the UserSettings object to send user profile information in your ad requests.
 *
 * @param customTargetKey   The custom targeting key. (Null, empty string and white space only values will not be added to the request)
 * @param customTargetValue The custom targeting value. (Null, empty string and white space only values will delete the key value pair)
 */
-(void)addCustomTargetingKey:(nullable NSString *)customTargetKey andValue:(nullable NSString *)customTargetValue;

/**
 * Get the custom target value assigned to the given key.
 *
 * @param customTargetKey The custom targeting key to be retrieved.
 * @return The custom target value assigned to the provided key.
 */
-(nullable NSString *)getCustomTargetingValueForKey:(nullable NSString *)customTargetKey;

@end

#endif
