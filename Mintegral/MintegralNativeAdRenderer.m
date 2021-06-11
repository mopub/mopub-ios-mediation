#import <Foundation/Foundation.h>
#import "MintegralNativeAdRenderer.h"
#if __has_include("MoPub.h")
#import "MPLogging.h"
#import "MPNativeAdAdapter.h"
#import "MPNativeAdConstants.h"
#import "MPNativeAdError.h"
#import "MPNativeAdRendererConfiguration.h"
#import "MPNativeAdRendererImageHandler.h"
#import "MPNativeAdRendering.h"
#import "MPNativeAdRenderingImageLoader.h"
#import "MPNativeView.h"
#import "MPStaticNativeAdRendererSettings.h"
#import "MPURLRequest.h"
#import "MPHTTPNetworkSession.h"
#import "MPMemoryCache.h"
#endif
#import "MintegralNativeAdAdapter.h"
#import <MTGSDK/MTGAdChoicesView.h>

@interface MintegralNativeAdRenderer () <MPNativeAdRendererImageHandlerDelegate>

@property (nonatomic, strong) MintegralNativeAdAdapter *adapter;
@property (nonatomic, strong) UIView<MPNativeAdRendering> *adView;
@property (nonatomic, assign) BOOL adViewInViewHierarchy;
@property (nonatomic, strong) Class renderingViewClass;
@property (nonatomic, strong) MPNativeAdRendererImageHandler *rendererImageHandler;

@end

@implementation MintegralNativeAdRenderer

- (instancetype)initWithRendererSettings:(id<MPNativeAdRendererSettings>)rendererSettings
{
    if (self = [super init]) {
        MPStaticNativeAdRendererSettings *settings = (MPStaticNativeAdRendererSettings *)rendererSettings;
        _renderingViewClass = settings.renderingViewClass;
        _viewSizeHandler = [settings.viewSizeHandler copy];
        _rendererImageHandler = [MPNativeAdRendererImageHandler new];
        _rendererImageHandler.delegate = self;
    }
    
    return self;
}

+ (MPNativeAdRendererConfiguration *)rendererConfigurationWithRendererSettings:(id<MPNativeAdRendererSettings>)rendererSettings
{
    MPNativeAdRendererConfiguration *config = [[MPNativeAdRendererConfiguration alloc] init];
    config.rendererClass = [self class];
    config.rendererSettings = rendererSettings;
    config.supportedCustomEvents = @[@"MintegralNativeCustomEvent"];
    
    return config;
}

- (UIView *)retrieveViewWithAdapter:(id<MPNativeAdAdapter>)adapter error:(NSError **)error
{
    if (!adapter || ![adapter isKindOfClass:[MintegralNativeAdAdapter class]]) {
        if (error) {
            *error = MPNativeAdNSErrorForRenderValueTypeError();
        }
        
        return nil;
    }
    
    self.adapter = adapter;
    
    if ([self.renderingViewClass respondsToSelector:@selector(nibForAd)]) {
        self.adView = (UIView<MPNativeAdRendering> *)[[[self.renderingViewClass nibForAd] instantiateWithOwner:nil options:nil] firstObject];
    } else {
        self.adView = [[self.renderingViewClass alloc] init];
    }
    
    self.adView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    
    if ([self.adView respondsToSelector:@selector(nativeMainTextLabel)]) {
        self.adView.nativeMainTextLabel.text = [adapter.properties objectForKey:kAdTextKey];
    }
    
    if ([self.adView respondsToSelector:@selector(nativeTitleTextLabel)]) {
        self.adView.nativeTitleTextLabel.text = [adapter.properties objectForKey:kAdTitleKey];
    }
    
    if ([self.adView respondsToSelector:@selector(nativeCallToActionTextLabel)] && self.adView.nativeCallToActionTextLabel) {
        self.adView.nativeCallToActionTextLabel.text = [adapter.properties objectForKey:kAdCTATextKey];
    }
    
    if ([self.adView respondsToSelector:@selector(nativePrivacyInformationIconImageView)]) {
        
        MTGAdChoicesView *adChoicesView = (MTGAdChoicesView *)adapter.privacyInformationIconView;
        adChoicesView.frame = self.adView.nativePrivacyInformationIconImageView.bounds;
        adChoicesView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.adView.nativePrivacyInformationIconImageView.userInteractionEnabled = YES;
        [self.adView.nativePrivacyInformationIconImageView addSubview:adChoicesView];
        self.adView.nativePrivacyInformationIconImageView.hidden = NO;
    }
    
    if ([self shouldLoadMediaView]) {
        UIView *mediaView = [self.adapter mainMediaView];
        UIView *mainImageView = [self.adView nativeMainImageView];
        
        mediaView.frame = mainImageView.bounds;
        mediaView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        mainImageView.userInteractionEnabled = YES;
        
        [mainImageView addSubview:mediaView];
    }
    
    if ([self.adView respondsToSelector:@selector(layoutStarRating:)]) {
        NSNumber *starRatingNum = [adapter.properties objectForKey:kAdStarRatingKey];
        
        if ([starRatingNum isKindOfClass:[NSNumber class]] && starRatingNum.floatValue >= kStarRatingMinValue && starRatingNum.floatValue <= kStarRatingMaxValue) {
            [self.adView layoutStarRating:starRatingNum];
        }
    }
    return self.adView;
}

- (BOOL)shouldLoadMediaView
{
    return [self.adapter respondsToSelector:@selector(mainMediaView)]
    && [self.adapter mainMediaView]
    && [self.adView respondsToSelector:@selector(nativeMainImageView)];
}

- (BOOL)hasIconView
{
    return [self.adapter respondsToSelector:@selector(iconMediaView)]
    && [self.adapter iconMediaView]
    && [self.adView respondsToSelector:@selector(nativeIconImageView)];
}

- (void)onPrivacyIconTapped
{
    if ([self.adapter respondsToSelector:@selector(displayContentForDAAIconTap)]) {
        [self.adapter displayContentForDAAIconTap];
    }
}

- (void)adViewWillMoveToSuperview:(UIView *)superview
{
    self.adViewInViewHierarchy = (superview != nil);
    if (superview) {
        if (![self hasIconView] && [self.adapter.properties objectForKey:kAdIconImageKey] && [self.adView respondsToSelector:@selector(nativeIconImageView)]) {
            [self.rendererImageHandler loadImageForURL:[NSURL URLWithString:[self.adapter.properties objectForKey:kAdIconImageKey]] intoImageView:self.adView.nativeIconImageView];
        }
        
        if (!([self.adapter respondsToSelector:@selector(mainMediaView)] && [self.adapter mainMediaView])) {
            if ([self.adapter.properties objectForKey:kAdMainImageKey] && [self.adView respondsToSelector:@selector(nativeMainImageView)]) {
                [self.rendererImageHandler loadImageForURL:[NSURL URLWithString:[self.adapter.properties objectForKey:kAdMainImageKey]] intoImageView:self.adView.nativeMainImageView];
            }
        }
        
        if ([self.adView respondsToSelector:@selector(layoutCustomAssetsWithProperties:imageLoader:)]) {
            MPNativeAdRenderingImageLoader *imageLoader = [[MPNativeAdRenderingImageLoader alloc] initWithImageHandler:self.rendererImageHandler];
            [self.adView layoutCustomAssetsWithProperties:self.adapter.properties imageLoader:imageLoader];
        }
    }
}

#pragma mark - MPNativeAdRendererImageHandlerDelegate

- (BOOL)nativeAdViewInViewHierarchy
{
    return self.adViewInViewHierarchy;
}

@end

