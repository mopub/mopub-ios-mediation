#import "AppLovinAdapterConfiguration.h"

#if __has_include(<AppLovinSDK/AppLovinSDK.h>)
    #import <AppLovinSDK/AppLovinSDK.h>
#else
    #import "ALSdk.h"
#endif

#if __has_include("MoPub.h")
    #import "MPLogging.h"
#endif

@implementation AppLovinAdapterConfiguration
static ALSdk *__nullable AppLovinAdapterConfigurationSDK;

static NSString *const kAppLovinSDKInfoPlistKey = @"AppLovinSdkKey";
static NSString *const kAdapterErrorDomain = @"com.mopub.mopub-ios-sdk.mopub-applovin-adapters";
static NSString *const kAdapterVersion = @"6.2.0.0";

typedef NS_ENUM(NSInteger, AppLovinAdapterErrorCode)
{
    AppLovinAdapterErrorCodeMissingSDKKey,
};

#pragma mark - Test Mode

+ (BOOL)isTestMode {
    return AppLovinAdapterConfigurationSDK.settings.isTestAdsEnabled;
}

+ (void)setIsTestMode:(BOOL)isTestMode {
    AppLovinAdapterConfigurationSDK.settings.isTestAdsEnabled = isTestMode;
}

#pragma mark - MPAdapterConfiguration

- (NSString *)adapterVersion {
    return kAdapterVersion;
}

- (NSString *)biddingToken {
    return AppLovinAdapterConfigurationSDK.adService.bidToken;
}

- (NSString *)moPubNetworkName {
    return @"applovin_sdk";
}

- (NSString *)networkSdkVersion {
    return ALSdk.version;
}

+ (NSString *)pluginVersion
{
    return [@"MoPub-" stringByAppendingString: kAdapterVersion];
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> *)configuration complete:(void(^)(NSError *))completionBlock
{
    ALSdk *sdk = [self SDKFromConfiguration: configuration];
    
    NSError *error;
    if ( sdk )
    {
        AppLovinAdapterConfigurationSDK = sdk;
    }
    // If SDK could not be retrieved, it means SDK key was missing from `configuration` (cached or not) AND the Info.plist
    else
    {
        error = [NSError errorWithDomain: kAdapterErrorDomain
                                    code: AppLovinAdapterErrorCodeMissingSDKKey
                                userInfo: @{NSLocalizedDescriptionKey: @"Could not retrieve AppLovin SDK key from `configuration` or Info.plist"}];
    }
    
    if ( completionBlock ) completionBlock( error );
}

- (nullable ALSdk *)SDKFromConfiguration:(NSDictionary<NSString *, id> *)configuration
{
    // If there is a configuration cached with SDK key already from any of the custom events, use that instead
    NSDictionary<NSString *, id> *cachedConfiguration = [[self class] cachedInitializationParameters];
    NSDictionary<NSString *, id> *configurationToUse = cachedConfiguration[@"sdk_key"] ? cachedConfiguration : configuration;
    
    NSString *key = configurationToUse[@"sdk_key"];
    return ( key.length > 0 ) ? [ALSdk sharedWithKey: key] : [ALSdk shared];
}

@end
