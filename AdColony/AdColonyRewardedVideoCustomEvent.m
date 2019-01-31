//
//  AdColonyRewardedVideoCustomEvent.m
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#import <AdColony/AdColony.h>
#import "AdColonyAdapterConfiguration.h"
#import "AdColonyRewardedVideoCustomEvent.h"
#import "AdColonyInstanceMediationSettings.h"
#import "AdColonyController.h"
#if __has_include("MoPub.h")
    #import "MoPub.h"
    #import "MPLogging.h"
    #import "MPRewardedVideoReward.h"
#endif

#define ADCOLONY_INITIALIZATION_TIMEOUT dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC)

@interface AdColonyRewardedVideoCustomEvent ()

@property (nonatomic, retain) AdColonyInterstitial *ad;
@property (nonatomic, retain) AdColonyZone *zone;
@property (nonatomic, strong) NSString *zoneId;

@end

@implementation AdColonyRewardedVideoCustomEvent

- (void)initializeSdkWithParameters:(NSDictionary *)parameters {
    // Do not wait for the callback since this method may be run on app
    // launch on the main thread.
    [self initializeSdkWithParameters:parameters callback:^{
        MPLogInfo(@"AdColony SDK initialization complete");
    }];
}

- (void)initializeSdkWithParameters:(NSDictionary *)parameters callback:(void(^)(void))completionCallback {
    NSString *appId = [parameters objectForKey:@"appId"];
    if (appId == nil) {
        NSError *error = [self createErrorWith:@"AdColony adapter failed to load ad"
                                     andReason:@"Invalid setup"
                                 andSuggestion:@"Use the appId parameter when configuring your network in the MoPub website."];
        
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);

        return;
    }
    
    NSArray *allZoneIds = [parameters objectForKey:@"allZoneIds"];
    if (allZoneIds.count == 0) {
        
        NSError *error = [self createErrorWith:@"AdColony adapter failed to load ad"
                                     andReason:@"Invalid setup"
                                 andSuggestion:@"Use the allZoneIds parameter when configuring your network in the MoPub website."];
        
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);

        return;
    }
    
    NSString *userId = [parameters objectForKey:@"userId"];
    
    [AdColonyController initializeAdColonyCustomEventWithAppId:appId allZoneIds:allZoneIds userId:userId callback:completionCallback];
}

- (NSError *)createErrorWith:(NSString *)description andReason:(NSString *)reaason andSuggestion:(NSString *)suggestion {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(description, nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(reaason, nil),
                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(suggestion, nil)
                               };
    
    return [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:userInfo];
}

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info {
    NSArray *allZoneIds = [info objectForKey:@"allZoneIds"];
    if (allZoneIds.count == 0) {
        
        NSError *error = [self createErrorWith:@"AdColony adapter failed to requestRewardedVideo"
                                     andReason:@"Invalid setup"
                                 andSuggestion:@"Use the allZoneIds parameter when configuring your network in the MoPub website."];
        
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);

        return;
    }
    
    self.zoneId = [info objectForKey:@"zoneId"];
    if (self.zoneId == nil) {
        self.zoneId = allZoneIds[0];
    }
    
    // Cache the initialization parameters
    [AdColonyAdapterConfiguration updateInitializationParameters:info];
    
    // Update the user ID
    NSString *customerId = [self.delegate customerIdForRewardedVideoCustomEvent:self];
    NSMutableDictionary *newInfo = [NSMutableDictionary dictionaryWithDictionary:info];
    newInfo[@"userId"] = customerId;
    
    [self initializeSdkWithParameters:newInfo callback:^{
        
        AdColonyInstanceMediationSettings *settings = [self.delegate instanceMediationSettingsForClass:[AdColonyInstanceMediationSettings class]];
        BOOL showPrePopup = (settings) ? settings.showPrePopup : NO;
        BOOL showPostPopup = (settings) ? settings.showPostPopup : NO;
        
        AdColonyAdOptions *options = [AdColonyAdOptions new];
        options.showPrePopup = showPrePopup;
        options.showPostPopup = showPostPopup;
        
        __weak AdColonyRewardedVideoCustomEvent *weakSelf = self;
        
        [AdColony requestInterstitialInZone:[self getAdNetworkId] options:options success:^(AdColonyInterstitial * _Nonnull ad) {
            
            MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getAdNetworkId]);
            
            weakSelf.zone = [AdColony zoneForID:[self getAdNetworkId]];
            weakSelf.ad = ad;
            
            [ad setOpen:^{
                [weakSelf.delegate rewardedVideoWillAppearForCustomEvent:weakSelf];
                MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);

                [weakSelf.delegate rewardedVideoDidAppearForCustomEvent:weakSelf];
                
                MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
                MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
            }];
            [ad setClose:^{
                MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
                [weakSelf.delegate rewardedVideoWillDisappearForCustomEvent:weakSelf];

                MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
                [weakSelf.delegate rewardedVideoDidDisappearForCustomEvent:weakSelf];
            }];
            [ad setExpire:^{
                [weakSelf.delegate rewardedVideoDidExpireForCustomEvent:weakSelf];
            }];
            [ad setLeftApplication:^{
                [weakSelf.delegate rewardedVideoWillLeaveApplicationForCustomEvent:weakSelf];
            }];
            [ad setClick:^{
                [weakSelf.delegate rewardedVideoDidReceiveTapEventForCustomEvent:weakSelf];
                MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
            }];
            
            [weakSelf.zone setReward:^(BOOL success, NSString * _Nonnull name, int amount) {
                if (!success) {
                    MPLogInfo(@"AdColony reward failure in zone %@", [self getAdNetworkId]);
                    return;
                }
                [weakSelf.delegate rewardedVideoShouldRewardUserForCustomEvent:weakSelf reward:[[MPRewardedVideoReward alloc] initWithCurrencyType:name amount:@(amount)]];
            }];
            
            [weakSelf.delegate rewardedVideoDidLoadAdForCustomEvent:weakSelf];
            MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
        } failure:^(AdColonyAdRequestError * _Nonnull error) {
            weakSelf.ad = nil;
            [weakSelf.delegate rewardedVideoDidFailToLoadAdForCustomEvent:weakSelf error:error];
            MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        }];
        
    }];
}

- (BOOL)hasAdAvailable {
    return self.ad != nil;
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController {
    
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);

    if (self.ad) {
        if (![self.ad showWithPresentingViewController:viewController]) {
            NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorUnknown userInfo:nil];
            
            MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
            [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
        }
    } else {
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:nil];

        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
    }
}

- (NSString *) getAdNetworkId {
    return self.zoneId;
}

@end
