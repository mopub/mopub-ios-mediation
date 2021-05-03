//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OguryBannerCustomEvent.h"
#import <Foundation/Foundation.h>
#import <OguryAds/OguryAds.h>
#import "OguryAdapterConfiguration.h"

@interface OguryBannerCustomEvent () <OguryAdsBannerDelegate>

#pragma mark - Properties

@property (nonatomic, copy) NSString *adUnitId;
@property (nonatomic, strong) OguryAdsBanner *banner;

@end

@implementation OguryBannerCustomEvent

@dynamic adUnitId;

#pragma mark - Methods

- (void)dealloc {
    self.banner.bannerDelegate = nil;
}

- (void)requestAdWithSize:(CGSize)size adapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    self.adUnitId = info[kOguryConfigurationAdUnitId];
    if (!self.adUnitId || [self.adUnitId isEqualToString:@""]) {
        NSError *error = [NSError errorWithCode:MOPUBErrorAdapterInvalid localizedDescription:@"An error occurred while loading the ad. Invalid ad unit identifier."];

        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass([self class]) error:error], @"");

        [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }

    OguryAdsBannerSize *sizeOguryBanner = [OguryBannerCustomEvent getOgurySize:size];

    if (!sizeOguryBanner) {
        NSError *error = [NSError errorWithCode:MOPUBErrorAdapterInvalid localizedDescription:@"An error occurred while loading the ad. Invalid width | height."];

        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass([self class]) error:error], self.adUnitId);

        [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }

    [OguryAdapterConfiguration applyTransparencyAndConsentStatusWithParameters:info];

    self.banner = [[OguryAdsBanner alloc] initWithAdUnitID:self.adUnitId];
    self.banner.bannerDelegate = self;
    self.banner.frame = CGRectMake(0, 0, size.width, size.height);

    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass([self class]) dspCreativeId:nil dspName:nil], self.adUnitId);

    [self.banner loadWithSize:sizeOguryBanner];
}

+ (OguryAdsBannerSize *)getOgurySize:(CGSize)size {
    if ([OguryBannerCustomEvent size:size canInclude:[[OguryAdsBannerSize small_banner_320x50] getSize]]) {
        return [OguryAdsBannerSize small_banner_320x50];
    }

    if ([OguryBannerCustomEvent size:size canInclude:[[OguryAdsBannerSize mpu_300x250] getSize]]) {
        return [OguryAdsBannerSize mpu_300x250];
    }

    return nil;
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

+ (BOOL)size:(CGSize)sizeMopubBanner canInclude:(CGSize)sizeOguryBanner {
    if (sizeMopubBanner.height < sizeOguryBanner.height || sizeMopubBanner.width < sizeOguryBanner.width) {
        return NO;
    }

    double maxRatio = 1.5;
    if (sizeMopubBanner.height >= sizeOguryBanner.height * maxRatio || sizeMopubBanner.width >= sizeOguryBanner.width * maxRatio) {
        return NO;
    }

    return YES;
}

#pragma mark - OguryAdsBannerDelegate

- (void)oguryAdsBannerAdAvailable:(OguryAdsBanner *)bannerAds {
    
}

- (void)oguryAdsBannerAdClicked:(OguryAdsBanner *)bannerAds {
    [self.delegate inlineAdAdapterWillBeginUserAction:self];
    [self.delegate inlineAdAdapterDidTrackClick:self];
}

- (void)oguryAdsBannerAdClosed:(OguryAdsBanner *)bannerAds {
     [self.delegate inlineAdAdapterDidEndUserAction:self];
}

- (void)oguryAdsBannerAdDisplayed:(OguryAdsBanner *)bannerAds {
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass([self class])], self.adUnitId);
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass([self class])], self.adUnitId);
    
     [self.delegate inlineAdAdapterDidTrackImpression:self];
}

- (void)oguryAdsBannerAdError:(OguryAdsErrorType)errorType forBanner:(OguryAdsBanner *)bannerAds {
    NSError *error = [OguryAdapterConfiguration MoPubErrorFromOguryError:errorType];

    MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass([self class]) error:error], self.adUnitId);

    [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)oguryAdsBannerAdLoaded:(OguryAdsBanner *)bannerAds {
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass([self class])], self.adUnitId);

    [self.delegate inlineAdAdapter:self didLoadAdWithAdView:bannerAds];
}

- (void)oguryAdsBannerAdNotAvailable:(OguryAdsBanner *)bannerAds {
    NSError *error = [NSError errorWithCode:MOPUBErrorNoInventory];

    MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass([self class]) error:error], self.adUnitId);

    [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)oguryAdsBannerAdNotLoaded:(OguryAdsBanner *)bannerAds {
    NSError *error = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd];

    MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass([self class]) error:error], self.adUnitId);

    [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
}

@end
