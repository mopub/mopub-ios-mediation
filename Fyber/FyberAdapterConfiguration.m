#import "FyberAdapterConfiguration.h"

#import <IASDKCore/IASDKCore.h>
#import "MPLogging.h"

@implementation FyberAdapterConfiguration

#pragma mark - Consts

NSString * const kIASDKMopubAdapterAppIDKey = @"appID";
NSString * const kIASDKMoPubAdapterErrorDomain = @"com.mopub.IASDKAdapter";
NSNotificationName _Nonnull kIASDKInitCompleteNotification = @"kIASDKInitCompleteNotification";

#pragma mark - Static members

static dispatch_queue_t sIASDKInitSyncQueue = nil;

+ (void)initialize {
    static BOOL initialised = NO;
    
    if ((self == FyberAdapterConfiguration.self) && !initialised) { // invoke only once per application runtime (and not in subclasses);
        initialised = YES;
        
        sIASDKInitSyncQueue = dispatch_queue_create("com.Fyber.SDK.Marketplace.mediation.mopub.init", DISPATCH_QUEUE_SERIAL);
    }
}

#pragma mark - MPAdapterConfiguration

- (NSString *)adapterVersion {
    return @"7.8.6.0";
}

- (NSString *)biddingToken {
    return nil;
}

- (NSString *)moPubNetworkName {
    return @"fyber";
}

- (NSString *)networkSdkVersion {
    return IASDKCore.sharedInstance.version;
}

#pragma mark - Overrides

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> *)configuration complete:(void(^)(NSError *))complete {
    NSString *appID = configuration[kIASDKMopubAdapterAppIDKey];
    
    if ([appID isEqualToString:IASDKCore.sharedInstance.appID]) {
        if (complete) {
            complete(nil);
        }
    } else {
        dispatch_async(sIASDKInitSyncQueue, ^{
            [IASDKCore.sharedInstance initWithAppID:appID completionBlock:^(BOOL success, NSError * _Nullable error) {
                if (success || (error.code == IASDKCoreInitErrorTypeFailedToDownloadMandatoryData)) {
                    error = nil;
                    [NSNotificationCenter.defaultCenter postNotificationName:kIASDKInitCompleteNotification object:self];
                }
                
                if (complete) {
                    complete(error);
                }
                
                if (error) {
                    NSInteger errorCode = IASDKMopubAdapterErrorSDKInit;
                    
                    if (!appID.length) {
                        errorCode = IASDKMopubAdapterErrorMissingAppID;
                    }
                    
                    error = [NSError errorWithDomain:kIASDKMoPubAdapterErrorDomain code:errorCode userInfo:error.userInfo];
                    MPLogEvent([MPLogEvent error:error message:nil]);
                } else {
                    [self.class setCachedInitializationParameters:configuration];
                }
            } completionQueue:nil];
        });
    }
}

#pragma mark - static API

+ (void)configureIASDKWithInfo:(NSDictionary *)info {
    NSString *receivedAppID = info[kIASDKMopubAdapterAppIDKey];
    
    dispatch_async(sIASDKInitSyncQueue, ^{
        if (receivedAppID && [receivedAppID isKindOfClass:NSString.class] && receivedAppID.length && ![receivedAppID isEqualToString:IASDKCore.sharedInstance.appID]) {
            [IASDKCore.sharedInstance initWithAppID:receivedAppID completionBlock:^(BOOL success, NSError * _Nullable error) {
                [NSNotificationCenter.defaultCenter postNotificationName:kIASDKInitCompleteNotification object:self];
            } completionQueue:nil];
        }
    });
}

+ (void)collectConsentStatusFromMoPub {
    
    if (MoPub.sharedInstance.isGDPRApplicable == MPBoolYes) {
        if (MoPub.sharedInstance.allowLegitimateInterest) {
            if ((MoPub.sharedInstance.currentConsentStatus == MPConsentStatusDenied) ||
                (MoPub.sharedInstance.currentConsentStatus == MPConsentStatusDoNotTrack) ||
                (MoPub.sharedInstance.currentConsentStatus == MPConsentStatusPotentialWhitelist)) {
                IASDKCore.sharedInstance.GDPRConsent = IAGDPRConsentTypeDenied;
            } else {
                IASDKCore.sharedInstance.GDPRConsent = IAGDPRConsentTypeGiven;
            }
        } else {
            const BOOL canCollectPersonalInfo = MoPub.sharedInstance.canCollectPersonalInfo;

            IASDKCore.sharedInstance.GDPRConsent = (canCollectPersonalInfo) ? IAGDPRConsentTypeGiven : IAGDPRConsentTypeDenied;
        }
    }
}

@end
