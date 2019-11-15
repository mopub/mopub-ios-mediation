//
//  AdColonyController.m
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AdColony/AdColony.h>
#import "AdColonyController.h"
#import "AdColonyGlobalMediationSettings.h"
#import "AdColonyAdapterConfiguration.h"
#import "AdColonyAdapterUtility.h"
#if __has_include("MoPub.h")
    #import "MoPub.h"
    #import "MPRewardedVideo.h"
#endif

@interface AdColonyController()

@property (atomic, assign, readwrite) InitState initState;
@property (atomic, strong) NSSet *currentAllZoneIds;
@property (atomic, assign) BOOL testModeEnabled;

@end

@implementation AdColonyController

+ (void)initializeAdColonyCustomEventWithAppId:(NSString *)appId allZoneIds:(NSArray *)allZoneIds userId:(NSString *)userId callback:(void(^)(NSError *error))callback {
    AdColonyController *instance = [AdColonyController sharedInstance];

    @synchronized (instance) {
        NSSet * allZoneIdsSet = [NSSet setWithArray:allZoneIds];
        BOOL zoneIdsSame = [instance.currentAllZoneIds isEqualToSet:allZoneIdsSet];

        if (instance.initState == INIT_STATE_INITIALIZED && zoneIdsSame) {
            if (callback) {
                callback(nil);
            }
        } else {
            if (instance.initState != INIT_STATE_INITIALIZING) {
                instance.initState = INIT_STATE_INITIALIZING;

                AdColonyGlobalMediationSettings *settings = [[MoPub sharedInstance] globalMediationSettingsForClass:[AdColonyGlobalMediationSettings class]];
                AdColonyAdapterConfiguration *adapterConfiguration = [[AdColonyAdapterConfiguration alloc] init];
                AdColonyAppOptions *appOptions = [AdColonyAppOptions new];
                [appOptions setMediationNetwork:ADCMoPub];
                [appOptions setMediationNetworkVersion:adapterConfiguration.adapterVersion];
                if (userId && userId.length > 0) {
                    appOptions.userID = userId;
                } else if (settings && settings.customId.length > 0) {
                    appOptions.userID = settings.customId;
                }

                instance.currentAllZoneIds = allZoneIdsSet;
                appOptions.testMode = instance.testModeEnabled;

                MoPub *moPub = [MoPub sharedInstance];
                if ([moPub isGDPRApplicable] == MPBoolYes) {
                    appOptions.gdprRequired = YES;
                    if ([moPub allowLegitimateInterest] == YES) {
                        if ([moPub currentConsentStatus] == MPConsentStatusDenied ||
                            [moPub currentConsentStatus] == MPConsentStatusDoNotTrack) {
                            appOptions.gdprConsentString = @"0";
                        } else {
                            appOptions.gdprConsentString = @"1";
                        }
                    }else if ([moPub canCollectPersonalInfo]) {
                        appOptions.gdprConsentString = @"1";
                    } else {
                        appOptions.gdprConsentString = @"0";
                    }
                }

                [AdColony configureWithAppID:appId zoneIDs:allZoneIds options:appOptions completion:^(NSArray<AdColonyZone *> *zones) {
                    @synchronized (instance) {
                        instance.initState = INIT_STATE_INITIALIZED;
                    }
                    
                    if (callback != nil) {
                        if (zones.count == 0) {
                            NSError *error = [AdColonyAdapterUtility createErrorWith:@"AdColony's initialization failed."
                                andReason:@"Failed to get zones list"
                            andSuggestion:@"Ensure values of 'appId' and 'zoneId' fields on the MoPub dashboard are valid."];
                            callback(error);
                        }else{
                            callback(nil);
                        }
                    }
                }];
            }
        }
    }
}

+ (void)enableClientSideTestMode {
    AdColonyController *instance = [AdColonyController sharedInstance];

    @synchronized (instance) {
        instance.testModeEnabled = YES;

        if (instance.initState == INIT_STATE_INITIALIZED || instance.initState == INIT_STATE_INITIALIZING) {
            AdColonyAppOptions *options = [AdColony getAppOptions];
            options.testMode = YES;
            [AdColony setAppOptions:options];
        }
    }
}

+ (void)disableClientSideTestMode {
    AdColonyController *instance = [AdColonyController sharedInstance];

    @synchronized (instance) {
        instance.testModeEnabled = NO;

        if (instance.initState == INIT_STATE_INITIALIZED || instance.initState == INIT_STATE_INITIALIZING) {
            AdColonyAppOptions *options = [AdColony getAppOptions];
            options.testMode = NO;
            [AdColony setAppOptions:options];
        }
    }
}

+ (AdColonyController *)sharedInstance {
    static dispatch_once_t onceToken;
    static AdColonyController *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [AdColonyController new];
    });
    return instance;
}

- (id)init {
    if (self = [super init]) {
        _initState = INIT_STATE_UNKNOWN;
    }
    return self;
}

@end
