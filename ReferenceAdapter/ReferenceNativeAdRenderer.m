//
//  ReferenceNativeAdRenderer.m
//  MoPub-Reference-Adapters
//
//  Created by Kelly Dun on 3/3/21.
//

#import "ReferenceNativeAdRenderer.h"
#import "ReferenceToMoPubNativeAdAdapter.h"
#if __has_include("MoPub.h")
#import "MPNativeAdRendering.h"
#import "MPNativeAdConstants.h"
#import "MPNativeAdError.h"
#import "MPNativeAdRendererConfiguration.h"
#import "MPStaticNativeAdRendererSettings.h"
#import "MPNativeAdRendererImageHandler.h"
#endif

@interface ReferenceNativeAdRenderer() <MPNativeAdRendererImageHandlerDelegate>
@property (nonatomic, strong) ReferenceToMoPubNativeAdAdapter *adapter;
@property (nonatomic, strong) UIView<MPNativeAdRendering>     *adView;
@property (nonatomic, strong) MPNativeAdRendererImageHandler  *rendererImageHandler;
@property (nonatomic, strong) Class                            renderingViewClass;
@end

@implementation ReferenceNativeAdRenderer
#pragma mark - Computed Properties

- (BOOL)shouldLoadMediaView {
    return [self.adapter respondsToSelector:@selector(mainMediaView)]
        && [self.adapter mainMediaView] != nil
        && [self.adView respondsToSelector:@selector(nativeMainImageView)];
}

#pragma mark - MPNativeAdRenderer
// Synthesize the backing storage for the properties specified in the
// `MPNativeAdRenderer` protocol.
@synthesize viewSizeHandler = _viewSizeHandler;

- (instancetype)initWithRendererSettings:(id<MPNativeAdRendererSettings>)rendererSettings {
    if (self = [super init]) {
        MPStaticNativeAdRendererSettings *settings = (MPStaticNativeAdRendererSettings *)rendererSettings;
        _renderingViewClass = settings.renderingViewClass;
        _viewSizeHandler = [settings.viewSizeHandler copy];
        _rendererImageHandler = [MPNativeAdRendererImageHandler new];
        _rendererImageHandler.delegate = self;
    }
    
    return self;
}

+ (MPNativeAdRendererConfiguration *)rendererConfigurationWithRendererSettings:(id<MPNativeAdRendererSettings>)rendererSettings {
    MPNativeAdRendererConfiguration *config = [[MPNativeAdRendererConfiguration alloc] init];
    config.rendererClass = self.class;
    config.rendererSettings = rendererSettings;
    config.supportedCustomEvents = @[@"ReferenceNativeAdapter"];
    
    return config;
}

- (UIView *)retrieveViewWithAdapter:(id<MPNativeAdAdapter>)adapter error:(NSError **)error {
    // Verify that incoming adapter is a type that the renderer can handle.
    if (adapter == nil || [adapter isKindOfClass:ReferenceToMoPubNativeAdAdapter.class] == NO) {
        if (error) {
            *error = MPNativeAdNSErrorForRenderValueTypeError();
        }
        
        return nil;
    }
    
    // Explicit downcast now that we know that the class type is correct.
    self.adapter = (ReferenceToMoPubNativeAdAdapter *)adapter;
    
    // Attach clickthrough geature recognizer.
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onMainMediaViewTapped)];
    [self.adapter.mainMediaView addGestureRecognizer:recognizer];
    self.adapter.mainMediaView.userInteractionEnabled = YES;
    
    // There is no rendering view, just give back the main media view.
    if (self.renderingViewClass == nil) {
        return self.adapter.mainMediaView;
    }
    
    // The rendering view is a nib.
    if ([self.renderingViewClass respondsToSelector:@selector(nibForAd)] == YES) {
        self.adView = (UIView<MPNativeAdRendering> *)[[[self.renderingViewClass nibForAd] instantiateWithOwner:nil options:nil] firstObject];
    }
    // The rendering view is a normal UIView.
    else {
        self.adView = [[self.renderingViewClass alloc] init];
    }
    
    // The rendering view should stretch to the size of its container.
    self.adView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    // Text fields.
    if ([self.adView respondsToSelector:@selector(nativeMainTextLabel)]) {
        self.adView.nativeMainTextLabel.text = [adapter.properties objectForKey:kAdTextKey];
    }
    
    if ([self.adView respondsToSelector:@selector(nativeTitleTextLabel)]) {
        self.adView.nativeTitleTextLabel.text = [adapter.properties objectForKey:kAdTitleKey];
    }
    
    if ([self.adView respondsToSelector:@selector(nativeCallToActionTextLabel)] && self.adView.nativeCallToActionTextLabel) {
        self.adView.nativeCallToActionTextLabel.text = [adapter.properties objectForKey:kAdCTATextKey];
    }
    
    // Main media view
    if (self.shouldLoadMediaView) {
        UIView *mediaView = self.adapter.mainMediaView;
        UIView *mainImageView = self.adView.nativeMainImageView;
        
        mediaView.frame = mainImageView.bounds;
        mainImageView.userInteractionEnabled = YES;
        
        [mainImageView addSubview:mediaView];
    }
    
    return self.adView;
}

- (void)adViewWillMoveToSuperview:(UIView *)superview {
    // Notify that impression was tracked
    [self.adapter.delegate nativeAdWillLogImpression:self.adapter];
}

- (void)nativeAdTapped {
    // no op
}

- (BOOL)nativeAdViewInViewHierarchy {
    return (self.adView.superview != nil);
}

#pragma mark - UITapGestureRecognizer

- (void)onMainMediaViewTapped {
    // Validate there is a URL to clickthrough.
    NSURL *clickthroughURL = self.adapter.defaultActionURL;
    if (clickthroughURL == nil) {
        return;
    }
    
    // Notify that a click occurred.
    [self.adapter.delegate nativeAdDidClick:self.adapter];
    
    // Navigate to the native browser.
    [self.adapter.delegate nativeAdWillLeaveApplicationFromAdapter:self.adapter];
    [UIApplication.sharedApplication openURL:clickthroughURL options:@{} completionHandler:^(BOOL success) {
        // no-op
    }];
}

@end
