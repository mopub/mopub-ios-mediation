//
// Created by Ross Rothenstine on 11/5/18.
// Copyright (c) 2018 MoPub. All rights reserved.
//

#import "UnityAdsBannerCustomEvent.h"
#import "MPUnityRouter.h"
#if __has_include("MoPub.h")
    #import "MPLogging.h"
#endif

static NSString *const kMPUnityRewardedVideoGameId = @"gameId";
static NSString *const kUnityAdsOptionPlacementIdKey = @"placementId";
static NSString *const kUnityAdsOptionZoneIdKey = @"zoneId";

@interface UnityAdsBannerCustomEvent ()
@property (nonatomic) NSString* placementId;
@end

@implementation UnityAdsBannerCustomEvent

-(id)init {
    if (self = [super init]) {

    }
    return self;
}

-(void)dealloc {
    [UnityAdsBanner destroy];
}

-(void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info {
    NSString *gameId = info[kMPUnityRewardedVideoGameId];
    self.placementId = info[kUnityAdsOptionPlacementIdKey];
    if (self.placementId == nil) {
        self.placementId = info[kUnityAdsOptionZoneIdKey];
    }
    if (self.placementId == nil) {
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
    } else {
        [[MPUnityRouter sharedRouter] requestBannerAdWithGameId:gameId placementId:self.placementId delegate:self];
    }
}

#pragma mark - UnityAdsBannerDelegate

-(void)unityAdsBannerDidLoad:(NSString *)placementId view:(UIView *)view {
    MPLogInfo(@"Unity Banner did load for placement %@", placementId);
    [self.delegate bannerCustomEvent:self didLoadAd:view];
}

-(void)unityAdsBannerDidUnload:(NSString *)placementId {
    MPLogInfo(@"Unity Banner did unload for placement %@", placementId);
}
-(void)unityAdsBannerDidShow:(NSString *)placementId {
    MPLogInfo(@"Unity Banner did show for placement %@", placementId);
}
-(void)unityAdsBannerDidHide:(NSString *)placementId {
    MPLogInfo(@"Unity Banner did hide for placement %@", placementId);
}
-(void)unityAdsBannerDidClick:(NSString *)placementId {
    MPLogInfo(@"Unity Banner did click for placement %@", placementId);
    [self.delegate bannerCustomEventWillLeaveApplication:self];
}
-(void)unityAdsBannerDidError:(NSString *)message {
    MPLogInfo(@"Unity Banner did error with message: %@", message);
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
}

@end
