#import "PangleAdapterConfiguration.h"
#import <BUAdSDK/BUAdSDKManager.h>

@implementation PangleAdapterConfiguration

NSString * const kPangleAppIdKey = @"app_id";
NSString * const kPanglePlacementIdKey = @"ad_placement_id";

static NSString *mUserId;
static NSString *mRewardName;
static NSInteger mRewardAmount;
static NSString *mMediaExtra;

static NSString * const kAdapterVersion = @"3.2.0.1.0";
static NSString * const kAdapterErrorDomain = @"com.mopub.mopub-ios-sdk.mopub-pangle-adapters";

typedef NS_ENUM(NSInteger, PangleAdapterErrorCode) {
    PangleAdapterErrorCodeMissingIdKey,
};

#pragma mark - MPAdapterConfiguration

- (NSString *)adapterVersion {
    return kAdapterVersion;
}

- (NSString *)biddingToken {
    return nil;
}

- (NSString *)moPubNetworkName {
    return @"pangle";
}

- (NSString *)networkSdkVersion {
    return [BUAdSDKManager SDKVersion];
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> *)configuration complete:(void(^)(NSError *))complete {
    MPBLogLevel logLevel = [MPLogging consoleLogLevel];
    BOOL verboseLoggingEnabled = (logLevel == MPBLogLevelDebug);
    [BUAdSDKManager setLoglevel:(verboseLoggingEnabled == true ? BUAdSDKLogLevelDebug : BUAdSDKLogLevelNone)];
    
    BOOL canCollectPersonalInfo =  [[MoPub sharedInstance] canCollectPersonalInfo];
    [BUAdSDKManager setGDPR:canCollectPersonalInfo ? 0 : 1];
    
    if (configuration.count == 0 || !BUCheckValidString(configuration[kPangleAppIdKey])) {
        NSError *error = [NSError errorWithDomain:kAdapterErrorDomain
                                             code:PangleAdapterErrorCodeMissingIdKey
                                         userInfo:@{NSLocalizedDescriptionKey:
                                                        @"Invalid or missing Pangle appId, please set networkConfig refer to method '-configCustomEvent' in 'AppDelegate' class"}];
        if (complete != nil) {
            complete(error);
        }
    } else {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [BUAdSDKManager setAppID:configuration[kPangleAppIdKey]];
                if (complete != nil) {
                    complete(nil);
                }
            });
        });
    }
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
    
    if (BUCheckValidString(appId)) {
        NSDictionary * configuration = @{kPangleAppIdKey: appId};
        [PangleAdapterConfiguration setCachedInitializationParameters:configuration];
    }
}
@end
