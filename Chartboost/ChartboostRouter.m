//
//  ChartboostRouter.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "ChartboostRouter.h"
#import "ChartboostAdapterConfiguration.h"

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

static NSString * const kChartboostAppIdKey        = @"appId";
static NSString * const kChartboostAppSignatureKey = @"appSignature";
static NSString * const kChartboostMinimumOSVersion = @"10.0";

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
                [Chartboost addDataUseConsent:[CHBGDPRDataUseConsent gdprConsent:CHBGDPRConsentNonBehavioral]];
            } else {
                [Chartboost addDataUseConsent:[CHBGDPRDataUseConsent gdprConsent:CHBGDPRConsentBehavioral]];
            }
        } else {
            if ([mopub canCollectPersonalInfo]) {
                [Chartboost addDataUseConsent:[CHBGDPRDataUseConsent gdprConsent:CHBGDPRConsentBehavioral]];
            } else {
                [Chartboost addDataUseConsent:[CHBGDPRDataUseConsent gdprConsent:CHBGDPRConsentNonBehavioral]];
            }
        }
    }
}

+ (void)startWithParameters:(NSDictionary *)parameters completion:(void (^)(BOOL))completion
{
    if (SYSTEM_VERSION_LESS_THAN(kChartboostMinimumOSVersion)) {
        NSString *errorDescription = [NSString stringWithFormat:@"Chartboost minimum supported OS version is iOS %@. Requested action is a no-op.", kChartboostMinimumOSVersion];
        NSError *error = [NSError errorWithCode:MOPUBErrorUnknown localizedDescription:errorDescription];
        MPLogEvent([MPLogEvent error:error message:nil]);
        completion(NO);
        return;
    }
    
    NSString *appId = parameters[kChartboostAppIdKey];
    NSString *appSignature = parameters[kChartboostAppSignatureKey];
    
    if (appId.length == 0) {
        NSError *error = [NSError errorWithCode:MOPUBErrorAdapterInvalid
                           localizedDescription:@"Failed to initialize Chartboost SDK: missing appId. Make sure you have a valid appId entered on the MoPub dashboard."];
        MPLogEvent([MPLogEvent error:error message:nil]);
        completion(NO);
        return;
    }
    
    if (appSignature.length == 0) {
           NSError *error = [NSError errorWithCode:MOPUBErrorAdapterInvalid
                              localizedDescription:@"Failed to initialize Chartboost SDK: missing appSignature. Make sure you have a valid appSignature entered on the MoPub dashboard."];
           MPLogEvent([MPLogEvent error:error message:nil]);
           completion(NO);
           return;
    }
       
    [ChartboostAdapterConfiguration updateInitializationParameters:parameters];
    //Patch for an internal issue of the Chartboost SDK, we will undo these changes with the next update of the Chartboost SDK 8.5.0
    [Chartboost startWithAppId:appId appSignature:appSignature completion: ^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(success);
        });
    }];
}

@end
