//
//  ChartboostBannerCustomEvent.m
//  MoPubSDK
//
//  Copyright (c) 2019 MoPub. All rights reserved.
//

#import "ChartboostBannerCustomEvent.h"
#import "ChartboostRouter.h"
#import "NSError+ChartboostErrors.h"

@interface ChartboostBannerCustomEvent () <CHBBannerDelegate>
@property (nonatomic) CHBBanner *banner;
@end

@implementation ChartboostBannerCustomEvent

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    NSString *location = [info objectForKey:@"location"];
    location = location.length > 0 ? location : CBLocationDefault;
    CGSize integerSize = CGSizeMake(floor(size.width), floor(size.height));

    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], location);
    if (self.banner) {
        MPLogAdEvent([MPLogEvent error:[NSError adRequestCalledTwiceOnSameEvent] message:nil], location);
    }
    
    __weak typeof(self) weakSelf = self;
    [ChartboostRouter startWithParameters:info completion:^(BOOL initialized) {
        if (!initialized) {
            NSError *error = [NSError adRequestFailedDueToSDKStartWithAdOfType:@"banner"];
            MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], location);
            [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.banner.delegate = nil;
            weakSelf.banner = [[CHBBanner alloc] initWithSize:integerSize location:location mediation:[ChartboostRouter mediation] delegate:weakSelf];
            weakSelf.banner.automaticallyRefreshesContent = NO;
            
            [weakSelf.banner showFromViewController:[weakSelf.delegate viewControllerForPresentingModalView]];
        });
    }];
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;  // Disabled so we have control over the click tracking behavior
}

// MARK: - CHBBannerDelegate

- (void)didCacheAd:(CHBCacheEvent *)event error:(nullable CHBCacheError *)error
{
    if (error) {
        NSError *nserror = [NSError errorWithCacheEvent:event error:error];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:nserror], event.ad.location);
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nserror];
    } else {
        MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], event.ad.location);
        [self.delegate bannerCustomEvent:self didLoadAd:self.banner];
    }
}

- (void)willShowAd:(CHBShowEvent *)event error:(nullable CHBShowError *)error
{
    if (error) {
        NSError *nserror = [NSError errorWithShowEvent:event error:error];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:nserror], event.ad.location);
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nserror];
    } else {
        MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], event.ad.location);
    }
}

- (void)didShowAd:(CHBShowEvent *)event error:(nullable CHBShowError *)error
{
    if (error) {
        NSError *nserror = [NSError errorWithShowEvent:event error:error];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:nserror], event.ad.location);
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nserror];
    } else {
        MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], event.ad.location);
        [self.delegate trackImpression];
    }
}

- (void)didClickAd:(CHBClickEvent *)event error:(nullable CHBClickError *)error
{
    if (error) {
        NSError *nserror = [NSError errorWithClickEvent:event error:error];
        MPLogAdEvent([MPLogEvent error:nserror message:nil], event.ad.location);
    } else {
        [self.delegate bannerCustomEventWillBeginAction:self];
    }
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], event.ad.location);
    [self.delegate trackClick]; // We track the click even if there was an error, since we want to track events like when an ad passes an invalid url
}

- (void)didFinishHandlingClick:(CHBClickEvent *)event error:(nullable CHBClickError *)error
{
    if (error) {
        NSError *nserror = [NSError errorWithDidFinishHandlingClickEvent:event error:error];
        MPLogAdEvent([MPLogEvent error:nserror message:nil], event.ad.location);
    }
    [self.delegate bannerCustomEventDidFinishAction:self];
}

@end
