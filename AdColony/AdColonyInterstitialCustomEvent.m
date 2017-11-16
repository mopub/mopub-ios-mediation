//
//  AdColonyInterstitialCustomEvent.m
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#import <AdColony/AdColony.h>
#import "AdColonyInterstitialCustomEvent.h"
#import "MPLogging.h"
#import "AdColonyController.h"

@interface AdColonyInterstitialCustomEvent ()

@property (nonatomic, retain) AdColonyInterstitial *ad;

@end

@implementation AdColonyInterstitialCustomEvent

#pragma mark - MPInterstitialCustomEvent Subclass Methods

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info {
    NSString *appId = [info objectForKey:@"appId"];
    if (appId == nil) {
        MPLogError(@"Invalid setup. Use the appId parameter when configuring your network in the MoPub website.");
        return;
    }
    
    NSArray *allZoneIds = [info objectForKey:@"allZoneIds"];
    if (allZoneIds.count == 0) {
        MPLogError(@"Invalid setup. Use the allZoneIds parameter when configuring your network in the MoPub website.");
        return;
    }
    
    NSString *zoneId = [info objectForKey:@"zoneId"];
    if (zoneId == nil) {
        zoneId = allZoneIds[0];
    }
    
    NSString *userId = [info objectForKey:@"userId"];
    
    [AdColonyController initializeAdColonyCustomEventWithAppId:appId allZoneIds:allZoneIds userId:userId callback:^{
        __weak AdColonyInterstitialCustomEvent *weakSelf = self;
        [AdColony requestInterstitialInZone:zoneId options:nil success:^(AdColonyInterstitial * _Nonnull ad) {
            weakSelf.ad = ad;
            
            [ad setOpen:^{
                MPLogInfo(@"AdColony zone %@ started", zoneId);
                [weakSelf.delegate interstitialCustomEventDidAppear:weakSelf];
            }];
            [ad setClose:^{
                MPLogInfo(@"AdColony zone %@ finished", zoneId);
                [weakSelf.delegate interstitialCustomEventWillDisappear:weakSelf];
                [weakSelf.delegate interstitialCustomEventDidDisappear:weakSelf];
            }];
            [ad setExpire:^{
                MPLogInfo(@"AdColony zone %@ expired", zoneId);
                [weakSelf.delegate interstitialCustomEventDidExpire:weakSelf];
            }];
            [ad setLeftApplication:^{
                MPLogInfo(@"AdColony zone %@ click caused application transition", zoneId);
                [weakSelf.delegate interstitialCustomEventWillLeaveApplication:weakSelf];
            }];
            [ad setClick:^{
                MPLogInfo(@"AdColony zone %@ ad clicked", zoneId);
                [weakSelf.delegate interstitialCustomEventDidReceiveTapEvent:weakSelf];
            }];
            
            [weakSelf.delegate interstitialCustomEvent:weakSelf didLoadAd:(id)ad];
        } failure:^(AdColonyAdRequestError * _Nonnull error) {
            MPLogInfo(@"Failed to load AdColony video interstitial: %@", error);
            weakSelf.ad = nil;
            [weakSelf.delegate interstitialCustomEvent:weakSelf didFailToLoadAdWithError:error];
        }];
        
    }];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController {
    if (self.ad) {
        if ([self.ad showWithPresentingViewController:rootViewController]) {
            [self.delegate interstitialCustomEventWillAppear:self];
        } else {
            MPLogInfo(@"Failed to show AdColony video");
        }
    } else {
        MPLogInfo(@"Failed to show AdColony video, ad is not available");
    }
}

@end
