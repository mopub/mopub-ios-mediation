//
//  MMSDK.h
//  MMAdSDK
//
//  Copyright (c) 2015 Millennial Media, Inc. All rights reserved.
//

#ifndef MMSDK_Header_h
#define MMSDK_Header_h

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
 * Key for setting the IAB Consent String via `setConsentDataValue:forKey`.
 */
extern NSString * __nonnull const MMIABConsentKey;

typedef NS_OPTIONS(NSUInteger, MMLogFlag) {
    MMLogFlagError  = (1 << 0),
    MMLogFlagWarn   = (1 << 1),
    MMLogFlagInfo   = (1 << 2),
    MMLogFlagDebug  = (1 << 3)
};

/** 
 * Log levels for the SDK. `Error` is the least verbose level, `Debug` the most verbose.
 * Using these values rather than the `MMLogFlag` enum is recommended.
 */
typedef NS_ENUM(NSUInteger, MMLogLevel) {
    MMLogLevelError = MMLogFlagError,
    MMLogLevelWarn  = (MMLogLevelError|MMLogFlagWarn),
    MMLogLevelInfo  = (MMLogLevelWarn|MMLogFlagInfo),
    MMLogLevelDebug = (MMLogLevelInfo|MMLogFlagDebug)
};

@class MMAppSettings;
@class MMUserSettings;

/**
 * The MMSDK class is the global singleton used to initialize the SDK state, and manage shared
 * settings.
 *
 * ## Initializing the MMSDK.
 *
 * The appSettings object is optional for MMSDK initialization.
 * This is a readonly object, however, its properties may be changed after initialization.
 *
 * The userSettings object is also optional.
 * This is a readwrite object, so it may be changed after initialization.
 *
 * Usage example:
 * <pre><code>
 *    MMAppSettings *appSettings = [[MMAppSettings alloc] init];
 *    appSettings.siteId = @"<siteId>";
 *    appSettings.mediator = @"<mediator>";
 *    [appSettings setCoppaCompliance:<BOOL>];
 *
 *    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
 *    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
 *    NSDate *dateOfBirth = [dateFormatter dateFromString:@"12/25/1985"];
 *
 *    MMUserSettings *userSettings = [[MMUserSettings alloc] init];
 *    userSettings.age = @(30);
 *    userSettings.children = @(3);
 *    userSettings.education = MMEducationBachelors;
 *    userSettings.dob = dateOfBirth;
 *
 *    [[MMSDK sharedInstance] initializeWithSettings:appSettings withUserSettings:userSettings];
 * </code></pre>
 */
@interface MMSDK : NSObject

/**
 * The shared instance of the Millennial Media SDK.
 *
 * @return The MMSDK singleton.
 */
+(nonnull instancetype)sharedInstance;

/**
 * Sets the console log level for the SDK.
 *
 * @param level The log level to be set.
 */
+(void)setLogLevel:(MMLogLevel)level;

/**
 * Initializes the SDK as a whole. This must be called before any ads are requested.
 *
 * @param appSettings  The appSettings object. Optional.
 * @param userSettings The userSettings object. Optional.
 */
-(void)initializeWithSettings:(nullable MMAppSettings *)appSettings withUserSettings:(nullable MMUserSettings *)userSettings;

/**
 * Sets a boolean indicating if a user or app falls under GDPR jurisdiction. In order to comply with GDPR,
 * if this is set to true and no consent string is set via `setConsentDataValue:forKey:`, user
 * information will not be used or passed over the network.
 *
 * @param consentRequired Set to true if GDPR applies to the user or app, false if GDPR does not apply
 */
-(void)setConsentRequired:(BOOL)consentRequired;

/**
 * Sets consent strings as key value pairs. These will be passed with each ad request.
 *
 * @param consentDataValue The consent string value
 * @param consentDataKey The consent string key
 */
-(void)setConsentDataValue:(nullable NSString *)consentDataValue forKey:(nonnull NSString *)consentDataKey;

/**
 * Clears all consent strings
 */
-(void)clearConsentData;

/**
 * The version of the Millennial Ad SDK.
 *
 * @return The semantic version of the SDK.
 */
-(nonnull NSString*)version;

/**
 * Whether or not to send geolocation information along with each ad request.
 *
 * When set to YES, location information is sent with ad requests ONLY if location permissions are granted for the app.
 * Enabling this will NOT prompt the user for location authorization. Providing location data will help to serve more
 * relevant ads to your users.
 *
 * Set to NO to explicitly disable sending location information with ad requests. Default is YES.
 */
@property (nonatomic, assign) BOOL sendLocationIfAvailable;

/**
 * The CLLocationManager initialized and started by the Millennial Media SDK when location permission is granted by the
 * user and sendLocationIfAvailable is set to YES.
 *
 * This is a readonly property and will be nil when sending location information is explicitly disabled.
 */
@property (nonatomic, readonly, nullable) CLLocationManager* locationManager;

/**
 * Whether or not the SDK has been initialized. The SDK must be initialized before any ads are requested.
 */
@property (nonatomic, assign, readonly) BOOL isInitialized;

/**
 * The SDK's global settings for the application. This object must be set when initializing the SDK.
 *
 * Although this is a read-only property, the returned `MMAppSettings` object may be modified in-place to update
 * any relevant values.
 */
@property (nonatomic, readonly, nullable) MMAppSettings* appSettings;

/**
 * The SDK's user settings object. This can be reset during normal app operations and does not have to be provided
 * at the time of initialization.
 */
@property (nonatomic, readwrite, nullable) MMUserSettings* userSettings;

@end

#endif
