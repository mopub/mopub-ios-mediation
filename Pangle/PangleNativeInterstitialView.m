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


static CGSize const dislikeSize = {24, 24};
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
    self.titleLable.textAlignment = NSTextAlignmentLeft;
    self.titleLable.font = [UIFont systemFontOfSize:17];
    [self.whiteBackgroundView addSubview:self.titleLable];
    
    self.describeLable = [[UILabel alloc] initWithFrame:CGRectZero];
    self.describeLable.textAlignment = NSTextAlignmentLeft;
    self.describeLable.font = [UIFont systemFontOfSize:13];
    self.describeLable.textColor = [UIColor lightGrayColor];
    [self.whiteBackgroundView addSubview:self.describeLable];
    
    self.dowloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.dowloadButton.backgroundColor = [UIColor colorWithRed:(0xff/255.0) green:(0x63/255.0) blue:(0x5c/255.0) alpha:1];
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
    [UIImage bu_compatImageNamed:kBU_fullClose block:^(UIImage *image) {
        [self->_dislikeButton setImage:image forState:UIControlStateNormal];
    }];
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
    self.whiteBackgroundView.frame = CGRectMake(leftEdge, (self.view.bu_height - whiteViewHeight)/2, self.view.bu_width-2*leftEdge, whiteViewHeight);
    
    self.titleLable.frame = CGRectMake(13, 0, self.whiteBackgroundView.bu_width - 2*13 , titleHeight);
    self.describeLable.frame = CGRectMake(0, 0, self.whiteBackgroundView.bu_width - 2*13 , titleHeight);
    self.dowloadButton.frame = CGRectMake(0, 0, 200, 30);
    
    CGFloat margin = 5;
    CGFloat logoIconX = CGRectGetWidth(self.whiteBackgroundView.bounds) - logoSize.width - margin;
    CGFloat logoIconY = self.whiteBackgroundView.bu_height - logoSize.height - margin;
    self.logoImgeView.frame = CGRectMake(logoIconX, logoIconY, logoSize.width, logoSize.height);
    
    self.dislikeButton.frame = CGRectMake(self.whiteBackgroundView.bu_right-dislikeSize.width , self.whiteBackgroundView.top-dislikeSize.height-10, dislikeSize.width, dislikeSize.height);
}

- (void)refreshUIWithAd:(BUNativeAd *_Nonnull)nativeAd{
    if (!nativeAd.data) { return; }
    if (nativeAd.data.imageAry.count) {
        self.titleLable.text = nativeAd.data.AdTitle;
        self.nativeAd = nativeAd;
        BUImage *adImage = nativeAd.data.imageAry.firstObject;
        CGFloat contentWidth = CGRectGetWidth(self.view.bounds) - 2*leftEdge - 2*5;
        CGFloat imageViewHeight = contentWidth * adImage.height/ adImage.width;
        self.interstitialAdView.frame = CGRectMake(5, titleHeight, contentWidth, imageViewHeight);
        [self layoutViewsWithimageViewHeight:imageViewHeight];
        
        if (adImage.imageURL.length) {
            [self.interstitialAdView sdBu_setImageWithURL:[NSURL URLWithString:adImage.imageURL] placeholderImage:nil];
        }
        
        self.describeLable.frame = CGRectMake(13, self.interstitialAdView.bu_bottom + 5, self.describeLable.bu_width, self.describeLable.bu_height);
        self.describeLable.text = nativeAd.data.AdDescription;
        
        self.dowloadButton.frame = CGRectMake((self.whiteBackgroundView.bu_width - self.dowloadButton.bu_width)/2, self.describeLable.bu_bottom + 5, self.dowloadButton.bu_width, self.dowloadButton.bu_height);
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
