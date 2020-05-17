//
//  PangleNativeBannerView.m
//  BUADDemo
//
//  Created by bytedance on 2020/4/24.
//  Copyright © 2020 Bytedance. All rights reserved.
//

#import "PangleNativeBannerView.h"
#import <BUAdSDK/BUNativeAdRelatedView.h>
#import <BUFoundation/UIImageView+BUWebCache.h>
#import <BUFoundation/UIImage+BUIcon.h>
#import <BUFoundation/UIView+BUAdditions.h>

#define PangleNative_RGB(r,g,b) [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:1]

@interface PangleNativeBannerView ()

@property (nonatomic, strong) UIImageView *logoImgeView;
@property (nonatomic, strong) UIButton *dislikeButton;
@property (nonatomic, strong) UILabel *titleLable;
@property (nonatomic, strong) UILabel *describeLable;
@property (nonatomic, strong) UIImageView *bannerImg;
@property (nonatomic, strong) UIButton *dowloadButton;
@property (nonatomic, strong) UIImageView *mediaIcon;

@end

@implementation PangleNativeBannerView

- (instancetype)initWithSize:(CGSize)size {
    if (self = [super init]) {
        self.bu_size = size;
        [self buildupView];
    }
    return self;
}

- (void)buildupView {
    self.backgroundColor = [UIColor whiteColor];
        
    self.titleLable = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLable.textAlignment = NSTextAlignmentCenter;
    self.titleLable.font = [UIFont systemFontOfSize:11];
    self.titleLable.textColor = PangleNative_RGB(62,62,62);
    [self addSubview:self.titleLable];
    
    self.describeLable = [[UILabel alloc] initWithFrame:CGRectZero];
    self.describeLable.textAlignment = NSTextAlignmentLeft;
    self.describeLable.font = [UIFont systemFontOfSize:12];
    self.describeLable.textColor = PangleNative_RGB(62,62,62);
    [self addSubview:self.describeLable];
    

    self.dowloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [UIImage bu_compatImageNamed:@"bu_mpNativebanner_download" block:^(UIImage *image) {
        [self->_dowloadButton setImage:image forState:UIControlStateNormal];
    }];
    [self addSubview:self.dowloadButton];
    
    self.bannerImg = [[UIImageView alloc] init];
    self.bannerImg.contentMode =  UIViewContentModeScaleAspectFill;
    self.bannerImg.clipsToBounds = YES;
    [self addSubview:self.bannerImg];
    
    self.mediaIcon = [[UIImageView alloc] init];
    self.mediaIcon.contentMode =  UIViewContentModeScaleAspectFill;
    self.mediaIcon.clipsToBounds = YES;
    self.mediaIcon.layer.cornerRadius = 13.2;
    [self addSubview:self.mediaIcon];

    self.logoImgeView = [[UIImageView alloc] init];
    [UIImage bu_compatImageNamed:kBU_logoAd_oversea block:^(UIImage *image) {
        self->_logoImgeView.image = image;
    }];

    [self addSubview:self.logoImgeView];
    
    self.dislikeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [UIImage bu_compatImageNamed:@"bu_mpNativebanner_close" block:^(UIImage *image) {
        [self->_dislikeButton setImage:image forState:UIControlStateNormal];
    }];
    [self.dislikeButton addTarget:self action:@selector(tapCloseButton) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.dislikeButton];
}


- (void)refreshUIWithAd:(BUNativeAd *_Nonnull)nativeAd{
    if (!nativeAd.data) { return; }
    if (nativeAd.data.imageAry.count) {
        self.nativeAd = nativeAd;
        CGFloat leftMargin = 10;
        BOOL isHeight;
        CGFloat temp = self.bu_size.width / self.bu_size.height < 4 ;
        if (temp && self.bu_height >= 130) {
            isHeight = YES;
        }else{
            isHeight = NO;
        }
        isHeight = YES;
        BUImage *adImage = nativeAd.data.imageAry.firstObject;
        CGFloat contentWidth = CGRectGetWidth(self.bounds);
        if (isHeight) {
            CGFloat widthRatio = self.bu_width / 300.0 ;
            CGFloat heightRatio = self.bu_height / 150.0;
            self.dislikeButton.frame = CGRectMake(contentWidth - 19, 10, 9, 9);
            self.describeLable.frame = CGRectMake(leftMargin, 9 * heightRatio, contentWidth - 10 - 30 , 16.5 * heightRatio);
            CGFloat bannerImgW = 187.0 / 300 * contentWidth;
            self.bannerImg.frame = CGRectMake(leftMargin, CGRectGetMaxY(self.describeLable.frame) + 9.5, bannerImgW * widthRatio, bannerImgW * 105.0/187 * heightRatio);
            self.logoImgeView.frame = CGRectMake(self.bannerImg.bu_x, CGRectGetMaxY(self.bannerImg.frame) -  16, 33, 12);
            CGFloat tempRatio = MIN(widthRatio, heightRatio);
            self.mediaIcon.frame = CGRectMake((self.bu_width - CGRectGetMaxX(self.bannerImg.frame) - 40) * 0.5 + CGRectGetMaxX(self.bannerImg.frame), self.bannerImg.bu_y + 4.5, 40 * tempRatio, 40 * tempRatio);
            
            self.titleLable.frame = CGRectMake(0, CGRectGetMaxY(self.mediaIcon.frame) + 5.5, 90 * widthRatio,15 * heightRatio);
            self.titleLable.bu_centerX = self.mediaIcon.bu_centerX;
            
            self.dowloadButton.frame = CGRectMake(0, CGRectGetMaxY(self.titleLable.frame) + 9, 71 * widthRatio, 25 * heightRatio);
            self.dowloadButton.bu_centerX = self.mediaIcon.bu_centerX;
        }else{
            self.dislikeButton.frame = CGRectMake(contentWidth - 19, 10, 9, 9);
            self.bannerImg.frame = CGRectMake(0, 0, 114.5 / 300 * self.bu_width, self.bu_height);
            self.logoImgeView.frame = CGRectMake(4, CGRectGetMaxY(self.bannerImg.frame) -  15, 33, 12);
            self.mediaIcon.hidden = YES;
            CGFloat titleH = 16.5;
            CGFloat descW =  contentWidth -  (CGRectGetMaxX(self.bannerImg.frame) + 12);
            CGFloat descH = [self getStringHeightWithText:nativeAd.data.AdDescription font:[UIFont systemFontOfSize:11] viewWidth:descW];
            if (descH > 15) {
              descH = 30;
            }
            if (titleH + descH > self.bu_height - 12) {
                descH = 15;
            }
            CGFloat titleY = (self.bu_height - titleH - descH) * 0.5;
            self.titleLable.frame = CGRectMake(CGRectGetMaxX(self.bannerImg.frame) + 12, titleY, contentWidth -  (CGRectGetMaxX(self.bannerImg.frame) + 12) - 40, titleH);
            self.titleLable.textAlignment = NSTextAlignmentLeft;
            self.titleLable.font = [UIFont systemFontOfSize:12];
            self.describeLable.frame = CGRectMake(CGRectGetMaxX(self.bannerImg.frame) + 12, CGRectGetMaxY(self.titleLable.frame), descW , descH);
            self.describeLable.numberOfLines = 2;
            self.describeLable.textAlignment = NSTextAlignmentLeft;
            self.describeLable.textColor = PangleNative_RGB(174,174,174);
            self.describeLable.font = [UIFont systemFontOfSize:11];
            
            self.dowloadButton.hidden = YES;
        }
        
        self.titleLable.text = nativeAd.data.AdTitle;
        self.describeLable.text = nativeAd.data.AdDescription;
        [self.dowloadButton setTitle:nativeAd.data.buttonText forState:UIControlStateNormal];
        if (adImage.imageURL.length) {
            [self.bannerImg sdBu_setImageWithURL:[NSURL URLWithString:adImage.imageURL] placeholderImage:nil];
        }
        if (nativeAd.data.icon.imageURL.length) {
            [self.mediaIcon sdBu_setImageWithURL:[NSURL URLWithString:nativeAd.data.icon.imageURL] placeholderImage:nil];
        }
        [self.nativeAd registerContainer:self    withClickableViews:@[self.titleLable,self.bannerImg,self.describeLable,self.dowloadButton]];
        [self addAccessibilityIdentifier];
    }
}

#pragma mark - private
- (void)tapCloseButton{
    [self removeFromSuperview];
}

- (CGFloat)getStringHeightWithText:(NSString *)text font:(UIFont *)font viewWidth:(CGFloat)width {
    NSDictionary *attrs = @{NSFontAttributeName :font};
    CGSize maxSize = CGSizeMake(width, MAXFLOAT);
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    CGSize size = [text boundingRectWithSize:maxSize options:options attributes:attrs context:nil].size;
    return  ceilf(size.height);
}

#pragma mark addAccessibilityIdentifier
- (void)addAccessibilityIdentifier {
    self.dislikeButton.accessibilityIdentifier = @"banner_close";
    self.logoImgeView.accessibilityIdentifier = @"banner_logo";
}

@end
