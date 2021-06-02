#import "OguryBannerCustomEvent.h"
#import <Foundation/Foundation.h>
#import <OguryAds/OguryAds.h>
#import "OguryAdapterConfiguration.h"

#if __has_include("MoPub.h")
#import "MPError.h"
#import "MPLogging.h"
#endif

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
        NSError *error = [NSError errorWithCode:MOPUBErrorAdapterInvalid localizedDescription:@"Invalid ad unit ID for Ogury received. Failing ad request"];
        
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass([self class]) error:error], @"");
        
        [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }
    
    OguryAdsBannerSize *sizeOguryBanner = [OguryBannerCustomEvent getOgurySize:size];
    
    if (!sizeOguryBanner) {
        NSError *error = [NSError errorWithCode:MOPUBErrorAdapterInvalid localizedDescription:@"Invalid banner size received. Ogury only supports 320x50 and 300x250 sizes. Failing ad request"];
        
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass([self class]) error:error], self.adUnitId);
        
        [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }
    
    [OguryAdapterConfiguration updateInitializationParameters:info];

    self.banner = [[OguryAdsBanner alloc] initWithAdUnitID:self.adUnitId];
    self.banner.bannerDelegate = self;
    self.banner.frame = CGRectMake(0, 0, size.width, size.height);

    [self.banner loadWithSize:sizeOguryBanner];

    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass([self class]) dspCreativeId:nil dspName:nil], self.adUnitId);
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
    double maxRatio = 1.5;
    return sizeMopubBanner.height <= sizeOguryBanner.height * maxRatio && sizeMopubBanner.width <= sizeOguryBanner.width * maxRatio;
}

#pragma mark - OguryAdsBannerDelegate

- (void)oguryAdsBannerAdAvailable:(OguryAdsBanner *)bannerAds {
}

- (void)oguryAdsBannerAdClicked:(OguryAdsBanner *)bannerAds {
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], self.adUnitId);

    [self.delegate inlineAdAdapterWillBeginUserAction:self];
    [self.delegate inlineAdAdapterDidTrackClick:self];
}

- (void)oguryAdsBannerAdClosed:(OguryAdsBanner *)bannerAds {
    [self.delegate inlineAdAdapterDidEndUserAction:self];
}

- (void)oguryAdsBannerAdDisplayed:(OguryAdsBanner *)bannerAds {
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.adUnitId);
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass([self class])], self.adUnitId);
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass([self class])], self.adUnitId);
    
    [self.delegate inlineAdAdapterDidTrackImpression:self];
}

- (void)oguryAdsBannerAdError:(OguryAdsErrorType)errorType forBanner:(OguryAdsBanner *)bannerAds {
    NSError *error = [OguryAdapterConfiguration MoPubErrorFromOguryError:errorType];
    
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.adUnitId);
    [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)oguryAdsBannerAdLoaded:(OguryAdsBanner *)bannerAds {
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass([self class])], self.adUnitId);
    
    [self.delegate inlineAdAdapter:self didLoadAdWithAdView:bannerAds];
}

- (void)oguryAdsBannerAdNotAvailable:(OguryAdsBanner *)bannerAds {
    NSError *error = [NSError errorWithCode:MOPUBErrorNoInventory];
    
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.adUnitId);
    [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)oguryAdsBannerAdNotLoaded:(OguryAdsBanner *)bannerAds {
    NSError *error = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd];
    
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.adUnitId);
    [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)oguryAdsBannerAdOnAdImpression {
    [self.delegate inlineAdAdapterDidTrackImpression:self];
}

@end
