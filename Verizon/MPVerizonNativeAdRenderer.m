#import "MPVerizonNativeAdRenderer.h"
#import "MPVerizonNativeAdAdapter.h"
#import "MPNativeAdRendererConfiguration.h"
#import <VerizonAdsSupport/VerizonAdsSupport.h>

@interface MPVerizonNativeAdRenderer () <MPNativeAdRendererImageHandlerDelegate>

@property (nonatomic) UIView<MPNativeAdRendering> *adView;
@property (nonatomic) BOOL adViewInViewHierarchy;
@property (nonatomic) Class renderingViewClass;
@property (nonatomic) MPVerizonNativeAdAdapter *adapter;

@end

@implementation MPVerizonNativeAdRenderer

+ (MPNativeAdRendererConfiguration *)rendererConfigurationWithRendererSettings:(id<MPNativeAdRendererSettings>)rendererSettings
{
    MPNativeAdRendererConfiguration *config = [[MPNativeAdRendererConfiguration alloc] init];
    config.rendererClass = [self class];
    config.rendererSettings = rendererSettings;
    config.supportedCustomEvents = @[@"MPVerizonNativeCustomEvent", @"MillennialNativeCustomEvent"];
    
    return config;
}

- (instancetype)initWithRendererSettings:(id<MPNativeAdRendererSettings>)rendererSettings
{
    if (self = [super init]) {
        MPStaticNativeAdRendererSettings *settings = (MPStaticNativeAdRendererSettings *)rendererSettings;
        _renderingViewClass = settings.renderingViewClass;
        _viewSizeHandler = [settings.viewSizeHandler copy];
    }
    
    return self;
}

- (UIView *)retrieveViewWithAdapter:(id<MPNativeAdAdapter>)adapter error:(NSError *__autoreleasing *)error
{
    if (!adapter || ![adapter isKindOfClass:[MPVerizonNativeAdAdapter class]]) {
        if (error) {
            *error = MPNativeAdNSErrorForRenderValueTypeError();
        }
        
        return nil;
    }
    
    self.adapter = (MPVerizonNativeAdAdapter *)adapter;
    
    [self initAdView];
    
    if ([self.adView respondsToSelector:@selector(nativeTitleTextLabel)]) {
        self.adView.nativeTitleTextLabel.text = [adapter.properties objectForKey:kAdTitleKey];
    }
    
    if ([self.adView respondsToSelector:@selector(nativeMainTextLabel)]) {
        self.adView.nativeMainTextLabel.text = [adapter.properties objectForKey:kAdTextKey];
    }
    
    if ([self.adView respondsToSelector:@selector(nativeCallToActionTextLabel)]) {
        self.adView.nativeCallToActionTextLabel.text = [adapter.properties objectForKey:kAdCTATextKey];
    }
    
    if ([self.adView respondsToSelector:@selector(nativeCallToActionTextLabel)]) {
        self.adView.nativeCallToActionTextLabel.text = [adapter.properties objectForKey:kAdCTATextKey];
    }
    
    if ([self.adView respondsToSelector:@selector(layoutStarRating:)]) {
        NSNumber *starRatingNum = [adapter.properties objectForKey:kAdStarRatingKey];
        
        if ([starRatingNum isKindOfClass:[NSNumber class]] && starRatingNum.floatValue >= kStarRatingMinValue && starRatingNum.floatValue <= kStarRatingMaxValue) {
            [self.adView layoutStarRating:starRatingNum];
        }
    }
    
    if ([self.adView respondsToSelector:@selector(nativeMainImageView)]) {
        UIView *mediaView = [adapter.properties objectForKey:kAdMainMediaViewKey];
        UIView *mainImageView = [self.adView nativeMainImageView];
        
        mediaView.frame = mainImageView.bounds;
        mediaView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        mediaView.userInteractionEnabled = YES;
        mainImageView.userInteractionEnabled = YES;
        
        [mainImageView addSubview:mediaView];
    }
    
    if ([self.adView respondsToSelector:@selector(nativeIconImageView)]) {
        UIView *mediaView = [adapter.properties objectForKey:kAdIconImageKey];
        UIView *iconImageView = [self.adView nativeIconImageView];
        
        mediaView.frame = iconImageView.bounds;
        mediaView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        mediaView.userInteractionEnabled = YES;
        iconImageView.userInteractionEnabled = YES;
        
        [iconImageView addSubview:mediaView];
    }
    
    if ([self.adView respondsToSelector:@selector(nativeVideoView)]) {
        UIView *mediaView = [adapter.properties objectForKey:kVASVideoViewKey];
        UIView *videoView = [self.adView nativeVideoView];
        
        mediaView.frame = videoView.bounds;
        mediaView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        mediaView.userInteractionEnabled = YES;
        videoView.userInteractionEnabled = YES;
        
        [videoView addSubview:mediaView];
    }
    
    // Verizon native does not have privacy icon image, but does provide a disclaimer text under "disclaimer" key in the properties  dictionary which should be handled as custom assets and displayed with the "layoutCustomAssetsWithProperties:imageLoader:" function
    
    self.adView.nativePrivacyInformationIconImageView.userInteractionEnabled = NO;
    self.adView.nativePrivacyInformationIconImageView.hidden = YES;
    
    return self.adView;
}

- (void)adViewWillMoveToSuperview:(UIView *)superview
{
    self.adViewInViewHierarchy = (superview != nil);
    
    if (superview) {
        if ([self.adView respondsToSelector:@selector(layoutCustomAssetsWithProperties:imageLoader:)]) {
            [self.adView layoutCustomAssetsWithProperties:self.adapter.properties imageLoader:nil];
        }
    }
}

- (void)initAdView
{
    if ([self.renderingViewClass respondsToSelector:@selector(nibForAd)]) {
        self.adView = (UIView<MPNativeAdRendering> *)[[[self.renderingViewClass nibForAd]
                                                       instantiateWithOwner:nil options:nil] firstObject];
    } else {
        self.adView = [[self.renderingViewClass alloc] init];
    }
    
    self.adView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
}

#pragma mark - MPNativeAdRendererImageHandlerDelegate

- (BOOL)nativeAdViewInViewHierarchy
{
    return self.adViewInViewHierarchy;
}

@end
