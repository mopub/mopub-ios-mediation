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

NSString *const kFBVideoAdsEnabledKey = @"video_enabled";

@interface FacebookNativeAdAdapter () <FBNativeAdDelegate>

@property (nonatomic, readonly) FBNativeAd *fbNativeAd;
@property (nonatomic, readonly) FBAdChoicesView *adChoicesView;
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
        [_mediaView setNativeAd:_fbNativeAd];
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
        
        [properties setObject:_iconView forKey:kAdIconImageViewKey];
        [properties setObject:_mediaView forKey:kAdMainMediaViewKey];

        if (fbNativeAd.placementID) {
            [properties setObject:fbNativeAd.placementID forKey:@"placementID"];
        }

        if (fbNativeAd.socialContext) {
            [properties setObject:fbNativeAd.socialContext forKey:@"socialContext"];
        }

        _properties = properties;

        _adChoicesView = [[FBAdChoicesView alloc] initWithNativeAd:fbNativeAd];
        _adChoicesView.backgroundShown = NO;
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
    return self.adChoicesView;
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
        [self.delegate nativeAdWillLogImpression:self];
    } else {
        MPLogWarn(@"Delegate does not implement impression tracking callback. Impressions likely not being tracked.");
    }
}

- (void)nativeAdDidClick:(FBNativeAd *)nativeAd
{
    if ([self.delegate respondsToSelector:@selector(nativeAdDidClick:)]) {
        [self.delegate nativeAdDidClick:self];
    } else {
        MPLogWarn(@"Delegate does not implement click tracking callback. Clicks likely not being tracked.");
    }

    [self.delegate nativeAdWillPresentModalForAdapter:self];
}

- (void)nativeAdDidFinishHandlingClick:(FBNativeAd *)nativeAd
{
    [self.delegate nativeAdDidDismissModalForAdapter:self];
}

@end
