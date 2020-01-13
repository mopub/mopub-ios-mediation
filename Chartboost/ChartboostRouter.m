//
//  ChartboostRouter.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "ChartboostRouter.h"
#if __has_include("MoPub.h")
    #import "MPLogging.h"
    #import "MoPub.h"
#endif
#import "ChartboostAdapterConfiguration.h"

static NSString * const kChartboostAppIdKey        = @"appId";
static NSString * const kChartboostAppSignatureKey = @"appSignature";

@implementation ChartboostRouter

+ (CHBMediation *)mediation
{
    return [[CHBMediation alloc] initWithType:CBMediationMoPub
                               libraryVersion:MP_SDK_VERSION
                               adapterVersion:[ChartboostAdapterConfiguration adapterVersion]];
}

+ (void)setLoggingLevel:(MPBLogLevel)loggingLevel
{
    CBLoggingLevel chbLoggingLevel = [self chartboostLoggingLevelFromMopubLevel:loggingLevel];
    [Chartboost setLoggingLevel:chbLoggingLevel];
}

+ (CBLoggingLevel)chartboostLoggingLevelFromMopubLevel:(MPBLogLevel)logLevel
{
    switch (logLevel) {
        case MPBLogLevelDebug:
            return CBLoggingLevelVerbose;
        case MPBLogLevelInfo:
            return CBLoggingLevelInfo;
        case MPBLogLevelNone:
            return CBLoggingLevelOff;
    }
    return CBLoggingLevelOff;
}

+ (void)setDataUseConsentWithMopubConfiguration
{
    MoPub *mopub = [MoPub sharedInstance];
    if ([mopub isGDPRApplicable] == MPBoolYes) {
        if ([mopub allowLegitimateInterest]) {
            if ([mopub currentConsentStatus] == MPConsentStatusDenied || [mopub currentConsentStatus] == MPConsentStatusDoNotTrack) {
                [Chartboost setPIDataUseConsent:NoBehavioral];
            } else {
                [Chartboost setPIDataUseConsent:YesBehavioral];
            }
        } else {
            if ([mopub canCollectPersonalInfo]) {
                [Chartboost setPIDataUseConsent:YesBehavioral];
            } else {
                [Chartboost setPIDataUseConsent:NoBehavioral];
            }
        }
    }
}

+ (void)startWithParameters:(NSDictionary *)parameters completion:(void (^)(BOOL))completion
{
    NSString *appId = parameters[kChartboostAppIdKey];
    NSString *appSignature = parameters[kChartboostAppSignatureKey];
    
    if (appId.length == 0 || appSignature.length == 0) {
        NSError *error = [NSError errorWithCode:MOPUBErrorAdapterInvalid
                           localizedDescription:@"Failed to initialize Chartboost SDK: missing appId or appSignature. Make sure you have a valid appId and appSignature entered on the MoPub dashboard."];
        MPLogEvent([MPLogEvent error:error message:nil]);
        completion(NO);
        return;
    }
    
    [ChartboostAdapterConfiguration updateInitializationParameters:parameters];
    [Chartboost startWithAppId:appId appSignature:appSignature completion:completion];
}

@end
