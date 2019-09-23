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
@property (nonatomic, strong) NSString* placementId;
@property (nonatomic, strong) UADSBannerView* bannerAdView;
@end

@implementation UnityAdsBannerCustomEvent

-(id)init {
    if (self = [super init]) {

    }
    return self;
}

-(void)dealloc {
    if (self.bannerAdView) {
        self.bannerAdView.delegate = nil;
    }
    self.bannerAdView = nil;
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
    [[UnityRouter sharedRouter] initializeWithGameId:gameId];
    
    self.bannerAdView = [[UADSBannerView alloc] initWithPlacementId:self.placementId size:size];
    self.bannerAdView.delegate = self;
    [self.bannerAdView load];

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

#pragma mark - UADSBannerViewDelegate

-(void)unityAdsBannerDidLoad:(UADSBannerView *)bannerAdView {
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate bannerCustomEvent:self didLoadAd:bannerAdView];
}

-(void)unityAdsBannerDidUnload:(UADSBannerView *)bannerAdView {
    MPLogInfo(@"Unity Banner did unload for %@", bannerAdView.viewId);
}

-(void)unityAdsBannerDidShow:(UADSBannerView *)bannerAdView {
    MPLogInfo(@"Unity Banner did show for %@", bannerAdView.viewId);
}

-(void)unityAdsBannerDidHide:(UADSBannerView *)bannerAdView {
    MPLogInfo(@"Unity Banner did hide for %@", bannerAdView.viewId);
}

-(void)unityAdsBannerDidClick:(UADSBannerView *)bannerAdView {
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate bannerCustomEventWillLeaveApplication:self];
}

-(void)unityAdsBannerDidError:(UADSBannerView *)bannerAdView error:(UADSBannerError *)error  {
    if (error == UADSBannerErrorCodeNoFillError) {
        NSError *error = [self createErrorWith:@"Unity Ads Banner returned no fill" andReason:@"" andSuggestion:@""];
    } else {
        NSError *error = [self createErrorWith:@"Unity Ads failed to load an ad" andReason:@"" andSuggestion:@""];
    }
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
}

- (NSString *) getAdNetworkId {
    return (self.placementId != nil) ? self.placementId : @"";
}

@end
