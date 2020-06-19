#import "PangleAdapterConfiguration.h"
#import <BUAdSDK/BUAdSDKManager.h>

@implementation PangleAdapterConfiguration

NSString * const kPangleAppIdKey = @"app_id";
NSString * const kPanglePlacementIdKey = @"ad_placement_id";

static NSString *mUserId;
static NSString *mRewardName;
static NSInteger mRewardAmount;
static NSString *mExtra;
static NSString * const kAdapterVersion = @"3.0.0.7.1";
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
    NSString *appId = configuration[kPangleAppIdKey];
    
    if (configuration.count == 0 || !BUCheckValidString(appId)) {
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
                [BUAdSDKManager setAppID:appId];
                MPBLogLevel logLevel = [MPLogging consoleLogLevel];
                BOOL verboseLoggingEnabled = (logLevel == MPBLogLevelDebug);
                
                [BUAdSDKManager setLoglevel:(verboseLoggingEnabled == true ? BUAdSDKLogLevelDebug : BUAdSDKLogLevelNone)];
                if ([[MoPub sharedInstance] isGDPRApplicable] != MPBoolUnknown) {
                    BOOL canCollectPersonalInfo =  [[MoPub sharedInstance] canCollectPersonalInfo];
                    /// Custom set the GDPR of the user,GDPR is the short of General Data Protection Regulation,the interface only works in The European.
                    /// @params GDPR 0 close privacy protection, 1 open privacy protection
                    [BUAdSDKManager setGDPR:canCollectPersonalInfo ? 0 : 1];
                }
                if (complete != nil) {
                    complete(nil);
                }
            });
        });
    }
}

// optional: Set userId for reward ad.
+ (void)setUserId:(NSString *)userId {
    mUserId = userId;
}
+ (NSString *)userId {
    return mUserId;
}
// optional: Set rewardName for reward ad.
+ (void)setRewardName:(NSString *)rewardName {
    mRewardName = rewardName;
}
+ (NSString *)rewardName {
    return mRewardName;
}
//optional: Set rewardAmount for reward ad.
+ (void)setRewardAmount:(NSInteger)rewardAmount {
    mRewardAmount = rewardAmount;
}
+ (NSInteger)rewardAmount {
    return mRewardAmount;
}
//optional: Set extra for reward ad.
+ (void)setExtra:(NSString *)extra {
    mExtra = extra;
}
+ (NSString *)extra {
    return mExtra;
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
