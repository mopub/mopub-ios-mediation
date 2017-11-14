//
//  MoPub.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MoPub.h"
#import "MPConstants.h"
#import "MPCoreInstanceProvider.h"
#import "MPGeolocationProvider.h"
#import "MPLogging.h"
#import "MPRewardedVideo.h"
#import "MPRewardedVideoCustomEvent+Caching.h"
#import "MPIdentityProvider.h"
#import "MPWebView.h"
#import "MOPUBExperimentProvider.h"

@interface MoPub ()

@property (nonatomic, strong) NSArray *globalMediationSettings;

@end

@implementation MoPub

+ (MoPub *)sharedInstance
{
    static MoPub *sharedInstance = nil;
    static dispatch_once_t initOnceToken;
    dispatch_once(&initOnceToken, ^{
        sharedInstance = [[MoPub alloc] init];
    });
    return sharedInstance;
}

- (void)setLocationUpdatesEnabled:(BOOL)locationUpdatesEnabled
{
    [[[MPCoreInstanceProvider sharedProvider] sharedMPGeolocationProvider] setLocationUpdatesEnabled:locationUpdatesEnabled];
}

- (BOOL)locationUpdatesEnabled
{
    return [[MPCoreInstanceProvider sharedProvider] sharedMPGeolocationProvider].locationUpdatesEnabled;
}

- (void)setFrequencyCappingIdUsageEnabled:(BOOL)frequencyCappingIdUsageEnabled
{
    [MPIdentityProvider setFrequencyCappingIdUsageEnabled:frequencyCappingIdUsageEnabled];
}

- (void)setForceWKWebView:(BOOL)forceWKWebView
{
    [MPWebView forceWKWebView:forceWKWebView];
}

- (BOOL)forceWKWebView
{
    return [MPWebView isForceWKWebView];
}

- (void)setLogLevel:(MPLogLevel)level
{
    MPLogSetLevel(level);
}

- (MPLogLevel)logLevel
{
    return MPLogGetLevel();
}

- (void)setClickthroughDisplayAgentType:(MOPUBDisplayAgentType)displayAgentType
{
    [MOPUBExperimentProvider setDisplayAgentType:displayAgentType];
}

- (BOOL)frequencyCappingIdUsageEnabled
{
    return [MPIdentityProvider frequencyCappingIdUsageEnabled];
}

- (void)start
{
}

// Keep -version and -bundleIdentifier methods around for Fabric backwards compatibility.
- (NSString *)version
{
    return MP_SDK_VERSION;
}

- (NSString *)bundleIdentifier
{
    return MP_BUNDLE_IDENTIFIER;
}

- (void)initializeRewardedVideoWithGlobalMediationSettings:(NSArray *)globalMediationSettings delegate:(id<MPRewardedVideoDelegate>)delegate
{
    NSArray * allCachedNetworks = [MPRewardedVideoCustomEvent allCachedNetworks];
    [self initializeRewardedVideoWithGlobalMediationSettings:globalMediationSettings delegate:delegate networkInitializationOrder:allCachedNetworks];
}

- (void)initializeRewardedVideoWithGlobalMediationSettings:(NSArray *)globalMediationSettings
                                                  delegate:(id<MPRewardedVideoDelegate>)delegate
                                networkInitializationOrder:(NSArray<NSString *> *)order
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    // initializeWithDelegate: is a known private initialization method on MPRewardedVideo. So we forward the initialization call to that class.
    [MPRewardedVideo performSelector:@selector(initializeWithDelegate:) withObject:delegate];
#pragma clang diagnostic pop
    [MPRewardedVideo initializeWithOrder:order];
    self.globalMediationSettings = globalMediationSettings;
}

- (id<MPMediationSettingsProtocol>)globalMediationSettingsForClass:(Class)aClass
{
    NSArray *mediationSettingsCollection = self.globalMediationSettings;

    for (id<MPMediationSettingsProtocol> settings in mediationSettingsCollection) {
        if ([settings isKindOfClass:aClass]) {
            return settings;
        }
    }

    return nil;
}

- (void)disableViewability:(MPViewabilityOption)vendors
{
    [MPViewabilityTracker disableViewability:vendors];
}

@end
