#import "MPGoogleAdMobNativeRenderer.h"

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
#endif
#import "MPGoogleAdMobNativeAdAdapter.h"
#import "UIView+MPGoogleAdMobAdditions.h"

@interface MPGoogleAdMobNativeRenderer ()<MPNativeAdRendererImageHandlerDelegate>

/// Publisher adView which is rendering.
@property(nonatomic, strong) UIView<MPNativeAdRendering> *adView;

/// MPGoogleAdMobNativeAdAdapter instance.
@property(nonatomic, strong) MPGoogleAdMobNativeAdAdapter *adapter;

/// YES if adView is in view hierarchy.
@property(nonatomic, assign) BOOL adViewInViewHierarchy;

/// MPNativeAdRendererImageHandler instance.
@property(nonatomic, strong) MPNativeAdRendererImageHandler *rendererImageHandler;

/// Class of renderingViewClass.
@property(nonatomic, strong) Class renderingViewClass;

/// GADUnifiedNativeAdView instance.
@property(nonatomic, strong) GADUnifiedNativeAdView *nativeAdView;

@end

@implementation MPGoogleAdMobNativeRenderer

@synthesize viewSizeHandler;

/// Construct and return an MPNativeAdRendererConfiguration object, you must set all the properties
/// on the configuration object.
+ (MPNativeAdRendererConfiguration *)rendererConfigurationWithRendererSettings:
(id<MPNativeAdRendererSettings>)rendererSettings {
    MPNativeAdRendererConfiguration *config = [[MPNativeAdRendererConfiguration alloc] init];
    config.rendererClass = [self class];
    config.rendererSettings = rendererSettings;
    config.supportedCustomEvents = @[ @"MPGoogleAdMobNativeCustomEvent" ];
    
    return config;
}

/// Renderer settings are objects that allow you to expose configurable properties to the
/// application. MPGoogleAdMobNativeRenderer renderer will be initialized with these settings.
- (instancetype)initWithRendererSettings:(id<MPNativeAdRendererSettings>)rendererSettings {
    if (self = [super init]) {
        MPStaticNativeAdRendererSettings *settings =
        (MPStaticNativeAdRendererSettings *)rendererSettings;
        _renderingViewClass = settings.renderingViewClass;
        viewSizeHandler = [settings.viewSizeHandler copy];
        _rendererImageHandler = [MPNativeAdRendererImageHandler new];
        _rendererImageHandler.delegate = self;
    }
    
    return self;
}

/// Returns an ad view rendered using provided |adapter|. Sets an |error| if any error is
/// encountered.
- (UIView *)retrieveViewWithAdapter:(id<MPNativeAdAdapter>)adapter error:(NSError **)error {
    if (!adapter || ![adapter isKindOfClass:[MPGoogleAdMobNativeAdAdapter class]]) {
        if (error) {
            *error = MPNativeAdNSErrorForRenderValueTypeError();
        }
        
        return nil;
    }
    
    self.adapter = (MPGoogleAdMobNativeAdAdapter *)adapter;
    
    if ([self.renderingViewClass respondsToSelector:@selector(nibForAd)]) {
        self.adView = (UIView<MPNativeAdRendering> *)[
                                                      [[self.renderingViewClass nibForAd] instantiateWithOwner:nil options:nil] firstObject];
    } else {
        self.adView = [[self.renderingViewClass alloc] init];
    }
    
    self.adView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self renderUnifiedNativeAdViewWithAdapter:self.adapter];
    
    return self.adView;
}

/// Creates unified native ad view with adapter. We added GADUnifiedNativeAdView assets on
/// top of MoPub's adView, to track impressions & clicks.
- (void)renderUnifiedNativeAdViewWithAdapter:(id<MPNativeAdAdapter>)adapter {
    // We only load text here. We're creating the GADUnifiedNativeAdView and preparing text
    // assets.
    GADUnifiedNativeAdView *gadUnifiedNativeAdView = [[GADUnifiedNativeAdView alloc] init];
    [self.adView addSubview:gadUnifiedNativeAdView];
    [gadUnifiedNativeAdView gad_fillSuperview];
    
    gadUnifiedNativeAdView.adChoicesView = (GADAdChoicesView *)[self.adapter privacyInformationIconView];
    gadUnifiedNativeAdView.nativeAd = self.adapter.adMobUnifiedNativeAd;
    
    if ([self.adView respondsToSelector:@selector(nativeTitleTextLabel)]) {
        UILabel *headlineView = [[UILabel alloc] initWithFrame:CGRectZero];
        headlineView.text = self.adapter.adMobUnifiedNativeAd.headline;
        headlineView.textColor = [UIColor clearColor];
        gadUnifiedNativeAdView.headlineView = headlineView;
        [self.adView.nativeTitleTextLabel addSubview:headlineView];
        [headlineView gad_fillSuperview];
        self.adView.nativeTitleTextLabel.text = adapter.properties[kAdTitleKey];
    }
    
    if ([self.adView respondsToSelector:@selector(nativeMainTextLabel)]) {
        UILabel *bodyView = [[UILabel alloc] initWithFrame:CGRectZero];
        bodyView.text = self.adapter.adMobUnifiedNativeAd.body;
        bodyView.textColor = [UIColor clearColor];
        gadUnifiedNativeAdView.bodyView = bodyView;
        [self.adView.nativeMainTextLabel addSubview:bodyView];
        [bodyView gad_fillSuperview];
        self.adView.nativeMainTextLabel.text = adapter.properties[kAdTextKey];
    }
    
    if ([self.adView respondsToSelector:@selector(nativeCallToActionTextLabel)] &&
        self.adView.nativeCallToActionTextLabel) {
        UILabel *callToActionView = [[UILabel alloc] initWithFrame:CGRectZero];
        callToActionView.text = self.adapter.adMobUnifiedNativeAd.callToAction;
        callToActionView.textColor = [UIColor clearColor];
        gadUnifiedNativeAdView.callToActionView = callToActionView;
        [self.adView.nativeCallToActionTextLabel addSubview:callToActionView];
        [callToActionView gad_fillSuperview];
        self.adView.nativeCallToActionTextLabel.text = adapter.properties[kAdCTATextKey];
    }
    
    // We delay loading of images until the view is added to the view hierarchy so we don't
    // unnecessarily load images from the cache if the user is scrolling fast. So we will just store
    // the image URLs for now.
    if ([self.adView respondsToSelector:@selector(nativeMainImageView)]) {
        NSString *mainImageURLString = adapter.properties[kAdMainImageKey];
        GADNativeAdImage *nativeAdImage =
        [[GADNativeAdImage alloc] initWithURL:[NSURL URLWithString:mainImageURLString] scale:1];
        UIImageView *mainMediaImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        mainMediaImageView.image = nativeAdImage.image;
        gadUnifiedNativeAdView.imageView = mainMediaImageView;
        [self.adView.nativeMainImageView addSubview:mainMediaImageView];
        [mainMediaImageView gad_fillSuperview];
    }
    
    if ([self.adView respondsToSelector:@selector(nativeIconImageView)]) {
        NSString *iconImageURLString = adapter.properties[kAdIconImageKey];
        GADNativeAdImage *nativeAdImage =
        [[GADNativeAdImage alloc] initWithURL:[NSURL URLWithString:iconImageURLString] scale:1];
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        iconView.image = nativeAdImage.image;
        gadUnifiedNativeAdView.iconView = iconView;
        [self.adView.nativeIconImageView addSubview:iconView];
        [iconView gad_fillSuperview];
    }
    
    // See if the ad contains a star rating and notify the view if it does.
    if ([self.adView respondsToSelector:@selector(layoutStarRating:)]) {
        NSNumber *starRatingNum = adapter.properties[kAdStarRatingKey];
        if ([starRatingNum isKindOfClass:[NSNumber class]] &&
            starRatingNum.floatValue >= kStarRatingMinValue &&
            starRatingNum.floatValue <= kStarRatingMaxValue) {
            [self.adView layoutStarRating:starRatingNum];
        }
    }
    
    // See if the ad contains the nativePrivacyInformationIconImageView and add GADAdChoices view
    // as its subview if it does.
    if ([self.adView respondsToSelector:@selector(nativePrivacyInformationIconImageView)]) {
        [self.adView.nativePrivacyInformationIconImageView
         addSubview:gadUnifiedNativeAdView.adChoicesView];
    }
}

/// Checks whether the ad view contains media.
- (BOOL)shouldLoadMediaView {
    return [self.adapter respondsToSelector:@selector(mainMediaView)] &&
    [self.adapter mainMediaView] &&
    [self.adView respondsToSelector:@selector(nativeMainImageView)];
}

/// Check the ad view is superView or not, if not adView will move to superView.
- (void)adViewWillMoveToSuperview:(UIView *)superview {
    self.adViewInViewHierarchy = (superview != nil);
    
    if (superview) {
        // We'll start asychronously loading the native ad images now.
        if (self.adapter.properties[kAdIconImageKey] &&
            [self.adView respondsToSelector:@selector(nativeIconImageView)]) {
            [self.rendererImageHandler
             loadImageForURL:[NSURL URLWithString:self.adapter.properties[kAdIconImageKey]]
             intoImageView:self.adView.nativeIconImageView];
        }
        
        // Only handle the loading of the main image if the adapter doesn't already have a view for it.
        if (!([self.adapter respondsToSelector:@selector(mainMediaView)] &&
              [self.adapter mainMediaView])) {
            if (self.adapter.properties[kAdMainImageKey] &&
                [self.adView respondsToSelector:@selector(nativeMainImageView)]) {
                [self.rendererImageHandler
                 loadImageForURL:[NSURL URLWithString:self.adapter.properties[kAdMainImageKey]]
                 intoImageView:self.adView.nativeMainImageView];
            }
        }
        
        // Lay out custom assets here as the custom assets may contain images that need to be loaded.
        if ([self.adView respondsToSelector:@selector(layoutCustomAssetsWithProperties:imageLoader:)]) {
            // Create a simplified image loader for the ad view to use.
            MPNativeAdRenderingImageLoader *imageLoader =
            [[MPNativeAdRenderingImageLoader alloc] initWithImageHandler:self.rendererImageHandler];
            [self.adView layoutCustomAssetsWithProperties:self.adapter.properties
                                              imageLoader:imageLoader];
        }
    }
}

#pragma mark - MPNativeAdRendererImageHandlerDelegate

- (BOOL)nativeAdViewInViewHierarchy {
    return self.adViewInViewHierarchy;
}

@end
