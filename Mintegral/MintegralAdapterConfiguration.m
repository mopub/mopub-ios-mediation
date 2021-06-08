#import <Foundation/Foundation.h>
#import "MintegralAdapterConfiguration.h"
#import <MTGSDK/MTGSDK.h>
#import <MTGSDKBidding/MTGBiddingSDK.h>
#if __has_include("MoPub.h")
#import "MoPub.h"
#endif

@interface MintegralAdapterConfiguration()

@end

static BOOL mintegralSDKInitialized = NO;
static BOOL mute = NO;

NSString *const kMintegralErrorDomain = @"com.mintegral.iossdk.mopub";

static NSString * const MintegralConfigurationKeyAppIdKey = @"appId";
static NSString * const MintegralConfigurationKeyAppKey = @"appKey";
static NSString * const kAdapterVersion = @"6.9.1.0.0";
static NSString * const kPluginNumber = @"Y+H6DFttYrPQYcIA+F2F+F5/Hv==";
static NSString * const kNetworkName = @"mintegral";

@implementation MintegralAdapterConfiguration

#pragma mark - MPAdapterConfiguration

- (NSString *)adapterVersion {
    return kAdapterVersion;
}

- (NSString *)biddingToken {
    return [MTGBiddingSDK buyerUID];
}

- (NSString *)moPubNetworkName {
    return kNetworkName;
}

- (NSString *)networkSdkVersion {
    return MTGSDK.sdkVersion;
}

+ (void)updateInitializationParameters:(NSDictionary *)parameters {
    NSString * appId = parameters[MintegralConfigurationKeyAppIdKey];
    NSString * appKey = parameters[MintegralConfigurationKeyAppKey];

    if (appId != nil && appKey != nil) {
        NSDictionary * configuration = @{ MintegralConfigurationKeyAppIdKey: appId, MintegralConfigurationKeyAppKey: appKey };
        
        [MintegralAdapterConfiguration setCachedInitializationParameters:configuration];
    }
}


- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *,id> *)configuration complete:(void (^)(NSError * _Nullable))complete {
    MPLogInfo(@"Attempting to initialize Mintegral");
    
    NSString *errorMsg = @"";
    NSString *appId = nil;
    NSString *appKey = nil;
    
    if (configuration == nil) {
        errorMsg = [errorMsg stringByAppendingString: @"Mintegral initialization skipped because of invalid/missing appId and appKey"];
    } else {
        appId = [configuration objectForKey:@"appId"];
        appKey = [configuration objectForKey:@"appKey"];
        
        if (appId == nil) {
            errorMsg = [errorMsg stringByAppendingString: @"Mintegral initialization skipped because of invalid/missing appId"];
        }
        
        if (appKey == nil) {
            errorMsg = [errorMsg stringByAppendingString: @"Mintegral initialization skipped because of invalid/missing appKey"];
        }
    }
    
    if (errorMsg.length > 0) {
        NSError *error = [NSError errorWithDomain:kMintegralErrorDomain
                                             code:MPErrorNetworkConnectionFailed
                                         userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
        
        if (complete != nil) {
            complete(error);
        }
        
        return;
    }
    
    [MintegralAdapterConfiguration initializeMintegral:configuration setAppID:appId appKey:appKey];
    
    if (complete != nil) {
        complete(nil);
    }
}

+(void)initializeMintegral:(NSDictionary *)info setAppID:(nonnull NSString *)appId appKey:(nonnull NSString *)appKey {
    if (![MintegralAdapterConfiguration isSDKInitialized]) {
        [[MTGSDK sharedInstance] setConsentStatus:[[MoPub sharedInstance] canCollectPersonalInfo]];
        [[MTGSDK sharedInstance] setAppID:appId ApiKey:appKey];
        
        [MintegralAdapterConfiguration sdkInitialized];
    }
}

+(BOOL)isSDKInitialized {
    return mintegralSDKInitialized;
}

+(void)sdkInitialized {
    Class class = NSClassFromString(@"MTGSDK");
    SEL selector = NSSelectorFromString(@"setChannelFlag:");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([class respondsToSelector:selector]) {
        [class performSelector:selector withObject:kPluginNumber];
    }
#pragma clang diagnostic pop
    mintegralSDKInitialized = YES;
    MPLogInfo(@"Mintegral SDK initialized");
}

+(void)setTargeting:(NSInteger)age gender:(MTGGender)gender latitude:(NSString *)latitude longitude:(NSString *)longitude pay:(MTGUserPayType)pay {
    MTGUserInfo *user = [[MTGUserInfo alloc]init];
    
    user.age = age;
    user.gender = gender;
    user.latitude = latitude;
    user.longitude = longitude;
    user.pay = pay;
    
    [[MTGSDK sharedInstance] setUserInfo:user];
}

+(BOOL)isMute {
    return mute;
}

+(void)setMute:(BOOL)muteStatus {
    mute = muteStatus;
}

@end
