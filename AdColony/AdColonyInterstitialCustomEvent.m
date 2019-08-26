//
//  AdColonyInterstitialCustomEvent.m
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#import <AdColony/AdColony.h>
#import "AdColonyAdapterConfiguration.h"
#import "AdColonyInterstitialCustomEvent.h"
#import "AdColonyController.h"
#import "AdColonyAdapterUtility.h"
#if __has_include("MoPub.h")
    #import "MPLogging.h"
#endif

@interface AdColonyInterstitialCustomEvent ()

@property (nonatomic, retain) AdColonyInterstitial *ad;
@property (nonatomic, copy) NSString *zoneId;

@end

@implementation AdColonyInterstitialCustomEvent

#pragma mark - MPInterstitialCustomEvent Subclass Methods

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info {
    NSString *appId = info[@"appId"];
    NSArray *allZoneIds = info[@"allZoneIds"];
    NSError *error = [AdColonyAdapterUtility validateAppId:appId andZoneIds:allZoneIds];
    if (error) {
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
        return;
    }
    
    self.zoneId = info[@"zoneId"];
    if (self.zoneId.length == 0) {
        self.zoneId = allZoneIds[0];
    }
    
    NSString *userId = [info objectForKey:@"userId"];
    
    // Cache the initialization parameters
    [AdColonyAdapterConfiguration updateInitializationParameters:info];
    
    [AdColonyController initializeAdColonyCustomEventWithAppId:appId allZoneIds:allZoneIds userId:userId callback:^(NSError *error){
        __weak AdColonyInterstitialCustomEvent *weakSelf = self;
        [AdColony requestInterstitialInZone:[self getAdNetworkId] options:nil success:^(AdColonyInterstitial * _Nonnull ad) {
            weakSelf.ad = ad;
            
            MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getAdNetworkId]);

            [ad setOpen:^{
                [weakSelf.delegate interstitialCustomEventDidAppear:weakSelf];
                
                MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
                MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
            }];
            [ad setClose:^{
                MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
                [weakSelf.delegate interstitialCustomEventWillDisappear:weakSelf];
                
                MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
                [weakSelf.delegate interstitialCustomEventDidDisappear:weakSelf];
            }];
            [ad setExpire:^{
                [weakSelf.delegate interstitialCustomEventDidExpire:weakSelf];
            }];
            [ad setLeftApplication:^{
                [weakSelf.delegate interstitialCustomEventWillLeaveApplication:weakSelf];
            }];
            [ad setClick:^{
                [weakSelf.delegate interstitialCustomEventDidReceiveTapEvent:weakSelf];
                MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
            }];
            
            [weakSelf.delegate interstitialCustomEvent:weakSelf didLoadAd:(id)ad];
            MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
        } failure:^(AdColonyAdRequestError * _Nonnull error) {
            weakSelf.ad = nil;
            [weakSelf.delegate interstitialCustomEvent:weakSelf didFailToLoadAdWithError:error];
            
            MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        }];
    }];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController {
    
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    
    if (self.ad) {
        if ([self.ad showWithPresentingViewController:rootViewController]) {
            [self.delegate interstitialCustomEventWillAppear:self];
            
            MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
        } else {
            NSError *error = [AdColonyAdapterUtility createErrorWith:@"Failed to show AdColony video"
                                         andReason:@"Unknown Error"
                                     andSuggestion:@""];
            MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
            
            [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
        }
    } else {
        NSError *error = [AdColonyAdapterUtility createErrorWith:@"Failed to show AdColony video"
                                     andReason:@"ad is not available"
                                 andSuggestion:@""];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    }
}

- (NSString *) getAdNetworkId {
    return self.zoneId;
}

@end
