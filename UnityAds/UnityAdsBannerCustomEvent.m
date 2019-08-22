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
@property (nonatomic, strong) UADSBannerAdView* bannerView;
@end

@implementation UnityAdsBannerCustomEvent

-(id)init {
    if (self = [super init]) {

    }
    return self;
}

-(void)dealloc {
    if (_bannerView) {
        _bannerView.delegate = nil;
    }
    _bannerView = nil;
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
    _bannerView = [[UADSBannerAdView alloc] initWithPlacementId:_placementId size:size];
    [_bannerView setDelegate:self];
    [_bannerView load];

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

-(void)unityAdsBannerDidNoFill:(UADSBannerAdView *)bannerAdView {
    NSError *error = [self createErrorWith:[@"Unity Ads returned no fill for banner placement"
                                            stringByAppendingString:bannerAdView.placementId]
                                 andReason:@""
                             andSuggestion:@""];

    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
}

-(void)unityAdsBannerDidLoad:(UADSBannerAdView *)bannerAdView {
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);

    [self.delegate bannerCustomEvent:self didLoadAd:bannerAdView];
}

/**
 Called when the banner is unloaded and references to it should be discarded.
 The view provided in unityAdsBannerDidLoad will be removed from the view hierarchy before
 this method is called.
 *
 * @param bannerAdView View that unloaded.
 */
-(void)unityAdsBannerDidUnload:(UADSBannerAdView *)bannerAdView {
     MPLogInfo(@"Unity Banner did unload for placement %@", bannerAdView.placementId);
}

/**
 * Called when the banner is shown.
 *
 * @param bannerAdView View that was shown.
 */
-(void)unityAdsBannerDidShow:(UADSBannerAdView *)bannerAdView {
    MPLogInfo(@"Unity Banner did show for placement %@", bannerAdView.placementId);
}

/**
 * Called when the banner is hidden.
 *
 * @param bannerAdView View that was hidden
 */
-(void)unityAdsBannerDidHide:(UADSBannerAdView *)bannerAdView {
    MPLogInfo(@"Unity Banner did hide for placement %@", bannerAdView.placementId);
}

/**
 * Called when the user clicks the banner.
 *
 * @param bannerAdView View that the click occurred on.
 */
-(void)unityAdsBannerDidClick:(UADSBannerAdView *)bannerAdView {
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate bannerCustomEventWillLeaveApplication:self];
}

/**
 *  Called when `UnityAdsBanner` encounters an error.
 *
 *  @param bannerAdView View that encountered an error.
 *  @param message A human readable string indicating the type of error encountered.
 */
-(void)unityAdsBannerDidError:(UADSBannerAdView *)bannerAdView message:(NSString *)message {
    NSError *error = [self createErrorWith:message
                                 andReason:@""
                             andSuggestion:@""];

    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
}


- (NSString *) getAdNetworkId {
    return (self.placementId != nil) ? self.placementId : @"";
}

@end
