//
//  FacebookNativeAdAdapter.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import "FacebookNativeAdAdapter.h"
#if __has_include("MoPub.h")
    #import "MPNativeAdConstants.h"
    #import "MPNativeAdError.h"
    #import "MPLogging.h"
#endif

@interface FacebookNativeAdAdapter () <FBNativeAdDelegate>

@property (nonatomic, readonly) FBAdOptionsView *adOptionsView;
@property (nonatomic, readonly) FBMediaView *mediaView;
@property (nonatomic, readonly) FBAdIconView *iconView;

@end

@implementation FacebookNativeAdAdapter

@synthesize properties = _properties;

- (instancetype)initWithFBNativeAd:(FBNativeAd *)fbNativeAd adProperties:(NSDictionary *)adProps
{
    if (self = [super init]) {
        _fbNativeAd = fbNativeAd;
        _fbNativeAd.delegate = self;
        _mediaView = [[FBMediaView alloc] init];
        _iconView = [[FBAdIconView alloc] init];

        NSMutableDictionary *properties;
        if (adProps) {
            properties = [NSMutableDictionary dictionaryWithDictionary:adProps];
        } else {
            properties = [NSMutableDictionary dictionary];
        }

        if (fbNativeAd.headline) {
            [properties setObject:fbNativeAd.headline forKey:kAdTitleKey];
        }

        if (fbNativeAd.bodyText) {
            [properties setObject:fbNativeAd.bodyText forKey:kAdTextKey];
        }

        if (fbNativeAd.callToAction) {
            [properties setObject:fbNativeAd.callToAction forKey:kAdCTATextKey];
        }
        
        /* Per Facebook's requirements, either the ad title or the advertiser name
        will be displayed, depending on the FB SDK version. Therefore, mapping both
        to the MoPub's ad title asset */
        if (fbNativeAd.advertiserName) {
            [properties setObject:fbNativeAd.advertiserName forKey:kAdTitleKey];
        }
        
        [properties setObject:_iconView forKey:kAdIconImageViewKey];
        [properties setObject:_mediaView forKey:kAdMainMediaViewKey];

        if (fbNativeAd.placementID) {
            [properties setObject:fbNativeAd.placementID forKey:@"placementID"];
        }

        if (fbNativeAd.socialContext) {
            [properties setObject:fbNativeAd.socialContext forKey:@"socialContext"];
        }

        _properties = properties;

        _adOptionsView = [[FBAdOptionsView alloc] init];
        _adOptionsView.nativeAd = fbNativeAd;
        _adOptionsView.backgroundColor = [UIColor clearColor];
    }

    return self;
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
    [self.fbNativeAd registerViewForInteraction:view mediaView:self.mediaView iconView:self.iconView viewController:[self.delegate viewControllerForPresentingModalView]];
}

- (void)willAttachToView:(UIView *)view withAdContentViews:(NSArray *)adContentViews
{
    if ( adContentViews.count > 0 ) {
        [self.fbNativeAd registerViewForInteraction:view mediaView:self.mediaView iconView:self.iconView viewController:[self.delegate viewControllerForPresentingModalView] clickableViews:adContentViews];
    } else {
        [self willAttachToView:view];
    }
}

- (UIView *)privacyInformationIconView
{
    return self.adOptionsView;
}

- (UIView *)mainMediaView
{
    return self.mediaView;
}

- (UIView *)iconMediaView
{
    return self.iconView;
}

#pragma mark - FBNativeAdDelegate

- (void)nativeAdWillLogImpression:(FBNativeAd *)nativeAd
{
    if ([self.delegate respondsToSelector:@selector(nativeAdWillLogImpression:)]) {
        MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], self.fbNativeAd.placementID);
        MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], self.fbNativeAd.placementID);
        [self.delegate nativeAdWillLogImpression:self];
    } else {
        MPLogInfo(@"Delegate does not implement impression tracking callback. Impressions likely not being tracked.");
    }
}

- (void)nativeAdDidClick:(FBNativeAd *)nativeAd
{
    if ([self.delegate respondsToSelector:@selector(nativeAdDidClick:)]) {
        MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], self.fbNativeAd.placementID);
        [self.delegate nativeAdDidClick:self];
    } else {
        MPLogInfo(@"Delegate does not implement click tracking callback. Clicks likely not being tracked.");
    }

    MPLogAdEvent([MPLogEvent adWillPresentModalForAdapter:NSStringFromClass(self.class)], self.fbNativeAd.placementID);

    [self.delegate nativeAdWillPresentModalForAdapter:self];
}

- (void)nativeAdDidFinishHandlingClick:(FBNativeAd *)nativeAd
{
    MPLogAdEvent([MPLogEvent adDidDismissModalForAdapter:NSStringFromClass(self.class)], self.fbNativeAd.placementID);

    [self.delegate nativeAdDidDismissModalForAdapter:self];
}

@end
