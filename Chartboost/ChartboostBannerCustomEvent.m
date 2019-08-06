//
//  ChartboostBannerCustomEvent.m
//  MoPubSDK
//
//  Copyright (c) 2019 MoPub. All rights reserved.
//

#import "ChartboostBannerCustomEvent.h"
#import "ChartboostAdapterConfiguration.h"
#import "ChartboostRouter.h"
#if __has_include("MoPub.h")
    #import "MPLogging.h"
#endif
#import <Chartboost/Chartboost.h>
#import <Chartboost/CHBBanner.h>

@interface ChartboostBannerCustomEvent () <CHBBannerDelegate>

@property (nonatomic) CHBBanner *banner;
@property (nonatomic, copy) NSString *appID;

@end

@implementation ChartboostBannerCustomEvent

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    self.appID = [info objectForKey:@"appId"];
    NSString *appSignature = [info objectForKey:@"appSignature"];
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], self.appID);
    
    if ([self.appID length] == 0 || [appSignature length] == 0) {
        NSError *error = [NSError errorWithCode:MOPUBErrorAdapterInvalid localizedDescription:@"Failed to load Chartboost banner: missing either appId or appSignature. Make sure you have a valid appId or appSignature entered on the MoPub dashboard."];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.appID);
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
        
        return;
    }
    
    if (self.banner) {
        NSError *error = [NSError errorWithCode:MOPUBErrorAdapterInvalid localizedDescription:@"Chartboost adapter failed to load ad: requestAdWithSize called twice on the same event."];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.appID);
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
        
        return;
    }
    
    [ChartboostAdapterConfiguration updateInitializationParameters:info];
    
    NSString *location = [info objectForKey:@"location"];
    location = [location length] != 0 ? location: CBLocationDefault;
    
    __weak typeof(self) weakSelf = self;
    [[ChartboostRouter sharedRouter] startWithAppId:self.appID appSignature:appSignature completion:^(BOOL initialized) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!weakSelf.banner) {
                weakSelf.banner = [[CHBBanner alloc] initWithSize:size location:location delegate:weakSelf];
                weakSelf.banner.automaticallyRefreshesContent = NO;
            }
            
            [weakSelf.banner showFromViewController:[weakSelf.delegate viewControllerForPresentingModalView]];
        });
    }];
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

// MARK: - CHBBannerDelegate

- (void)didCacheAd:(CHBCacheEvent *)event error:(nullable CHBCacheError *)error
{
    if (error) {
        NSError *nserror = [self errorWithCacheError:error];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:nserror], self.appID);
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nserror];
    } else {
        MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], self.appID);
        [self.delegate bannerCustomEvent:self didLoadAd:self.banner];
    }
}

- (void)willShowAd:(CHBShowEvent *)event error:(nullable CHBShowError *)error
{
    if (error) {
        NSError *nserror = [self errorWithShowError:error];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:nserror], self.appID);
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nserror];
    } else {
        MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.appID);
    }
}

- (void)didShowAd:(CHBShowEvent *)event error:(nullable CHBShowError *)error
{
    if (error) {
        NSError *nserror = [self errorWithShowError:error];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:nserror], self.appID);
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nserror];
    } else {
        MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], self.appID);
        [self.delegate trackImpression];
    }
}

- (void)didClickAd:(CHBClickEvent *)event error:(nullable CHBClickError *)error
{
    if (error) {
        NSError *nserror = [self errorWithClickError:error];
        MPLogAdEvent([MPLogEvent error:nserror message:nil], self.appID);
    } else {
        MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], self.appID);
        [self.delegate bannerCustomEventWillBeginAction:self];
        [self.delegate trackClick];
    }
}

- (void)didFinishHandlingClick:(CHBClickEvent *)event error:(nullable CHBClickError *)error
{
    if (error) {
        NSError *nserror = [self errorWithClickHandlingError:error];
        MPLogAdEvent([MPLogEvent error:nserror message:nil], self.appID);
    }
    [self.delegate bannerCustomEventDidFinishAction:self];
}

// MARK: - Helpers

- (NSError *)errorWithCacheError:(CHBCacheError *)error
{
    NSString *description = [NSString stringWithFormat:@"Chartboost adapter failed to load ad with error %lu", (unsigned long)error.code];
    NSError *nserror = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd localizedDescription:description];
    
    return nserror;
}

- (NSError *)errorWithShowError:(CHBShowError *)error
{
    NSString *description = [NSString stringWithFormat:@"Chartboost adapter failed to show ad with error %lu", (unsigned long)error.code];
    NSError *nserror = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd localizedDescription:description];
    
    return nserror;
}

- (NSError *)errorWithClickError:(CHBClickError *)error
{
    NSString *description = [NSString stringWithFormat:@"Chartboost adapter failed to click ad with error %lu", (unsigned long)error.code];
    NSError *nserror = [NSError errorWithCode:MOPUBErrorUnknown localizedDescription:description];
    
    return nserror;
}

- (NSError *)errorWithClickHandlingError:(CHBClickError *)error
{
    NSString *description = [NSString stringWithFormat:@"Chartboost adapter did finish handling click with error %lu", (unsigned long)error.code];
    NSError *nserror = [NSError errorWithCode:MOPUBErrorUnknown localizedDescription:description];
    
    return nserror;
}

@end
