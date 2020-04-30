//
//  BUDMopubNativeBannerView.m
//  BUADDemo
//
//  Created by bytedance on 2020/4/24.
//  Copyright © 2020 Bytedance. All rights reserved.
//

#import "BUDMopubNativeBannerView.h"
#import <BUAdSDK/BUNativeAdRelatedView.h>
#import "UIImageView+AFNetworking.h"
#import "BUDMacros.h"
//#import UIKit
#import "UIView+Draw.h"

static CGSize const logoSize = {58, 18.5};

@interface BUDMopubNativeBannerView ()
@property (nonatomic, strong) BUNativeAdRelatedView *relatedView;
@property (nonatomic, strong, nullable) UIScrollView *horizontalScrollView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic,strong) UIImageView *adLogo;
@end

@implementation BUDMopubNativeBannerView

- (instancetype)initWithSize:(CGSize)size {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, size.width, size.height);
        [self buildupView];
    }
    return self;
}

- (void)buildupView {
    self.relatedView = [[BUNativeAdRelatedView alloc] init];
    
    self.horizontalScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.horizontalScrollView.pagingEnabled = YES;
    [self addSubview:self.horizontalScrollView];
    
    self.relatedView = [[BUNativeAdRelatedView alloc] init];
    self.closeButton = self.relatedView.dislikeButton;
    [self addSubview:self.closeButton];
    
    self.adLogo = self.relatedView.logoADImageView;
    [self addSubview:self.adLogo];
    
    [self addAccessibilityIdentifier];
}

- (void)refreshUIWithAd:(BUNativeAd *_Nonnull)nativeAd {
    self.nativeAd = nativeAd;
    [self.relatedView refreshData:nativeAd];
    
    for (UIView *view in self.horizontalScrollView.subviews) {
        [view removeFromSuperview];
    }
    
    CGFloat contentWidth = CGRectGetWidth(self.bounds);
    CGFloat contentHeight = CGRectGetHeight(self.bounds);
    self.horizontalScrollView.frame = CGRectMake(0, 0, contentWidth, contentHeight);
    
    BUMaterialMeta *materialMeta = nativeAd.data;
    CGFloat x = 0.0;
    for (int i = 0; i < materialMeta.imageAry.count; i++) {
        BUImage *adImage = [materialMeta.imageAry objectAtIndex:i];

        UIImageView *adImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 0, contentWidth, contentHeight)];
        adImageView.contentMode =  UIViewContentModeScaleAspectFill;
        adImageView.clipsToBounds = YES;
        if (adImage.imageURL.length) {
            [adImageView setImageWithURL:[NSURL URLWithString:adImage.imageURL] placeholderImage:nil];
        }
        [self.horizontalScrollView addSubview:adImageView];
        
        CAGradientLayer* gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = @[
                                 (id)[[UIColor blackColor] colorWithAlphaComponent:0].CGColor,
                                 (id)[[UIColor blackColor] colorWithAlphaComponent:0.7].CGColor];
        gradientLayer.frame = CGRectMake(0, contentHeight -60, contentWidth, 60);
        [adImageView.layer addSublayer:gradientLayer];
        
        NSString * titleString = [NSString stringWithFormat:@"Total Page:%lu, Current page:%d",(unsigned long)materialMeta.imageAry.count,i+1];

        UILabel *titleLable = [UILabel new];
        titleLable.frame = CGRectMake(10, contentHeight-10-20, contentWidth-100, 20);
        titleLable.textColor = BUD_RGB(0xff, 0xff, 0xff);
        titleLable.font = [UIFont boldSystemFontOfSize:18];
        titleLable.text = titleString;
        [adImageView addSubview:titleLable];
        
        [self.nativeAd registerContainer:adImageView withClickableViews:nil];
        
        x += contentWidth;
        adImageView.accessibilityIdentifier = @"banner_view";
    }
    self.horizontalScrollView.contentSize = CGSizeMake(x, contentHeight);
    self.closeButton.frame = CGRectMake(self.width-self.closeButton.width-5, self.horizontalScrollView.height +(bottomHeight-self.closeButton.width)/2, self.closeButton.width, self.closeButton.height);
    self.adLogo.frame = CGRectMake(self.closeButton.left-logoSize.width - 10, self.horizontalScrollView.height +(bottomHeight-logoSize.height)/2, logoSize.width, logoSize.height);
}

#pragma mark addAccessibilityIdentifier
- (void)addAccessibilityIdentifier {
    self.closeButton.accessibilityIdentifier = @"banner_close";
    self.adLogo.accessibilityIdentifier = @"banner_logo";
}

@end
