#import "SnapAdAdapterConfiguration.h"
#import <SAKSDK/SAKSDK.h>

@implementation SnapAdAdapterConfiguration

static NSString * const kSAKAppId = @"appId";
static NSString * const kAdapterErrorDomain = @"com.mopub.mopub-ios-sdk.mopub-snapchat-adapters";
NSString * const kMoPubSnapAdapterVersion = @"1.1.1.0";
NSString * const kMoPubNetworkName = @"SnapAudienceNetwork";

typedef NS_ENUM(NSInteger, SAKAdapterErrorCode) {
    SAKAdpaterErrorCodeMissingAppId,
    SAKAdpaterErrorCodeNetworkError,
    SAKAdpaterErrorCodeEligible,
    SAKAdpaterErrorCodeFailedToParse
};

#pragma mark - Caching

+ (void)updateInitializationParameters:(NSDictionary *)parameters {
    // These should correspond to the required parameters checked in
    // `initializeNetworkWithConfiguration:complete:`
    NSString * appId = parameters[kSAKAppId];
    
    if ([appId length] > 0) {
        NSDictionary * configuration = @{ kSAKAppId: appId };
        [SnapAdAdapterConfiguration setCachedInitializationParameters:configuration];
    }
}

#pragma mark - MPAdapterConfiguration

- (NSString *)adapterVersion {
    return kMoPubSnapAdapterVersion;
}

- (NSString *)biddingToken {
    return nil;
}

- (NSString *)moPubNetworkName {
    return kMoPubNetworkName;
}

- (NSString *)networkSdkVersion {
    return [[SAKMobileAd shared] sdkVersion];
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> *)configuration
                                  complete:(void(^)(NSError *))complete {
    
    NSString * appId = configuration[kSAKAppId];
    
    if ([appId length] == 0) {
        NSError * error = [NSError errorWithDomain:kAdapterErrorDomain code:SAKAdpaterErrorCodeMissingAppId userInfo:@{ NSLocalizedDescriptionKey: @"Snap Ad Kit initialization skipped. The appId is empty. Ensure it is properly configured on the MoPub dashboard." }];
        MPLogEvent([MPLogEvent error:error message:nil]);
    } else {
        [SnapAdAdapterConfiguration initSnapAdKit:configuration complete:complete];
    }
}

+ (void)initSnapAdKit:(NSDictionary *)info complete:(void(^)(NSError *))complete {
    
    NSString * appId = info[kSAKAppId];
    if ([appId length] == 0) {
        NSError * error = [NSError errorWithDomain:kAdapterErrorDomain code:SAKAdpaterErrorCodeNetworkError userInfo:@{ NSLocalizedDescriptionKey: @"Snap Snap Ad Kit initialization skipped. Incorrect or missing Snap appId." }];
        MPLogEvent([MPLogEvent error:error message:nil]);
        
        if (complete != nil) {
            complete(error);
        }
        return;
    }
    
    SAKRegisterRequestConfigurationBuilder *configurationBuilder = [SAKRegisterRequestConfigurationBuilder new];
    [configurationBuilder withSnapKitAppId:appId];
    
    BOOL debugLoggingEnabled = MPLogging.consoleLogLevel == MPBLogLevelDebug;
    
    if (debugLoggingEnabled) {
        [SAKMobileAd shared].debug = YES;
    }
    
    MPLogInfo(@"Initializing SnapAudienceNetwork with appId %@", appId);
    [[SAKMobileAd shared] startWithConfiguration:[configurationBuilder build]
                                      completion:^(BOOL success, NSError *_Nullable error) {
        MPLogInfo(@"MoPub: SAK startWithConfiguration");
        if (error) {
            if (error.code == SAKErrorNetworkError) {
                NSError * error = [NSError errorWithDomain:kAdapterErrorDomain code:SAKAdpaterErrorCodeNetworkError userInfo:@{ NSLocalizedDescriptionKey: @"Snap Snap Ad Kit initialization skipped. There was a network error." }];
                MPLogEvent([MPLogEvent error:error message:nil]);
                return;
            } else if (error.code == SAKErrorNotEligible) {
                NSError * error = [NSError errorWithDomain:kAdapterErrorDomain code:SAKAdpaterErrorCodeEligible userInfo:@{ NSLocalizedDescriptionKey: @"Snap Ad Kit initialization skipped. Not Eligible." }];
                MPLogEvent([MPLogEvent error:error message:nil]);
                return;
            } else if (error.code == SAKErrorFailedToParse) {
                NSError * error = [NSError errorWithDomain:kAdapterErrorDomain code:SAKAdpaterErrorCodeFailedToParse userInfo:@{ NSLocalizedDescriptionKey: @"Snap Ad Kit initialization skipped. Failed to parse the response from network request." }];
                MPLogEvent([MPLogEvent error:error message:nil]);
                return;
            }
        } else {
            MPLogEvent([MPLogEvent error:error message:@"MoPub: Snap Ad Kit initialization completed successfully"]);
        }
        
        if (complete != nil) {
            complete(error);
        }
    }];
}
@end
