//
//  MillennialNativeAdAdapter.m
//
//  Copyright (c) 2015 Millennial Media, Inc. All rights reserved.
//

#import "MillennialNativeAdAdapter.h"
#import "MPNativeAdConstants.h"
#import "MPAdImpressionTimer.h"

NSString * const kAdMainImageViewKey = @"mmmainimage";
NSString * const kAdIconImageViewKey = @"mmiconimage";
NSString * const kDisclaimerKey = @"mmdisclaimer";

@interface MillennialNativeAdAdapter() <MPAdImpressionTimerDelegate>

@property (nonatomic) MPAdImpressionTimer *impressionTimer;
@property (nonatomic, strong) MMNativeAd *mmNativeAd;
@property (nonatomic, strong) NSDictionary<NSString *, id> *mmAdProperties;

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
            properties[kAdMainImageViewKey] = ad.mainImageView;
        }

        if (ad.iconImageView.image) {
            properties[kAdIconImageViewKey] = ad.iconImageView;
        }

        if (ad.disclaimer.text) {
            properties[kDisclaimerKey] = ad.disclaimer.text;
        }

        _mmNativeAd = ad;
        _mmAdProperties = properties;

        // Impression tracking
        _impressionTimer = [[MPAdImpressionTimer alloc] initWithRequiredSecondsForImpression:0.0 requiredViewVisibilityPercentage:0.5];
        _impressionTimer.delegate = self;

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

#pragma mark - Click Tracking

- (void)displayContentForURL:(NSURL *)URL rootViewController:(UIViewController *)controller {
    [self.mmNativeAd invokeDefaultAction];
}

#pragma mark - Impression tracking

- (void)willAttachToView:(UIView *)view {
    [self.impressionTimer startTrackingView:view];
}

- (void)adViewWillLogImpression:(UIView *)adView {
    [self.delegate nativeAdWillLogImpression:self];

    // Handle the impression
    [self.mmNativeAd fireImpression];
}

@end
