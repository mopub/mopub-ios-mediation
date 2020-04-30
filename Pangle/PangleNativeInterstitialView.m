//
//  PangleNativeInterstitialView.m
//  BUDemo
//
//  Created by bytedance on 2020/4/24.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "PangleNativeInterstitialView.h"
#import "UIImageView+AFNetworking.h"
#import <BUAdSDK/BUNativeAdRelatedView.h>
#import "BUDMacros.h"
#import "BUDNormalButton.h"
#import "UIView+Draw.h"
#import "NSString+LocalizedString.h"

static CGSize const dislikeSize = {15, 15};
static CGSize const logoSize = {20, 20};
#define leftEdge 20
#define titleHeight 40

@interface PangleNativeInterstitialView () <BUNativeAdDelegate>
@property (nonatomic, weak) id <PangleNativeInterstitialViewDelegate> delegate;
@property (nonatomic, strong) BUNativeAd *nativeAd;
@property (nonatomic, strong) BUNativeAdRelatedView *relatedView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *whiteBackgroundView;
@property (nonatomic, strong) UIImageView *logoImgeView;
@property (nonatomic, strong) UIButton *dislikeButton;
@property (nonatomic, strong) UILabel *titleLable;
@property (nonatomic, strong) UILabel *describeLable;
@property (nonatomic, strong) UIImageView *interstitialAdView;
@property (nonatomic, strong) UIButton *dowloadButton;
@end

@implementation PangleNativeInterstitialView

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildupView];
}

- (BOOL)showAdFromRootViewController:(UIViewController *)rootViewController delegate:(id <PangleNativeInterstitialViewDelegate>)delegate{
    if (!rootViewController.presentedViewController) {
        self.delegate = delegate;
        [rootViewController presentViewController:self animated:YES completion:^{
            
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
    self.backgroundView.hidden = YES;
    [self.view addSubview:self.backgroundView];
    
    self.whiteBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    self.whiteBackgroundView.backgroundColor = [UIColor whiteColor];
    [self.backgroundView addSubview:self.whiteBackgroundView];
    
    self.titleLable = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLable.textAlignment = NSTextAlignmentLeft;
    self.titleLable.font = [UIFont systemFontOfSize:17];
    [self.whiteBackgroundView addSubview:self.titleLable];
    
    self.describeLable = [[UILabel alloc] initWithFrame:CGRectZero];
    self.describeLable.textAlignment = NSTextAlignmentLeft;
    self.describeLable.font = [UIFont systemFontOfSize:13];
    self.describeLable.textColor = [UIColor lightGrayColor];
    [self.whiteBackgroundView addSubview:self.describeLable];
    
    self.dowloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.dowloadButton.backgroundColor = mainColor;
    self.dowloadButton.layer.cornerRadius = 5;
    self.dowloadButton.clipsToBounds = YES;
    [self.whiteBackgroundView addSubview:self.dowloadButton];
    
    self.interstitialAdView = [[UIImageView alloc] init];
    _interstitialAdView.contentMode =  UIViewContentModeScaleAspectFill;
    _interstitialAdView.clipsToBounds = YES;
    [self.whiteBackgroundView addSubview:_interstitialAdView];
    
    self.relatedView = [[BUNativeAdRelatedView alloc] init];
    self.logoImgeView = self.relatedView.logoImageView;
    [self.whiteBackgroundView addSubview:self.logoImgeView];
    
    self.dislikeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.dislikeButton setImage:[UIImage imageNamed:@"nativeDislike.png"] forState:UIControlStateNormal];
    [self.dislikeButton addTarget:self action:@selector(tapCloseButton) forControlEvents:UIControlEventTouchUpInside];
    [self.backgroundView addSubview:_dislikeButton];
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

- (void)layoutViewsWithimageViewHeight:(CGFloat)imageViewHeight {
    CGFloat whiteViewHeight = titleHeight + imageViewHeight + 10 + titleHeight + 10 + 30;
    self.whiteBackgroundView.frame = CGRectMake(leftEdge, (self.view.height - whiteViewHeight)/2, self.view.width-2*leftEdge, whiteViewHeight);
    
    self.titleLable.frame = CGRectMake(13, 0, self.whiteBackgroundView.width - 2*13 , titleHeight);
    self.describeLable.frame = CGRectMake(0, 0, self.whiteBackgroundView.width - 2*13 , titleHeight);
    self.dowloadButton.frame = CGRectMake(0, 0, 200, 30);
    
    CGFloat margin = 5;
    CGFloat logoIconX = CGRectGetWidth(self.whiteBackgroundView.bounds) - logoSize.width - margin;
    CGFloat logoIconY = self.whiteBackgroundView.height - logoSize.height - margin;
    self.logoImgeView.frame = CGRectMake(logoIconX, logoIconY, logoSize.width, logoSize.height);
    
    self.dislikeButton.frame = CGRectMake(self.whiteBackgroundView.right-dislikeSize.width , self.whiteBackgroundView.top-dislikeSize.height-10, dislikeSize.width, dislikeSize.height);
}

- (void)refreshUIWithAd:(BUNativeAd *_Nonnull)nativeAd{
    if (!nativeAd.data) { return; }
    if (nativeAd.data.imageAry.count) {
        self.titleLable.text = nativeAd.data.AdTitle;
        
        BUImage *adImage = nativeAd.data.imageAry.firstObject;
        CGFloat contentWidth = CGRectGetWidth(self.view.bounds) - 2*leftEdge - 2*5;
        CGFloat imageViewHeight = contentWidth * adImage.height/ adImage.width;
        self.interstitialAdView.frame = CGRectMake(5, titleHeight, contentWidth, imageViewHeight);
        [self layoutViewsWithimageViewHeight:imageViewHeight];
        
        if (adImage.imageURL.length) {
            [self.interstitialAdView setImageWithURL:[NSURL URLWithString:adImage.imageURL] placeholderImage:nil];
        }
        
        self.describeLable.frame = CGRectMake(13, self.interstitialAdView.bottom + 5, self.describeLable.width, self.describeLable.height);
        self.describeLable.text = nativeAd.data.AdDescription;
        
        self.dowloadButton.frame = CGRectMake((self.whiteBackgroundView.width - self.dowloadButton.width)/2, self.describeLable.bottom + 5, self.dowloadButton.width, self.dowloadButton.height);
        [self.dowloadButton setTitle:nativeAd.data.buttonText forState:UIControlStateNormal];
        
        [self.nativeAd registerContainer:self.whiteBackgroundView    withClickableViews:@[self.titleLable,self.interstitialAdView,self.describeLable,self.dowloadButton]];
        [self.relatedView refreshData:nativeAd];
        
        [self addAccessibilityIdentifier];
    }
}

#pragma mark addAccessibilityIdentifier
- (void)addAccessibilityIdentifier {
    self.interstitialAdView.accessibilityIdentifier = @"interaction_view";
    self.relatedView.logoImageView.accessibilityIdentifier = @"interaction_logo";
    self.dislikeButton.accessibilityIdentifier = @"interaction_close";
}


@end
