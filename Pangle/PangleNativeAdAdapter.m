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
@end

@implementation PangleNativeAdAdapter

- (instancetype)initWithBUNativeAd:(BUNativeAd *)nativeAd {
    if (self = [super init]) {
        self.properties = [self buNativeAdToDic:nativeAd];
    }
    return self;
}

- (NSDictionary *)buNativeAdToDic:(BUNativeAd *)nativeAd {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:nativeAd.data.AdTitle forKey:kAdTitleKey];
    [dic setValue:nativeAd.data.AdDescription forKey:kAdTextKey];
    [dic setValue:nativeAd.data.buttonText forKey:kAdCTATextKey];
    [dic setValue:nativeAd.data.icon.imageURL forKey:kAdIconImageKey];
    if (nativeAd.data.imageAry.count > 0) {
        [dic setValue:nativeAd.data.imageAry.firstObject.imageURL forKey:kAdMainImageKey];
    }
    self.mediaView = nil;
    if (nativeAd.data.imageMode == BUFeedVideoAdModeImage) {
        BUNativeAdRelatedView *related = [[BUNativeAdRelatedView alloc] init];
        [related refreshData:nativeAd];
        self.mediaView = related.videoAdView;
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
    // This is translate the Pangle nativeAd
    [dic setValue:nativeAd forKey:@"bu_nativeAd"];
    return [dic copy];
}

- (BOOL)enableThirdPartyClickTracking {
    return NO;
}

- (UIView *)mainMediaView
{
    return self.mediaView;
}

@end
