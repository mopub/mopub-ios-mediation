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

NSString *const kMintegralErrorDomain = @"com.mintegral.iossdk.mopub";

@implementation MintegralAdapterConfiguration

#pragma mark - MPAdapterConfiguration

- (NSString *)adapterVersion {
    return MintegralAdapterVersion;
}

- (NSString *)biddingToken {
    return [MTGBiddingSDK buyerUID];
}

- (NSString *)moPubNetworkName {
    return @"Mintegral";
}

- (NSString *)networkSdkVersion {
    return MTGSDKVersion;
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *,id> *)configuration complete:(void (^)(NSError * _Nullable))complete {
    MPLogInfo(@"initializeNetworkWithConfiguration for Mintegral");
    
    NSString *appId = [configuration objectForKey:@"appId"];
    NSString *appKey = [configuration objectForKey:@"appKey"];
    
    NSString *errorMsg = nil;
    if (!appId) errorMsg = @"Invalid Mintegral appId";
    if (!appKey) errorMsg = @"Invalid Mintegral appKey";
    
    if (errorMsg) {
        NSError *error = [NSError errorWithDomain:kMintegralErrorDomain code:MPErrorNetworkConnectionFailed userInfo:@{NSLocalizedDescriptionKey : errorMsg}];

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
        [MintegralAdapterConfiguration setGDPRInfo:info];
        [[MTGSDK sharedInstance] setAppID:appId ApiKey:appKey];
        [MintegralAdapterConfiguration sdkInitialized];
    }
}

+(BOOL)isSDKInitialized {
    return mintegralSDKInitialized;
}

+(void)sdkInitialized {
#ifdef DEBUG
    if (DEBUG) {
        MPLogInfo(@"The version of current Mintegral Adapter is: %@", MintegralAdapterVersion);
    }
#endif
    
    Class class = NSClassFromString(@"MTGSDK");
    SEL selector = NSSelectorFromString(@"setChannelFlag:");
    NSString *pluginNumber = @"Y+H6DFttYrPQYcIA+F2F+F5/Hv==";
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([class respondsToSelector:selector]) {
        [class performSelector:selector withObject:pluginNumber];
    }
#pragma clang diagnostic pop
    mintegralSDKInitialized = YES;
    MPLogInfo(@"Mintegral sdkInitialized");
}

+(void)setGDPRInfo:(NSDictionary *)info {
    if ([[MoPub sharedInstance] canCollectPersonalInfo])
    {
        [[MTGSDK sharedInstance] setConsentStatus:YES];
    } else {
        [[MTGSDK sharedInstance] setConsentStatus:NO];
    }
}

@end
