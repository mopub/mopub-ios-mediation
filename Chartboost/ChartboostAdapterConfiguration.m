#import "ChartboostAdapterConfiguration.h"
#import "ChartboostRouter.h"
#if __has_include("MoPub.h")
#import "MPLogging.h"
#endif

#define CHARTBOOST_ADAPTER_VERSION             @"8.1.0.0"
#define MOPUB_NETWORK_NAME                     @"chartboost"

// Constants
static NSString * const kChartboostAppIdKey        = @"appId";
static NSString * const kChartboostAppSignatureKey = @"appSignature";

// Errors
static NSString * const kAdapterErrorDomain = @"com.mopub.mopub-ios-sdk.mopub-chartboost-adapters";

typedef NS_ENUM(NSInteger, ChartboostAdapterErrorCode) {
    ChartboostAdapterErrorCodeMissingAppId,
    ChartboostAdapterErrorCodeMissingAppSignature,
};

@implementation ChartboostAdapterConfiguration

#pragma mark - Caching

+ (void)updateInitializationParameters:(NSDictionary *)parameters {
    // These should correspond to the required parameters checked in `initializeNetworkWithConfiguration:complete:`
    NSString *appId = parameters[kChartboostAppIdKey];
    NSString *appSignature = parameters[kChartboostAppSignatureKey];
    
    if (appId != nil && appSignature != nil) {
        [ChartboostAdapterConfiguration setCachedInitializationParameters: @{kChartboostAppIdKey: appId,
                                                                             kChartboostAppSignatureKey: appSignature}];
    }
}

#pragma mark - MPAdapterConfiguration

- (NSString *)adapterVersion {
    return CHARTBOOST_ADAPTER_VERSION;
}

- (NSString *)biddingToken {
    return nil;
}

- (NSString *)moPubNetworkName {
    return MOPUB_NETWORK_NAME;
}

- (NSString *)networkSdkVersion {
    return Chartboost.getSDKVersion;
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> *)configuration
                                  complete:(void(^)(NSError *))complete
{
    // configuration may not have credentials info on the first app launch. See https://developers.mopub.com/publishers/ios/initialize/
    if (configuration[kChartboostAppIdKey] == nil) {
        NSError *error = [NSError errorWithDomain:kAdapterErrorDomain
                                             code:ChartboostAdapterErrorCodeMissingAppId
                                         userInfo:@{ NSLocalizedDescriptionKey: @"Chartboost's initialization skipped. The appId is empty. Ensure it is properly configured on the MoPub dashboard. Note that initialization on the first app launch is a no-op." }];
        MPLogEvent([MPLogEvent error:error message:nil]);
        
        if (complete != nil) {
            complete(error);
        }
        return;
    }
    if (configuration[kChartboostAppSignatureKey] == nil) {
        NSError *error = [NSError errorWithDomain:kAdapterErrorDomain
                                             code:ChartboostAdapterErrorCodeMissingAppSignature
                                         userInfo:@{ NSLocalizedDescriptionKey: @"Chartboost's initialization skipped. The appSignature is empty. Ensure it is properly configured on the MoPub dashboard. Note that initialization on the first app launch is a no-op." }];
        MPLogEvent([MPLogEvent error:error message:nil]);
        
        if (complete != nil) {
            complete(error);
        }
        return;
    }
    
    [ChartboostRouter setDataUseConsentWithMopubConfiguration];
    [ChartboostRouter setLoggingLevel:[MPLogging consoleLogLevel]];
    
    [ChartboostRouter startWithParameters:configuration completion:^(BOOL initialized) {
        if (complete != nil) {
            complete(nil);
        }
    }];
}

+ (NSString *)adapterVersion
{
    return CHARTBOOST_ADAPTER_VERSION;
}
    
@end
