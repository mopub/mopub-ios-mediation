//
//  MillennialNativeAdAdapter.m
//
//  Copyright (c) 2015 Millennial Media, Inc. All rights reserved.
//

#import "MillennialNativeAdAdapter.h"
#if __has_include("MoPub.h")
    #import "MPNativeAdConstants.h"
    #import "MPAdImpressionTimer.h"
#endif

NSString * const kDisclaimerKey = @"mmdisclaimer";

@interface MillennialNativeAdAdapter() <MPAdImpressionTimerDelegate>

@property (nonatomic) MPAdImpressionTimer *impressionTimer;
@property (nonatomic, strong) MMNativeAd *mmNativeAd;
@property (nonatomic, strong) NSDictionary<NSString *, id> *mmAdProperties;
@property (nonatomic, readonly) UIImageView *mainImageView;
@property (nonatomic, readonly) UIImageView *iconImageView;

@end

@implementation MillennialNativeAdAdapter

- (instancetype)initWithMMNativeAd:(MMNativeAd *)ad {
    if (self = [super init]) {
        NSMutableDictionary<NSString *, id> *properties = [NSMutableDictionary dictionary];

        if (ad.title.text) {
            properties[kAdTitleKey] = ad.title.text;
        }

        if (ad.body.text) {
            properties[kAdTextKey] = ad.body.text;
        }

        if (ad.callToActionButton.titleLabel.text) {
            properties[kAdCTATextKey] = ad.callToActionButton.titleLabel.text;
        }

        if (ad.rating.text) {
            properties[kAdStarRatingKey] = @(ad.rating.text.integerValue);
        }

        if (ad.mainImageView.image) {
            _mainImageView = ad.mainImageView;
            properties[kAdMainMediaViewKey] = _mainImageView;
        }

        if (ad.iconImageView.image) {
            _iconImageView = ad.iconImageView;
            properties[kAdIconImageViewKey] = _iconImageView;
        }

        if (ad.disclaimer.text) {
            properties[kDisclaimerKey] = ad.disclaimer.text;
        }

        self.mmNativeAd = ad;
        self.mmAdProperties = properties;

        // Impression tracking
        self.impressionTimer = [[MPAdImpressionTimer alloc] initWithRequiredSecondsForImpression:0.0 requiredViewVisibilityPercentage:0.5];
        self.impressionTimer.delegate = self;

    }
    return self;
}

#pragma mark - MPNativeAdAdapter

- (NSDictionary *)properties {
    return self.mmAdProperties;
}

- (NSURL *)defaultActionURL {
    return nil;
}

- (UIView *)mainMediaView
{
    return self.mainImageView;
}

- (UIView *)iconMediaView
{
    return self.iconImageView;
}

#pragma mark - Click Tracking

- (void)displayContentForURL:(NSURL *)URL rootViewController:(UIViewController *)controller {
    [self.mmNativeAd invokeDefaultAction];
    [self.delegate nativeAdDidClick:self];

    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], nil);
}

#pragma mark - Impression tracking

- (void)willAttachToView:(UIView *)view {
    [self.impressionTimer startTrackingView:view];
}

- (void)adViewWillLogImpression:(UIView *)adView {
    [self.delegate nativeAdWillLogImpression:self];

    // Handle the impression
    [self.mmNativeAd fireImpression];
    [self.delegate nativeAdWillLogImpression:self];
    
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], nil);
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], nil);
}

@end
