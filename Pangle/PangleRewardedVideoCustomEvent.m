//
//  PangleRewardedVideoCustomEvent.m
//  mopub_adaptor
//
//  Created by Pangle on 2018/9/18.
//  Copyright © 2018年 Pangle. All rights reserved.
//

#import "PangleRewardedVideoCustomEvent.h"
#import <BUAdSDK/BUAdSDK.h>
#if __has_include("MoPub.h")
#import "MPLogging.h"
#import "MPRewardedVideoError.h"
#import "MPRewardedVideoReward.h"
#endif
#import "PangleAdapterConfiguration.h"

@interface PangleRewardedVideoCustomEvent ()<BURewardedVideoAdDelegate>
@property (nonatomic, strong) BURewardedVideoAd *rewardVideoAd;
@end

@implementation PangleRewardedVideoCustomEvent

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    BOOL hasAdMarkup = adMarkup.length > 0;
    NSString * appId = [info objectForKey:@"app_id"];
    if (appId != nil){
        [PangleAdapterConfiguration updateInitializationParameters:info];
    }
    NSString *ritStr;
    ritStr = [info objectForKey:@"ad_placement_id"];
    if (ritStr == nil) {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:@{NSLocalizedDescriptionKey: @"Invalid Pangle placement ID"}];
        [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
        return;
    }
    
    BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
    model.userId = @"123";
    
    BURewardedVideoAd *RewardedVideoAd = [[BURewardedVideoAd alloc] initWithSlotID:ritStr rewardedVideoModel:model];
    RewardedVideoAd.delegate = self;
    self.rewardVideoAd = RewardedVideoAd;
    if (hasAdMarkup) {
        [RewardedVideoAd setMopubAdMarkUp:adMarkup];
    }else{
        [RewardedVideoAd loadAdData];
    }
}

- (BOOL)hasAdAvailable {
    return self.rewardVideoAd.isAdValid;
}
    
- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController {
    [self.rewardVideoAd showAdFromRootViewController:viewController];
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

#pragma mark BURewardedVideoAdDelegate
- (void)rewardedVideoAdDidLoad:(BURewardedVideoAd *)rewardedVideoAd {
    [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
}

- (void)rewardedVideoAdVideoDidLoad:(BURewardedVideoAd *)rewardedVideoAd {
}

- (void)rewardedVideoAd:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
}

- (void)rewardedVideoAdDidVisible:(BURewardedVideoAd *)rewardedVideoAd {
    [self.delegate rewardedVideoWillAppearForCustomEvent:self];
    [self.delegate trackImpression];
    [self.delegate rewardedVideoDidAppearForCustomEvent:self];
}

- (void)rewardedVideoAdDidClose:(BURewardedVideoAd *)rewardedVideoAd {
    [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
}

- (void)rewardedVideoAdDidClick:(BURewardedVideoAd *)rewardedVideoAd {
    [self.delegate rewardedVideoDidReceiveTapEventForCustomEvent:self];
    [self.delegate trackClick];
}

- (void)rewardedVideoAdDidPlayFinish:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    if(error != nil)
        [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
}

- (void)rewardedVideoAdServerRewardDidSucceed:(BURewardedVideoAd *)rewardedVideoAd verify:(BOOL)verify {
    if (verify) {
        MPRewardedVideoReward *reward = [[MPRewardedVideoReward alloc] initWithCurrencyType:self.rewardVideoAd.rewardedVideoModel.rewardName amount:[NSNumber numberWithInteger:self.rewardVideoAd.rewardedVideoModel.rewardAmount]];
        [self.delegate rewardedVideoShouldRewardUserForCustomEvent:self reward:reward];
    }
}

- (void)rewardedVideoAdServerRewardDidFail:(BURewardedVideoAd *)rewardedVideoAd {
}

@end
