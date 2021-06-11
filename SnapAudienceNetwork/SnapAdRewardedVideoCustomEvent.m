#import "SnapAdRewardedVideoCustomEvent.h"
#import "SnapAdAdapterConfiguration.h"
#import "SnapAdErrorHelpers.h"
#import <SAKSDK/SAKSDK.h>
#if __has_include("MoPub.h")
    #import "MPLogging.h"
    #import "MPError.h"
    #import "MPReward.h"
#endif

static NSString *const kSAKSlotId = @"slotId";

@interface SnapAdRewardedVideoCustomEvent () <SAKRewardedAdDelegate>

@property (nonatomic, copy) NSString *slotId;
@property (nonatomic) SAKRewardedAd *rewardedAd;

@end

@implementation SnapAdRewardedVideoCustomEvent

@dynamic delegate;
@dynamic localExtras;

#pragma mark - MPFullscreenAdAdapter Override

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    _slotId = [info objectForKey:kSAKSlotId];
    
    if (!self.slotId) {
        NSError *error = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd
                           localizedDescription:@"Snap's Slot ID received is nil."];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.slotId);
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        return;
    } else {
        MPLogInfo(@"[MoPub] Server info fetched from MoPub for Snap Ad Kit. slotId : %@", self.slotId);
    }
    
    [SnapAdAdapterConfiguration updateInitializationParameters:info];
    
    if ([[SAKMobileAd shared] initialized]) {
        [self _loadRewardedAd];
    } else {
        typeof(self) __weak weakSelf = self;
        [SnapAdAdapterConfiguration initSnapAdKit:info
                                         complete:^(NSError *error) {
            if (!error) {
                [weakSelf _loadRewardedAd];
            }
        }];
    }
}

- (BOOL)isRewardExpected
{
    return YES;
}

- (BOOL)hasAdAvailable
{
    return self.rewardedAd.isReady;
}

- (void)presentAdFromViewController:(nonnull UIViewController *)viewController
{
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.slotId);
    
    if (_rewardedAd) {
        [_rewardedAd presentFromRootViewController:viewController dismissTransition:CGRectZero];
    } else {
        NSError *error = SnapAdCreateError(self.class, @"[MoPub] Snap Ad Kit rewarded not ready yet.", @"",
                                           @"You can make a new ad request.");
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], self.slotId);
        [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:error];
    }
}

- (void)dealloc
{
    _rewardedAd.delegate = nil;
    _rewardedAd = nil;
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (void)handleDidInvalidateAd
{
    // no-op
}

- (void)handleDidPlayAd
{
    // no-op
}

#pragma mark - private methods

- (void)_loadRewardedAd
{
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil],
                 self.slotId);
    if (!_rewardedAd) {
        _rewardedAd = [SAKRewardedAd new];
        _rewardedAd.delegate = self;
    }
    
    SAKAdRequestConfigurationBuilder *configurationBuilder = [SAKAdRequestConfigurationBuilder new];
    [configurationBuilder withPublisherSlotId:self.slotId];
    
    [_rewardedAd loadRequest:[configurationBuilder build]];
}

#pragma mark - SAKRewardedAdDelegate methods

- (void)rewardedAd:(nonnull SAKRewardedAd *)ad didFailWithError:(nonnull NSError *)error
{
    NSString *errorDescription = [NSString stringWithFormat:@"[MoPub] %@", SnapAdErrorDescription(error)];
    NSError *mpError = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd localizedDescription:errorDescription];
    
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:mpError], self.slotId);
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)rewardedAdDidAppear:(nonnull SAKRewardedAd *)ad
{
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], self.slotId);
    
    [self.delegate fullscreenAdAdapterAdDidPresent:self];
    [self.delegate fullscreenAdAdapterDidTrackImpression:self];
}

- (void)rewardedAdDidDisappear:(nonnull SAKRewardedAd *)ad
{
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], self.slotId);
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
    [self.delegate fullscreenAdAdapterAdDidDismiss:self];
}

- (void)rewardedAdDidEarnReward:(nonnull SAKRewardedAd *)ad
{
    MPReward *reward = [MPReward unspecifiedReward];
    
    MPLogAdEvent([MPLogEvent adShouldRewardUserWithReward:reward], self.slotId);
    [self.delegate fullscreenAdAdapter:self willRewardUser:reward];
}

- (void)rewardedAdDidExpire:(nonnull SAKRewardedAd *)ad
{
    NSError *error = SnapAdCreateError(self.class, @"Error in loading Snap Ad Kit Rewarded Ad",
                                       @"Snap Rewarded Ad has expired.", @"");
    MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], self.slotId);
    [self.delegate fullscreenAdAdapterDidExpire:self];
    [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:error];
}

- (void)rewardedAdDidLoad:(nonnull SAKRewardedAd *)ad
{
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], self.slotId);
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
}

- (void)rewardedAdDidShowAttachment:(nonnull SAKRewardedAd *)ad
{
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], self.slotId);
    MPLogAdEvent([MPLogEvent adWillLeaveApplicationForAdapter:NSStringFromClass(self.class)], self.slotId);

    [self.delegate fullscreenAdAdapterDidReceiveTap:self];
    [self.delegate fullscreenAdAdapterDidTrackClick:self];
    [self.delegate fullscreenAdAdapterWillLeaveApplication:self];
}

- (void)rewardedAdWillAppear:(nonnull SAKRewardedAd *)ad
{
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], self.slotId);
    [self.delegate fullscreenAdAdapterAdWillPresent:self];
}

- (void)rewardedAdWillDisappear:(nonnull SAKRewardedAd *)ad
{
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], self.slotId);
    [self.delegate fullscreenAdAdapterAdWillDismiss:self];
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
}

@end
