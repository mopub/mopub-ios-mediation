#import "PangleAdapterConfiguration.h"
#import <BUAdSDK/BUAdSDKManager.h>

@implementation PangleAdapterConfiguration

NSString * const kPangleAppIdKey = @"app_id";
NSString * const kPanglePlacementIdKey = @"ad_placement_id";

static NSString *mUserId;
static NSString *mRewardName;
static NSInteger mRewardAmount;
static NSString *mMediaExtra;

static NSString * const kAdapterVersion = @"3.5.1.2.0";
static NSString * const kAdapterErrorDomain = @"com.mopub.mopub-ios-sdk.mopub-pangle-adapters";

typedef NS_ENUM(NSInteger, PangleAdapterErrorCode) {
    PangleAdapterErrorCodeMissingIdKey,
};

#pragma mark - MPAdapterConfiguration

- (NSString *)adapterVersion {
    return kAdapterVersion;
}

- (NSString *)biddingToken {
    return [BUAdSDKManager mopubBiddingToken];
}

- (NSString *)moPubNetworkName {
    return @"pangle";
}

- (NSString *)networkSdkVersion {
    return [BUAdSDKManager SDKVersion];
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> *)configuration complete:(void(^)(NSError *))complete {
    NSString *pangleAppIdKey = configuration[kPangleAppIdKey];
    if (configuration.count == 0 || !(pangleAppIdKey && [pangleAppIdKey isKindOfClass:[NSString class]] && pangleAppIdKey.length > 0)) {
        NSError *error = [NSError errorWithDomain:kAdapterErrorDomain
                                             code:PangleAdapterErrorCodeMissingIdKey
                                         userInfo:@{NSLocalizedDescriptionKey:
                                                        @"Invalid or missing Pangle appId, please set networkConfig refer to method '-configCustomEvent' in 'AppDelegate' class"}];
        if (complete != nil) {
            complete(error);
        }
    } else {
        [PangleAdapterConfiguration pangleSDKInitWithAppId:configuration[kPangleAppIdKey]];
        if (complete != nil) {
            complete(nil);
        }
    }
}

+ (void)pangleSDKInitWithAppId:(NSString *)appId {
    if (!(appId && [appId isKindOfClass:[NSString class]] && appId.length > 0)) {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                             code:PangleAdapterErrorCodeMissingIdKey
                                         userInfo:@{NSLocalizedDescriptionKey: @"Incorrect or missing Pangle appId. Failing to initialize. Ensure the appId is correct."}];
        MPLogEvent([MPLogEvent error:error message:nil]);
        return;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            MPBLogLevel logLevel = [MPLogging consoleLogLevel];
            BOOL verboseLoggingEnabled = (logLevel == MPBLogLevelDebug);
            [BUAdSDKManager setLoglevel:(verboseLoggingEnabled == true ? BUAdSDKLogLevelDebug : BUAdSDKLogLevelNone)];

            BOOL canCollectPersonalInfo =  [[MoPub sharedInstance] canCollectPersonalInfo];
            [BUAdSDKManager setGDPR:canCollectPersonalInfo ? 0 : 1];
            
            [BUAdSDKManager setUserExtData:@"[{\"name\":\"mediation\",\"value\":\"mopub\"},{\"name\":\"adapter_version\",\"value\":\"1.2.0\"}]"];

            [BUAdSDKManager setAppID:appId];
            
            MPLogInfo(@"Pangle SDK initialized succesfully with appId: %@.", appId);
        });
    });
}

// Set optional data for rewarded ad
+ (void)setUserId:(NSString *)userId {
    mUserId = userId;
}

+ (NSString *)userId {
    return mUserId;
}

+ (void)setRewardName:(NSString *)rewardName {
    mRewardName = rewardName;
}

+ (NSString *)rewardName {
    return mRewardName;
}

+ (void)setRewardAmount:(NSInteger)rewardAmount {
    mRewardAmount = rewardAmount;
}

+ (NSInteger)rewardAmount {
    return mRewardAmount;
}

+ (void)setMediaExtra:(NSString *)mediaExtra {
    mMediaExtra = mediaExtra;
}

+ (NSString *)mediaExtra {
    return mMediaExtra;
}

#pragma mark - Update the network initialization parameters cache
+ (void)updateInitializationParameters:(NSDictionary *)parameters {
    NSString * appId = parameters[kPangleAppIdKey];
    
    if (appId && [appId isKindOfClass:[NSString class]] && appId.length > 0) {
        NSDictionary * configuration = @{kPangleAppIdKey: appId};
        [PangleAdapterConfiguration setCachedInitializationParameters:configuration];
    }
}
@end
