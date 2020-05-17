//
//  PangleNativeInterstitialView.m
//  BUDemo
//
//  Created by bytedance on 2020/4/24.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "PangleNativeInterstitialView.h"
#import <BUFoundation/UIImageView+BUWebCache.h>
#import <BUAdSDK/BUNativeAdRelatedView.h>
#import <BUFoundation/UIView+BUAdditions.h>
#import <BUFoundation/UIImage+BUIcon.h>


@interface PangleNativeInterstitialView () <BUNativeAdDelegate>
@property (nonatomic, weak) id <PangleNativeInterstitialViewDelegate> delegate;
@property (nonatomic, strong) BUNativeAd *nativeAd;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *whiteBackgroundView;
@property (nonatomic, strong) UIImageView *logoImgeView;
@property (nonatomic, strong) UIButton *dislikeButton;
@property (nonatomic, strong) UILabel *titleLable;
@property (nonatomic, strong) UILabel *describeLable;
@property (nonatomic, strong) UIImageView *interstitialAdView;
@property (nonatomic, strong) UIButton *dowloadButton;
@property (nonatomic, strong) UIImageView *mediaIcon;
@property (nonatomic, strong) UIView *starView;

@end

@implementation PangleNativeInterstitialView

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildupView];
}

- (BOOL)showAdFromRootViewController:(UIViewController *)rootViewController delegate:(id <PangleNativeInterstitialViewDelegate>)delegate{
    if (!rootViewController.presentedViewController) {
        self.delegate = delegate;
        self.nativeAd.rootViewController = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
        [rootViewController presentViewController:self animated:NO completion:^{
            
        }];
        return YES;
    }
    return NO;
}

- (void)buildupView {
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    self.backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    self.backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    [self.view addSubview:self.backgroundView];
    
    self.whiteBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    self.whiteBackgroundView.backgroundColor = [UIColor whiteColor];
    [self.backgroundView addSubview:self.whiteBackgroundView];
    
    self.titleLable = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLable.textAlignment = NSTextAlignmentCenter;
    self.titleLable.font = [UIFont systemFontOfSize:18];
    self.titleLable.textColor = [UIColor blackColor];
    [self.whiteBackgroundView addSubview:self.titleLable];
    
    self.describeLable = [[UILabel alloc] initWithFrame:CGRectZero];
    self.describeLable.textAlignment = NSTextAlignmentCenter;
    self.describeLable.font = [UIFont systemFontOfSize:14];
    self.describeLable.numberOfLines = 2;
    self.describeLable.textColor = [UIColor blackColor];
    [self.whiteBackgroundView addSubview:self.describeLable];
    

    self.dowloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CAGradientLayer *dowloadButtonLayer = [CAGradientLayer layer];
    dowloadButtonLayer.frame = CGRectMake(0,0,280,38);
    dowloadButtonLayer.startPoint = CGPointMake(0.92, 0.11);
    dowloadButtonLayer.endPoint = CGPointMake(0, 1);
    dowloadButtonLayer.colors = @[(__bridge id)[UIColor colorWithRed:240/255.0 green:45/255.0 blue:66/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:252/255.0 green:75/255.0 blue:60/255.0 alpha:1.0].CGColor];
    dowloadButtonLayer.locations = @[@(0), @(1.0f)];
    [self.dowloadButton.layer addSublayer:dowloadButtonLayer];
    self.dowloadButton.layer.cornerRadius = 19;
    self.dowloadButton.layer.cornerRadius = 5;
    self.dowloadButton.clipsToBounds = YES;
    [self.whiteBackgroundView addSubview:self.dowloadButton];
    
    self.interstitialAdView = [[UIImageView alloc] init];
    _interstitialAdView.contentMode =  UIViewContentModeScaleAspectFill;
    _interstitialAdView.clipsToBounds = YES;
    [self.whiteBackgroundView addSubview:_interstitialAdView];
    
    self.mediaIcon = [[UIImageView alloc] init];
    self.mediaIcon.contentMode =  UIViewContentModeScaleAspectFill;
    self.mediaIcon.clipsToBounds = YES;
    self.mediaIcon.layer.cornerRadius = 13.2;
    [self.whiteBackgroundView addSubview:self.mediaIcon];

    self.logoImgeView = [[UIImageView alloc] init];
    [UIImage bu_compatImageNamed:kBU_logoAd_oversea block:^(UIImage *image) {
        self->_logoImgeView.image = image;
    }];

    [self.whiteBackgroundView addSubview:self.logoImgeView];
    
    self.dislikeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [UIImage bu_compatImageNamed:kBU_fullClose block:^(UIImage *image) {
        [self->_dislikeButton setImage:image forState:UIControlStateNormal];
    }];
    [self.dislikeButton addTarget:self action:@selector(tapCloseButton) forControlEvents:UIControlEventTouchUpInside];
    self.dislikeButton.imageEdgeInsets = UIEdgeInsetsMake(12.5, 12.5, 12.5, 12.5);
    [self.backgroundView addSubview:_dislikeButton];
}

- (void)refreshUIWithAd:(BUNativeAd *_Nonnull)nativeAd{
    if (!nativeAd.data) { return; }
    if (nativeAd.data.imageAry.count) {
        self.nativeAd = nativeAd;
        
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        BOOL isPortrait = screenSize.height > screenSize.width ? YES : NO;
        
        BUImage *adImage = nativeAd.data.imageAry.firstObject;

        CGFloat contentWidth = CGRectGetWidth(self.view.bounds);
        CGFloat imageViewHeight = contentWidth * adImage.height/ adImage.width;
        
        if (isPortrait) {
            self.dislikeButton.frame = CGRectMake(contentWidth - 40, 10, 40, 40);
            self.interstitialAdView.frame = CGRectMake(0, 0, contentWidth, imageViewHeight);
            self.logoImgeView.frame = CGRectMake(0, CGRectGetMaxY(self.interstitialAdView.frame) -  14.4, 35.6, 14.4);
            CGFloat ratio = [UIScreen mainScreen].bounds.size.width / 320.0;
            self.mediaIcon.frame = CGRectMake(0, CGRectGetMaxY(self.interstitialAdView.frame) + 33, 65 * ratio, 65 * ratio);
            self.mediaIcon.bu_centerX = self.view.bu_centerX;
            
            self.titleLable.frame = CGRectMake(0, CGRectGetMaxY(self.mediaIcon.frame) + 17, contentWidth , 20);
            [self.view addSubview:self.starView];
            self.starView.frame = CGRectMake(0, CGRectGetMaxY(self.titleLable.frame) + 7, 71, 11);
            self.starView.bu_centerX = self.view.bu_centerX;

            CGFloat descH = [self getStringHeightWithText:nativeAd.data.AdDescription font:[UIFont systemFontOfSize:14] viewWidth:contentWidth];
            if (descH > 20) {
                descH = 35;
            }
            self.describeLable.frame = CGRectMake(0, CGRectGetMaxY(self.starView.frame) + 13, contentWidth , descH);
            self.describeLable.bu_centerX = self.view.bu_centerX;
            
            self.dowloadButton.frame = CGRectMake(0, CGRectGetMaxY(self.describeLable.frame) + 54, 280, 38);
            self.dowloadButton.bu_centerX = self.view.bu_centerX;
            self.whiteBackgroundView.frame = CGRectMake(0, 0, self.view.bu_width, self.view.bu_height);

            self.titleLable.text = nativeAd.data.AdTitle;

        }else{
            CGFloat leftMargin = 12;
            self.dislikeButton.frame = CGRectMake(contentWidth - 40 - 7.5, 7.5, 40, 40);
            CGFloat bigImgBottom = 69 / 320.0 * self.view.bu_height;
            self.interstitialAdView.frame = CGRectMake(leftMargin, leftMargin, contentWidth - leftMargin * 2, self.view.bu_height - bigImgBottom - leftMargin);
            self.logoImgeView.frame = CGRectMake(leftMargin, CGRectGetMaxY(self.interstitialAdView.frame) -  14.4, 35.6, 14.4);
            CGFloat ratio = [UIScreen mainScreen].bounds.size.width / 480.0;
            self.mediaIcon.frame = CGRectMake(leftMargin, CGRectGetMaxY(self.interstitialAdView.frame) + 13, 42.68 * ratio, 42.68 * ratio);
            
            self.titleLable.frame = CGRectMake(CGRectGetMaxX(self.mediaIcon.frame) + 9, CGRectGetMaxY(self.interstitialAdView.frame) + 17, contentWidth -  (CGRectGetMaxX(self.mediaIcon.frame) + 9) - 125, 20);
            self.titleLable.textAlignment = NSTextAlignmentLeft;
            self.titleLable.bu_centerY = self.mediaIcon.bu_centerY;
            self.describeLable.hidden = YES;
            
            self.dowloadButton.frame = CGRectMake(CGRectGetMaxX(self.titleLable.frame) + 10, 0, 103, 36);
            self.dowloadButton.bu_centerY = self.mediaIcon.bu_centerY;
            self.whiteBackgroundView.frame = CGRectMake(0, 0, self.view.bu_width, self.view.bu_height);
            
            self.titleLable.text = nativeAd.data.AdDescription;
        }
        
        self.describeLable.text = nativeAd.data.AdDescription;
        [self.dowloadButton setTitle:nativeAd.data.buttonText forState:UIControlStateNormal];
        if (adImage.imageURL.length) {
            [self.interstitialAdView sdBu_setImageWithURL:[NSURL URLWithString:adImage.imageURL] placeholderImage:nil];
        }
        if (nativeAd.data.icon.imageURL.length) {
            [self.mediaIcon sdBu_setImageWithURL:[NSURL URLWithString:nativeAd.data.icon.imageURL] placeholderImage:nil];
        }
        [self.nativeAd registerContainer:self.whiteBackgroundView    withClickableViews:@[self.titleLable,self.interstitialAdView,self.describeLable,self.dowloadButton]];
        [self addAccessibilityIdentifier];

    }
}

#pragma mark - private
- (void)tapCloseButton{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeInterstitialAdWillClose:)]) {
        [self.delegate nativeInterstitialAdWillClose:self.nativeAd];
    }
    [self dismissViewControllerAnimated:NO completion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(nativeInterstitialAdDidClose:)]) {
            [self.delegate nativeInterstitialAdDidClose:self.nativeAd];
        }
    }];
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
    self.interstitialAdView.accessibilityIdentifier = @"interaction_view";
    self.dislikeButton.accessibilityIdentifier = @"interaction_close";
}


- (UIView *)starView
{
    if (!_starView) {
        _starView = [[UIView alloc] init];
        _starView.backgroundColor = [UIColor clearColor];
        CGFloat x = 0;
        for (int i = 0; i < 5; i++) {
            CGFloat starWidth = 11;
            x = (starWidth + 4) * i;
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 0, starWidth, starWidth)];
            imgView.backgroundColor = [UIColor clearColor];
            NSInteger starCount = self.nativeAd.data.score ?: 4;// 产品定义默认星级
            if (i < starCount) {
                imgView.image = [UIImage bu_compatImageNamed:@"bu_adStar"];
            } else {
                imgView.image = [UIImage bu_compatImageNamed:@"bu_adStarEmpty"];
            }
            [_starView addSubview:imgView];
        }
    }
    return _starView;
}


@end
