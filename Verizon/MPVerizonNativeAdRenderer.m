#import "MPVerizonNativeAdRenderer.h"
#import "MPVerizonNativeAdAdapter.h"
#if __has_include("MoPub.h")
#import "MPNativeAdRendererConfiguration.h"
#endif
#import <VerizonAdsSupport/VerizonAdsSupport.h>
#import <VerizonAdsVerizonNativeController/VerizonAdsVerizonNativeController.h>

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
    config.supportedCustomEvents = @[@"MPVerizonNativeCustomEvent"];
    
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
    
    // Preconditions for `prepareView:` each text component object must be a UILabel as required by <MPNativeAdRendering>,
    // and the text components must conform to <VASNativeTextComponent>
    
    if ([self.adView respondsToSelector:@selector(nativeTitleTextLabel)]) {
        UILabel *titleTextLabel = [self.adView nativeTitleTextLabel];
        id<VASNativeViewComponent> titleTextComponent  = adapter.properties[kTitleCompId];
        if ([titleTextLabel isKindOfClass:[UILabel class]] && [titleTextComponent conformsToProtocol:@protocol(VASNativeTextComponent)]) {
            [(id<VASNativeViewComponent>)titleTextComponent prepareView:titleTextLabel];
        }
    }
    
    if ([self.adView respondsToSelector:@selector(nativeMainTextLabel)]) {
        UILabel *nativeMainTextLabel = [self.adView nativeMainTextLabel];
        id<VASNativeViewComponent> nativeMainTextComponent = adapter.properties[kBodyCompId];
        if ([nativeMainTextLabel isKindOfClass:[UILabel class]] && [nativeMainTextComponent conformsToProtocol:@protocol(VASNativeTextComponent)]) {
            [(id<VASNativeViewComponent>)nativeMainTextComponent prepareView:nativeMainTextLabel];
        }
    }
    
    if ([self.adView respondsToSelector:@selector(nativeCallToActionTextLabel)]) {
        UILabel *nativeCallToActionTextLabel = [self.adView nativeCallToActionTextLabel];
        id<VASNativeViewComponent> nativeCallToActionTextComponent = adapter.properties[kCTACompId];
        if ([nativeCallToActionTextLabel isKindOfClass:[UILabel class]] && [nativeCallToActionTextComponent conformsToProtocol:@protocol(VASNativeTextComponent)]) {
            [(id<VASNativeViewComponent>)nativeCallToActionTextComponent prepareView:nativeCallToActionTextLabel];
        }
    }
    
    // disclaimer is equivalent to sponsoredByCompany
    if ([self.adView respondsToSelector:@selector(nativeSponsoredByCompanyTextLabel)]) {
        UILabel *nativeSponsoredByCompanyTextLabel = [self.adView nativeSponsoredByCompanyTextLabel];
        id<VASNativeViewComponent> nativeDisclaimerTextComponent = adapter.properties[kDisclaimerCompId];
        if ([nativeSponsoredByCompanyTextLabel isKindOfClass:[UILabel class]] && [nativeDisclaimerTextComponent conformsToProtocol:@protocol(VASNativeTextComponent)]) {
            [(id<VASNativeViewComponent>)nativeDisclaimerTextComponent prepareView:nativeSponsoredByCompanyTextLabel];
        }
    }
    
    if ([self.adView respondsToSelector:@selector(layoutStarRating:)]) {
        NSNumber *starRatingNum = [adapter.properties objectForKey:kAdStarRatingKey];
        
        if ([starRatingNum isKindOfClass:[NSNumber class]] && starRatingNum.floatValue >= kStarRatingMinValue && starRatingNum.floatValue <= kStarRatingMaxValue) {
            [self.adView layoutStarRating:starRatingNum];
        }
    }
    
    // Preconditions for `prepareView:` mainImageComponent and iconImageComponent must be a UIImageView as required by <MPNativeAdRendering>,
    // and the iconImageComponent must conform to <VASNativeViewComponent>
    
    if ([self.adView respondsToSelector:@selector(nativeMainImageView)]) {
        UIImageView *mainImageView = [self.adView nativeMainImageView];
        id<VASNativeViewComponent> mainImageComponent  = adapter.properties[kMainImageCompId];
        if ([mainImageView isKindOfClass:[UIImageView class]] && [mainImageComponent conformsToProtocol:@protocol(VASNativeViewComponent)]) {
            [(id<VASNativeViewComponent>)mainImageComponent prepareView:mainImageView];
        }
    }
    
    if ([self.adView respondsToSelector:@selector(nativeIconImageView)]) {
        UIImageView *iconImageView = [self.adView nativeIconImageView];
        id<VASNativeViewComponent> iconImageComponent  = adapter.properties[kIconImageCompId];
        if ([iconImageView isKindOfClass:[UIImageView class]] && [iconImageComponent conformsToProtocol:@protocol(VASNativeViewComponent)]) {
            [(id<VASNativeViewComponent>)iconImageComponent prepareView:iconImageView];
        }
    }
    
    // Verizon native does not have privacy icon image
    self.adView.nativePrivacyInformationIconImageView.userInteractionEnabled = NO;
    self.adView.nativePrivacyInformationIconImageView.hidden = YES;
    
    // `registerContainerView: confirms that all required components have been attached to the container view,
    // and enables viewability rules for firing the 'adImpression` event
    VASNativeAd *nativeAd = adapter.properties[kVASNativeAd];
    [nativeAd registerContainerView:self.adView];
    
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
