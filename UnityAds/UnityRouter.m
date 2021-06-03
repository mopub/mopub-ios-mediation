//
//  UnityRouter.m
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#import "UnityRouter.h"
#import "UnityAdsInstanceMediationSettings.h"
#import "UnityAdsAdapterConfiguration.h"

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
    #import <MoPubSDK/MoPub.h>
#else
    #import "MoPub.h"
#endif

@interface UnityAdsAdapterInitializationDelegate : NSObject<UnityAdsInitializationDelegate>
@property(nonatomic, copy) void (^ initializationCompleteBlock)(void);
@property(nonatomic, copy) void (^ initializationFailedBlock)(int error, NSString *message);
@end

@implementation UnityAdsAdapterInitializationDelegate
- (void)initializationComplete {
    if (self.initializationCompleteBlock) {
        self.initializationCompleteBlock();
    }
}

- (void)initializationFailed:(UnityAdsInitializationError)error withMessage:(nonnull NSString *)message {
    if (self.initializationFailedBlock) {
        self.initializationFailedBlock(kUnityAdsErrorNotInitialized,message);
    }
}

@end

@implementation UnityRouter

- (id) init {
    self = [super init];

    return self;
}

+ (UnityRouter *)sharedRouter
{
    static UnityRouter * sharedRouter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedRouter = [[UnityRouter alloc] init];
    });
    return sharedRouter;
}

- (void)initializeWithGameId:(NSString *)gameId withCompletionHandler:(void (^)(NSError *))complete {
    [self setIfUnityAdsCollectsPersonalInfo];
    static dispatch_once_t unityInitToken;
    dispatch_once(&unityInitToken, ^{
        UADSMediationMetaData *mediationMetaData = [[UADSMediationMetaData alloc] init];
        [mediationMetaData setName:@"MoPub"];
        [mediationMetaData setVersion:[[MoPub sharedInstance] version]];
        [mediationMetaData set:@"adapter_version"  value:ADAPTER_VERSION];
        [mediationMetaData commit];
        
        
        UnityAdsAdapterInitializationDelegate *initDelegate = [[UnityAdsAdapterInitializationDelegate alloc] init];
        
        initDelegate.initializationCompleteBlock = ^{
            if (complete != nil) {
                complete(nil);
            }
        };
        initDelegate.initializationFailedBlock = ^(int error, NSString *message) {
            if (complete != nil) {
                NSError *err = [NSError errorWithCode:(MOPUBErrorSDKNotInitialized) localizedDescription:message];
                complete(err);
            }
        };
        
        [UnityAds initialize:gameId testMode:false enablePerPlacementLoad:true initializationDelegate:initDelegate];
    });
}

- (void) setIfUnityAdsCollectsPersonalInfo
{
    // Collect and pass the user's consent/non-consent from MoPub to the Unity Ads SDK
    UADSMetaData *gdprConsentMetaData = [[UADSMetaData alloc] init];
    
    if ([[MoPub sharedInstance] isGDPRApplicable] == MPBoolYes){
        if ([[MoPub sharedInstance] allowLegitimateInterest] == YES){
            if ([[MoPub sharedInstance] currentConsentStatus] == MPConsentStatusDenied
                || [[MoPub sharedInstance] currentConsentStatus] == MPConsentStatusDoNotTrack) {
                
                [gdprConsentMetaData set:@"gdpr.consent" value:@NO];
            }
            else {
                [gdprConsentMetaData set:@"gdpr.consent" value:@YES];
            }
        } else {
            if ([[MoPub sharedInstance] canCollectPersonalInfo] == YES) {
                [gdprConsentMetaData set:@"gdpr.consent" value:@YES];
            }
            else {
                [gdprConsentMetaData set:@"gdpr.consent" value:@NO];
            }
        }
        [gdprConsentMetaData commit];
    }
}

@end
