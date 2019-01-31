//
//  AdColonyInterstitialCustomEvent.m
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#import <AdColony/AdColony.h>
#import "AdColonyAdapterConfiguration.h"
#import "AdColonyInterstitialCustomEvent.h"
#if __has_include("MoPub.h")
    #import "MPLogging.h"
#endif
#import "AdColonyController.h"

@interface AdColonyInterstitialCustomEvent ()

@property (nonatomic, retain) AdColonyInterstitial *ad;
@property (nonatomic, copy) NSString *zoneId;

@end

@implementation AdColonyInterstitialCustomEvent

#pragma mark - MPInterstitialCustomEvent Subclass Methods

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info {

    NSString *appId = [info objectForKey:@"appId"];
    if (appId == nil) {
        NSError *error = [self createErrorWith:@"AdColony adapter failed to requestInterstitial"
                                     andReason:@"Invalid setup"
                                 andSuggestion:@"Use the appId parameter when configuring your network in the MoPub website."];
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);

        return;
    }
    
    NSArray *allZoneIds = [info objectForKey:@"allZoneIds"];
    if (allZoneIds.count == 0) {
        NSError *error = [self createErrorWith:@"AdColony adapter failed to requestInterstitial"
                                     andReason:@"Invalid setup"
                                 andSuggestion:@"Use the allZoneIds parameter when configuring your network in the MoPub website."];
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);

        return;
    }
    
    self.zoneId = [info objectForKey:@"zoneId"];
    if (self.zoneId == nil) {
        self.zoneId = allZoneIds[0];
    }
    
    NSString *userId = [info objectForKey:@"userId"];
    
    // Cache the initialization parameters
    [AdColonyAdapterConfiguration updateInitializationParameters:info];
    
    [AdColonyController initializeAdColonyCustomEventWithAppId:appId allZoneIds:allZoneIds userId:userId callback:^{
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
            NSError *error = [self createErrorWith:@"Failed to show AdColony video"
                                     andReason:@"Unknown Error"
                                 andSuggestion:@""];
            MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
            
            [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
        }
    } else {
        NSError *error = [self createErrorWith:@"Failed to show AdColony video"
                                     andReason:@"ad is not available"
                                 andSuggestion:@""];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    }
}

- (NSString *) getAdNetworkId {
    return self.zoneId;
}

- (NSError *)createErrorWith:(NSString *)description andReason:(NSString *)reaason andSuggestion:(NSString *)suggestion {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(description, nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(reaason, nil),
                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(suggestion, nil)
                               };
    
    return [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:userInfo];
}

@end
