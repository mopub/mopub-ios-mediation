//
//  FlurryNativeAdAdapter.m
//  MoPub Mediates Flurry
//
//  Created by Flurry.
//  Copyright (c) 2015 Yahoo, Inc. All rights reserved.
//

#import "FlurryNativeAdAdapter.h"
#if __has_include("MoPub.h")
    #import "MPNativeAdConstants.h"
    #import "MPNativeAdError.h"
    #import "MPLogging.h"
#endif

@interface FlurryNativeAdAdapter() <FlurryAdNativeDelegate>

@property (nonatomic, strong) FlurryAdNative *adNative;

@end

@implementation FlurryNativeAdAdapter

@synthesize properties = _properties;

- (instancetype)initWithFlurryAdNative:(FlurryAdNative *)adNative
{
    self = [super init];
    if (self) {
        _adNative = adNative;
        _adNative.adDelegate = self;
        
        _properties = [self convertAssetsToProperties:adNative];
    }
    return self;
}

- (void)dealloc
{
    _adNative.adDelegate = nil;
    _adNative = nil;
}

- (NSDictionary *)convertAssetsToProperties:(FlurryAdNative *)adNative
{
    NSDictionary *flurryToMoPubPropertiesMap = @{
                                                 @"headline": kAdTitleKey,
                                                 @"secImage": kAdIconImageKey,
                                                 @"secHqImage": kAdMainImageKey,
                                                 @"summary": kAdTextKey,
                                                 @"appRating": kAdStarRatingKey,
                                                 @"callToAction": kAdCTATextKey
                                                 };
    
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    for (int ix = 0; ix < adNative.assetList.count; ++ix) {
        FlurryAdNativeAsset* asset = [adNative.assetList objectAtIndex:ix];
        NSString *key = flurryToMoPubPropertiesMap[asset.name];
        if (key == nil) {
            // If we don't have a mapping to one of the standard MoPub keys
            // we still pass the data along using a non-standard key.
            key = [NSString stringWithFormat:@"flurry_%@", asset.name];
        }
        
        id value;
        if ([key isEqualToString:kAdStarRatingKey]) {
            value = [self getStarRatingValue:asset.value];
        } else {
            value = asset.value;
        }
        
        if (key && value) {
            [props setObject:value forKey:key];
        }
    }
    
    return [props copy];
}

- (NSNumber *)getStarRatingValue:(NSString *)appRating
{
    CGFloat ratingValue = 0;
    if ([appRating length] > 0) {
        NSArray *ratingParts = [appRating componentsSeparatedByString:@"/"];
        if ([ratingParts count] == 2) {
            // Rating is in the form X/Y where 0 < X < 100, Y=100
            CGFloat numer = [ratingParts[0] floatValue];
            CGFloat denom = [ratingParts[1] floatValue];
            ratingValue = (numer/denom) * kUniversalStarRatingScale;
        } else {
            // Rating is single digit X where 0 < X < 100
            ratingValue = [ratingParts[0] floatValue] / 100.0 * kUniversalStarRatingScale;
        }
    }
    return [NSNumber numberWithDouble:ratingValue];
}

#pragma mark - MPNativeAdAdapter

- (NSURL *)defaultActionURL
{
    return nil;
}

- (BOOL)enableThirdPartyClickTracking
{
    return YES;
}

- (void)willAttachToView:(UIView *)view
{
    self.adNative.viewControllerForPresentation = [self.delegate viewControllerForPresentingModalView];
    // Can only set FlurryAdNative#videoViewContainer after setting viewControllerForPresentation
    if ([self.adNative isVideoAd]) {
        self.adNative.videoViewContainer = self.videoViewContainer;
    }
    
    self.adNative.trackingView = view;
}

- (void)didDetachFromView:(UIView *)view
{
    [self.adNative removeTrackingView];
}

- (UIView *)mainMediaView
{
    return self.adNative.videoViewContainer;
}

#pragma mark - Flurry Ad Delegates

- (void) adNativeWillPresent:(FlurryAdNative*) nativeAd
{
    MPLogAdEvent([MPLogEvent adWillPresentModalForAdapter:NSStringFromClass(self.class)], nil);
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], nil);
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], nil);

    if ([self.delegate respondsToSelector:@selector(nativeAdWillPresentModalForAdapter:)]) {
        [self.delegate nativeAdWillPresentModalForAdapter:self];
    }
}

- (void) adNativeWillLeaveApplication:(FlurryAdNative*) nativeAd
{
    if ([self.delegate respondsToSelector:@selector(nativeAdWillLeaveApplicationFromAdapter:)]) {
    }
}

- (void) adNativeWillDismiss:(FlurryAdNative*) nativeAd
{
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], nil);
}

- (void) adNativeDidDismiss:(FlurryAdNative*) nativeAd
{
    MPLogAdEvent([MPLogEvent adDidDismissModalForAdapter:NSStringFromClass(self.class)], nil);
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], nil);

    if ([self.delegate respondsToSelector:@selector(nativeAdDidDismissModalForAdapter:)]) {
        [self.delegate nativeAdDidDismissModalForAdapter:self];
    }
}

- (void) adNativeDidReceiveClick:(FlurryAdNative*) nativeAd
{
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], nil);

    if ([self.delegate respondsToSelector:@selector(nativeAdDidClick:)]) {
        [self.delegate nativeAdDidClick:self];
    } else {
        MPLogInfo(@"Delegate does not implement click tracking callback. Clicks likely not being tracked.");
    }
}

- (void) adNativeDidLogImpression:(FlurryAdNative*) nativeAd
{
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], nil);

    if ([self.delegate respondsToSelector:@selector(nativeAdWillLogImpression:)]) {
        [self.delegate nativeAdWillLogImpression:self];
    } else {
        MPLogInfo(@"Delegate does not implement impression tracking callback. Impression likely not being tracked.");
    }
}

@end
