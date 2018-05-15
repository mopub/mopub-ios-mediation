//
//  MMAppSettings.h
//  MMAdSDK
//
//  Copyright (c) 2015 Millennial Media, Inc. All rights reserved.
//

#ifndef MMAppSettings_Header_h
#define MMAppSettings_Header_h

#import <Foundation/Foundation.h>

extern NSString* __nonnull const MMAppSettingsCOPPAEnabled;
extern NSString* __nonnull const MMAppSettingsCOPPADisabled;

/**
 * The object used to configure persistent app-wide settings which are integral for SDK operation.
 */
@interface MMAppSettings : NSObject

/** The siteId of this application. */
@property (atomic, copy, nullable) NSString *siteId;

/** The mediator initializing ad requests. Should only be set by mediation adapters. */
@property (atomic, copy, nullable) NSString *mediator;

/**
 * Returns the current state of COPPA (Children's Online Privacy Protection Act) for the SDK.
 *
 * Returns `nil` if this value has not been explicitly set, otherwise returns `MMAppSettingsCOPPAEnabled` or
 * `MMAppSettingsCOPPADisabled`.
 */
@property (readonly, nullable) NSString *coppa;

/**
 * Set to `YES` to convey to ad buyers that COPPA (Children's Online Privacy Protection Act) restrictions need to be enforced for requests from this user.
 *
 * @param compliance Whether COPPA compliance is enforced.
 */
- (void)setCoppaCompliance:(BOOL)compliance;

/**
 * Set to YES to include the app's bundle identifier, e.g. "com.company.appname", within the MRAID
 * environment settings.
 *
 * Default is NO.
 */
@property (atomic) BOOL mraidIncludeBundleID;

/**
 * Set to YES to include the Identifier For Advertiser within the MRAID environment settings.
 *
 * Default is NO.
 */
@property (atomic) BOOL mraidIncludeIDFA;

@end

#endif
