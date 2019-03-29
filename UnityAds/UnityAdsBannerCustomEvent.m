//
// Created by Ross Rothenstine on 11/5/18.
// Copyright (c) 2018 MoPub. All rights reserved.
//

#import "UnityAdsBannerCustomEvent.h"
#import "UnityRouter.h"
#if __has_include("MoPub.h")
    #import "MPLogging.h"
#endif

static NSString *const kMPUnityBannerGameId = @"gameId";
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
    NSString *gameId = info[kMPUnityBannerGameId];
    self.placementId = info[kUnityAdsOptionPlacementIdKey];
    if (self.placementId == nil) {
        self.placementId = info[kUnityAdsOptionZoneIdKey];
    }
    if (gameId == nil || self.placementId == nil) {
        NSError *error = [self createErrorWith:@"Unity Ads adapter failed to request Ad"
                                     andReason:@"Custom event class data did not contain gameId/placementId"
                                 andSuggestion:@"Update your MoPub custom event class data to contain a valid Unity Ads gameId/placementId."];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);

        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
        return;
    }

    [[UnityRouter sharedRouter] requestBannerAdWithGameId:gameId placementId:self.placementId delegate:self];
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getAdNetworkId]);
}

#pragma mark - UnityAdsBannerDelegate

- (NSError *)createErrorWith:(NSString *)description andReason:(NSString *)reaason andSuggestion:(NSString *)suggestion {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(description, nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(reaason, nil),
                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(suggestion, nil)
                               };
    
    return [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:userInfo];
}

-(void)unityAdsBannerDidLoad:(NSString *)placementId view:(UIView *)view {
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);

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
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate bannerCustomEventWillLeaveApplication:self];
}
-(void)unityAdsBannerDidError:(NSString *)message {
    NSError *error = [self createErrorWith:@"Unity Ads failed to load an ad"
                                 andReason:@""
                             andSuggestion:@""];

    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
}

- (NSString *) getAdNetworkId {
    return (self.placementId != nil) ? self.placementId : @"";
}

@end
