//
//  BUDMopub_MPNativeCustomEvent.m
//  BUDemo
//
//  Created by Pangle on 2020/1/8.
//  Copyright © 2020 Pangle. All rights reserved.
//

#import "PangleNativeAdAdapter.h"
#import <BUAdSDK/BUNativeAdRelatedView.h>
#import <BUFoundation/UIImageView+BUWebCache.h>
#if __has_include("MoPub.h")
#import "MPNativeAd.h"
#import "MPNativeAdConstants.h"
#endif

@interface PangleNativeAdAdapter ()
@property (nonatomic, strong) UIView *mediaView;
@property (nonatomic, strong) BUNativeAdRelatedView *relatedView;
@property (nonatomic, strong) BUNativeAd *nativeAd;
@end

@implementation PangleNativeAdAdapter

- (instancetype)initWithBUNativeAd:(BUNativeAd *)nativeAd {
    if (self = [super init]) {
        self.properties = [self buNativeAdToDic:nativeAd];
    }
    return self;
}

- (NSDictionary *)buNativeAdToDic:(BUNativeAd *)nativeAd {
    self.nativeAd = nativeAd;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:nativeAd.data.AdTitle forKey:kAdTitleKey];
    [dic setValue:nativeAd.data.AdDescription forKey:kAdTextKey];
    [dic setValue:nativeAd.data.buttonText forKey:kAdCTATextKey];
    [dic setValue:nativeAd.data.icon.imageURL forKey:kAdIconImageKey];
    [dic setValue:@(nativeAd.data.score) forKey:kAdStarRatingKey];
    if (nativeAd.data.imageAry.count > 0) {
        [dic setValue:nativeAd.data.imageAry.firstObject.imageURL forKey:kAdMainImageKey];
    }
    self.mediaView = nil;
    self.relatedView = [[BUNativeAdRelatedView alloc] init];
    [self.relatedView refreshData:nativeAd];
    if (nativeAd.data.imageMode == BUFeedVideoAdModeImage) {
        self.mediaView = self.relatedView.videoAdView;
    }else{
        UIImageView *imageView = [[UIImageView alloc] init];
        self.mediaView = imageView;
        if (nativeAd.data.imageAry.count > 0) {
            BUImage *img = nativeAd.data.imageAry.firstObject;
            if (img.imageURL.length > 0) {
                [imageView sdBu_setImageWithURL:[NSURL URLWithString:img.imageURL] placeholderImage:nil];
            }
        }
    }
    [dic setValue:self.mediaView forKey:kAdMainMediaViewKey];
    [dic setValue:nativeAd forKey:@"bu_nativeAd"];
    return [dic copy];
}


#pragma mark - <MPNativeAdAdapter>
- (void)willAttachToView:(UIView *)view
{
    if (self.nativeAd.data.imageMode == BUFeedVideoAdModeImage) {
        [self.nativeAd registerContainer:view withClickableViews:@[]];
    } else {
        [self.nativeAd registerContainer:view withClickableViews:@[]];
    }
}

- (void)willAttachToView:(UIView *)view withAdContentViews:(NSArray *)adContentViews
{
    if ( adContentViews.count > 0 ) {
        if (self.nativeAd.data.imageMode == BUFeedVideoAdModeImage) {
            [self.nativeAd registerContainer:view withClickableViews:adContentViews];
        } else {
            [self.nativeAd registerContainer:view withClickableViews:adContentViews];
        }
    } else {
        [self willAttachToView:view];
    }
}

- (BOOL)enableThirdPartyClickTracking {
    return NO;
}

- (UIView *)mainMediaView
{
    return self.mediaView;
}

- (UIView *)iconMediaView
{
    return self.relatedView.logoImageView;
}

- (UIView *)privacyInformationIconView {
  return self.relatedView.logoADImageView;
}

@end
