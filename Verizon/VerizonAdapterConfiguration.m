#import <VerizonAdsStandardEdition/VerizonAdsStandardEdition.h>
#import <VerizonAdsCore/VerizonAdsCore.h>
#import <VerizonAdsSupport/VASCommon.h>
#import <VerizonAdsSupport/NSDictionary+VASAds.h>
#import <CoreTelephony/CTCarrier.h>
#import "VerizonAdapterConfiguration.h"

NSString * const kMoPubVASAdapterVersion = @"1.2.1.2";

NSString * const kMoPubVASAdapterErrorWho = @"MoPubVASAdapter";
NSString * const kMoPubVASAdapterPlacementId = @"placementId";
NSString * const kMoPubVASAdapterSiteId = @"siteId";

NSErrorDomain const kMoPubVASAdapterErrorDomain = @"com.verizon.ads.mopubvasadapter.ErrorDomain";
NSTimeInterval kMoPubVASAdapterSATimeoutInterval = 600;

NSString * const kMoPubVASBiddingToken  = @"sy_bp";
NSString * const kMoPubVASNetworkName   = @"verizon";
NSString * const kMoPubMMNetworkName    = @"Millennial";

NSString * const kMoPubServerExtrasAdContent     = @"adMarkup";
NSString * const kMoPubRequestMetadataAdContent  = @"adContent";

static NSString * const kDomainVASAds           = @"com.verizon.ads";
static NSString * const kVASEditionNameKey      = @"editionName";
static NSString * const kVASEditionVersionKey   = @"editionVersion";

@interface VerizonAdapterConfiguration ()

@end

@implementation VerizonAdapterConfiguration

+ (NSString *)appMediator
{
    static NSString *_appMediator = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _appMediator = [NSString stringWithFormat:@"MoPubVAS-%@", kMoPubVASAdapterVersion];
    });
    
    return _appMediator;
}

+ (void)updateInitializationParameters:(NSDictionary *)parameters {}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> * _Nullable)configuration complete:(void(^ _Nullable)(NSError * _Nullable))complete
{
    NSString *siteId = configuration[kMoPubVASAdapterSiteId];
    if (siteId.length == 0) {
        siteId = [VerizonAdapterConfiguration cachedInitializationParameters][kMoPubVASAdapterSiteId];
    }
    if (siteId.length > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([VASStandardEdition initializeWithSiteId:siteId]) {
                MPLogInfo(@"VAS adapter version: %@", kMoPubVASAdapterVersion);
            }
            if (complete) {
                complete(nil);
            }
        });
    } else {
        if (complete) {
            complete(nil);
        }
    }
    
    if (MPLogging.consoleLogLevel == MPBLogLevelDebug) {
        [VASAds setLogLevel:VASLogLevelDebug];
    } else if (MPLogging.consoleLogLevel == MPBLogLevelInfo) {
        [VASAds setLogLevel:VASLogLevelInfo];
    }
}

- (NSString *)adapterVersion
{
    return kMoPubVASAdapterVersion;
}

- (NSString *)biddingToken
{
    VASRequestMetadataBuilder *builder = [[VASRequestMetadataBuilder alloc] initWithRequestMetadata:[[VASAds sharedInstance] requestMetadata]];
    [builder setAppMediator:kMoPubVASAdapterVersion];
        
    return [self buildBiddingTokenWithRequestMetadata:[builder build]];
}

- (NSString *)moPubNetworkName
{
    return kMoPubVASNetworkName;
}

- (NSString *)networkSdkVersion
{
    NSString *editionName = [[[VASAds sharedInstance] configuration] stringForDomain:@"com.verizon.ads"
                                                                                 key:@"editionName"
                                                                         withDefault:nil];

    NSString *editionVersion = [[[VASAds sharedInstance] configuration] stringForDomain:@"com.verizon.ads"
                                                                                    key:@"editionVersion"
                                                                            withDefault:nil];
    if (editionName.length > 0 && editionVersion.length > 0) {
        return [NSString stringWithFormat:@"%@-%@", editionName, editionVersion];
    }
    
    NSString *adapterVersion = [self adapterVersion];
    NSRange range = [adapterVersion rangeOfString:@"." options:NSBackwardsSearch];
    
    return adapterVersion.length > range.location ? [adapterVersion substringToIndex:range.location] : @"";
}

- (NSString *)buildBiddingTokenWithRequestMetadata:(VASRequestMetadata *)metadata
{
    NSMutableDictionary<NSString *, id> *biddingTokenDictionary = [NSMutableDictionary dictionaryWithDictionary:@{
        @"env" : NULL_OR_VALUE([self buildEnvironmentInfoJSON]),
        @"req" : NULL_OR_VALUE([self buildRequestInfoJSONWithRequestMetadata:metadata])}];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:biddingTokenDictionary
                                                       options:0
                                                         error:&error];
    
    if (error) {
        MPLogError(@"Error creating bidding token: %@", error);
        return nil;
    }
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSDictionary *)buildEnvironmentInfoJSON
{
    VASEnvironmentInfo *envInfo = [VASAds sharedInstance].environmentInfo;
    
    // Location Info
    NSMutableDictionary<NSString *, id> *locationDictionary = nil;
    CLLocation *currentLocation = envInfo.locationInfo;

    if (currentLocation) {
        locationDictionary = [NSMutableDictionary dictionaryWithDictionary:@{
            @"ts"        : @([[self getUnixTimeFromDate:currentLocation.timestamp] longValue]),
            @"horizAcc"  : @(currentLocation.horizontalAccuracy),
            @"vertAcc"   : @(currentLocation.verticalAccuracy),
            @"lat"       : @(currentLocation.coordinate.latitude),
            @"lon"       : @(currentLocation.coordinate.longitude),
            @"speed"     : @(currentLocation.speed),
            @"alt"       : @(currentLocation.altitude),
            @"bearing"   : @(currentLocation.course),
            @"src"       : @"coreLocation"}];
    }
    
    // SDK Info
    NSMutableDictionary<NSString *, id> *sdkPluginsDictionary = [[NSMutableDictionary<NSString *, id> alloc] init];
    
    for (VASPlugin *plugin in [VASAds sharedInstance].registeredPlugins) {
        sdkPluginsDictionary[plugin.identifier] = @{
            @"name"         : NULL_OR_VALUE(plugin.name),
            @"version"      : NULL_OR_VALUE(plugin.version),
            @"author"       : NULL_OR_VALUE(plugin.author),
            @"minApiLevel"  : @(plugin.minApiLevel),
            @"email"        : NULL_OR_VALUE([plugin.email absoluteString]),
            @"website"      : NULL_OR_VALUE([plugin.website absoluteString]),
            @"enabled"      : @([[VASAds sharedInstance] isPluginEnabled:plugin.identifier])};
    }
    
    NSMutableDictionary<NSString *, id> *sdkInfo = [NSMutableDictionary dictionaryWithDictionary:@{
        @"coreVer"     : NULL_OR_VALUE(VASAds.sdkInfo.version),
        @"sdkPlugins"  : NULL_OR_VALUE(sdkPluginsDictionary)}];
    
    NSString *editionName = [[VASAds sharedInstance].configuration stringForDomain:kDomainVASAds key:kVASEditionNameKey withDefault:nil];
    NSString *editionVersion = [[VASAds sharedInstance].configuration stringForDomain:kDomainVASAds key:kVASEditionVersionKey withDefault:nil];
    
    if (editionName != nil && editionVersion != nil) {
        sdkInfo[@"editionId"] = [NSString stringWithFormat:@"%@-%@", editionName, editionVersion];
    }
    
    // Device Features
    NSNumber *frontCameraAllowed = envInfo.frontCameraFeatureAllowed;
    NSNumber *rearCameraAllowed = envInfo.rearCameraFeatureAllowed;
    NSNumber *micAllowed = envInfo.micFeatureAllowed;
    NSNumber *gpsAllowed = envInfo.gpsFeatureAllowed;
    NSMutableDictionary<NSString *, id> *deviceFeatures = [NSMutableDictionary dictionaryWithDictionary:@{
        @"cameraFront" : frontCameraAllowed != nil ? frontCameraAllowed : [NSNull null],
        @"cameraRear"  : rearCameraAllowed != nil ? rearCameraAllowed : [NSNull null],
        @"mic"         : micAllowed != nil ? micAllowed : [NSNull null],
        @"gps"         : gpsAllowed != nil ? gpsAllowed : [NSNull null],}];
    
    // Environment Info
    NSNumber *headphonesArePresent = envInfo.headphonesArePresent;
    NSMutableDictionary<NSString *, id> *environmentInfo = [NSMutableDictionary dictionaryWithDictionary:@{
        @"sdkInfo"       : NULL_OR_VALUE(sdkInfo),
        @"loc"           : NULL_OR_VALUE(locationDictionary),
        @"deviceFeatures": NULL_OR_VALUE(deviceFeatures),
        @"mcc"           : NULL_OR_VALUE(envInfo.networkInfo.carrier.mobileCountryCode),
        @"mnc"           : NULL_OR_VALUE(envInfo.networkInfo.carrier.mobileNetworkCode),
        @"ip"            : NULL_OR_VALUE(envInfo.ipAddress),
        @"lang"          : NULL_OR_VALUE(VASEnvironmentInfo.language),
        @"natOrient"     : NULL_OR_VALUE(envInfo.naturalOrientation),
        @"secureContent" : @(VASEnvironmentInfo.isSecureTransportEnabled),
        @"headphones"    : headphonesArePresent != nil ? headphonesArePresent : [NSNull null],
        @"vol"           : envInfo.outputVolume != nil ? @((NSInteger)([envInfo.outputVolume floatValue] * 100)) : [NSNull null],
        @"storage"       : envInfo.availableStorage != nil ? @([envInfo.availableStorage longLongValue]) : [NSNull null],
        @"charging"      : envInfo.batteryInfo != nil ? @(envInfo.batteryInfo.charging) : [NSNull null],
        @"charge"        : envInfo.batteryInfo != nil ? @((envInfo.batteryInfo.level >= 0) ? (NSInteger) (envInfo.batteryInfo.level * 100.0) : 0) : [NSNull null],}];
    
    return [environmentInfo vas_prune];
}

- (NSDictionary *)buildRequestInfoJSONWithRequestMetadata:(VASRequestMetadata *)metadata
{
    NSNumber *isProtectedByGDPR = [self isProtectedByGDPR];
    NSDictionary<NSString *, id> *consentData = [[VASAds sharedInstance].configuration objectForDomain:kVASConfigurationCoreDomain key:kVASConfigUserConsentDataKey withDefault:nil];
    
    NSDictionary<NSString *, id> *requestInfo = [NSMutableDictionary dictionaryWithDictionary:@{
        @"gdpr" : isProtectedByGDPR != nil ? isProtectedByGDPR : [NSNull null],
        @"consentstrings" : NULL_OR_VALUE(consentData),
        @"refreshRate" : NULL_OR_VALUE(metadata.placementData[@"refreshRate"]),
        @"grp" : NULL_OR_VALUE(metadata.placementData[@"impressionGroup"]),
        @"mediator": NULL_OR_VALUE(metadata.appData[@"mediator"]),
        @"targeting" : NULL_OR_VALUE(metadata.customTargeting),
        @"keywords": NULL_OR_VALUE(metadata.keywords)}];

    return [requestInfo vas_prune];
}

- (NSNumber *)getUnixTimeFromDate:(NSDate *)date
{
    if (!date || [date isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return [NSNumber numberWithLongLong:(long long)[date timeIntervalSince1970]];
}

- (NSNumber *)isProtectedByGDPR
{
    BOOL isRestrictedOrigin = [[VASAds sharedInstance].configuration booleanForDomain:kVASConfigurationCoreDomain key:kVASConfigUserRestrictedOriginKey withDefault:NO];
    BOOL isLocationConsentDetermined = [[VASAds sharedInstance].configuration existsForDomain:kVASConfigurationCoreDomain key:kVASConfigLocationRequiresConsentKey];
    
    if (isLocationConsentDetermined) {
        BOOL isConsentRequired = [[VASAds sharedInstance].configuration booleanForDomain:kVASConfigurationCoreDomain key:kVASConfigLocationRequiresConsentKey withDefault:YES];
        
        if (isConsentRequired || isRestrictedOrigin) {
            return @YES;
        } else {
            return @NO;
        }
    } else {
        if (isRestrictedOrigin) {
            return @YES;
        } else {
            return nil;
        }
    }
}

@end
