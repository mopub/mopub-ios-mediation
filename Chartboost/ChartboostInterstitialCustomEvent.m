//
//  ChartboostInterstitialCustomEvent.m
//  MoPubSDK
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "ChartboostInterstitialCustomEvent.h"
#import "ChartboostRouter.h"
#import "NSError+ChartboostErrors.h"

@interface ChartboostInterstitialCustomEvent() <CHBInterstitialDelegate>
@property (nonatomic) CHBInterstitial *ad;
@end

@implementation ChartboostInterstitialCustomEvent

#pragma mark - MPInterstitialCustomEvent

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    NSString *location = [info objectForKey:@"location"];
    location = location.length > 0 ? location : CBLocationDefault;

    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], location);
    if (self.ad) {
        MPLogAdEvent([MPLogEvent error:[NSError adRequestCalledTwiceOnSameEvent] message:nil], location);
    }
    
    __weak typeof(self) weakSelf = self;
    [ChartboostRouter startWithParameters:info completion:^(BOOL initialized) {
        if (!initialized) {
            NSError *error = [NSError adRequestFailedDueToSDKStartWithAdOfType:@"interstitial"];
            MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], location);
            [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
            return;
        }
        
        weakSelf.ad.delegate = nil;
        weakSelf.ad = [[CHBInterstitial alloc] initWithLocation:location mediation:[ChartboostRouter mediation] delegate:weakSelf];
        [weakSelf.ad cache];
    }];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)viewController
{
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.ad.location);
    [self.ad showFromViewController:viewController];
}

#pragma mark - CHBInterstitialDelegate

- (void)didCacheAd:(CHBCacheEvent *)event error:(CHBCacheError *)error
{
    if (error) {
        NSError *nserror = [NSError errorWithCacheEvent:event error:error];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:nserror], event.ad.location);
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nserror];
    } else {
        MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], event.ad.location);
        [self.delegate interstitialCustomEvent:self didLoadAd:nil];
    }
}

- (void)willShowAd:(CHBShowEvent *)event error:(CHBShowError *)error
{
    if (error) {
        NSError *nserror = [NSError errorWithShowEvent:event error:error];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:nserror], event.ad.location);
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nserror];
    } else {
        MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], event.ad.location);
        [self.delegate interstitialCustomEventWillAppear:self];
    }
}

- (void)didShowAd:(CHBShowEvent *)event error:(CHBShowError *)error
{
    if (error) {
        NSError *nserror = [NSError errorWithShowEvent:event error:error];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:nserror], self.ad.location);
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nserror];
    } else {
        MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], event.ad.location);
        MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], event.ad.location);
        [self.delegate interstitialCustomEventDidAppear:self];
    }
}

- (void)didClickAd:(CHBClickEvent *)event error:(CHBClickError *)error
{
    if (error) {
        NSError *nserror = [NSError errorWithClickEvent:event error:error];
        MPLogAdEvent([MPLogEvent error:nserror message:nil], event.ad.location);
    }
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], event.ad.location);
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
}

- (void)didDismissAd:(CHBDismissEvent *)event
{
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], event.ad.location);
    [self.delegate interstitialCustomEventWillDisappear:self];
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], event.ad.location);
    [self.delegate interstitialCustomEventDidDisappear:self];
}

@end
