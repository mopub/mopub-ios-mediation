#import <VerizonAdsNativePlacement/VerizonAdsNativePlacement.h>
#import <VerizonAdsVerizonNativeController/VerizonAdsVerizonNativeController.h>
#import "MPVerizonNativeAdAdapter.h"
#import "MPNativeAdConstants.h"
#import "MPLogging.h"

NSString * const kVASDisclaimerKey = @"vasdisclaimer";
NSString * const kVASVideoViewKey = @"vasvideoview";

static NSString * const kTitleCompId        = @"title";
static NSString * const kBodyCompId         = @"body";
static NSString * const kCTACompId          = @"callToAction";
static NSString * const kRatingCompId       = @"rating";
static NSString * const kDisclaimerCompId   = @"disclaimer";
static NSString * const kMainImageCompId    = @"mainImage";
static NSString * const kIconImageCompId    = @"iconImage";
static NSString * const kVideoCompId        = @"video";

@interface MPVerizonNativeAdAdapter() <VASNativeAdDelegate>
@property (nonatomic, strong) NSString *siteId;
@property (nonatomic, strong) VASNativeAd *vasNativeAd;
@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *vasAdProperties;
@end

@implementation MPVerizonNativeAdAdapter

- (instancetype)initWithSiteId:(NSString *)siteId
{
    if (self = [super init])
    {
        _siteId = siteId;
    }
    return self;
}

- (void)setupWithVASNativeAd:(VASNativeAd *)vasNativeAd
{
    self.vasNativeAd = vasNativeAd;
    self.vasNativeAd.delegate = self;
    
    self.vasAdProperties = [NSMutableDictionary dictionary];
    
    id<VASComponent> titleComponent = [vasNativeAd component:kTitleCompId];
    if ([titleComponent conformsToProtocol:@protocol(VASNativeTextComponent)]) {
        NSString *titleText = ((id<VASNativeTextComponent>) titleComponent).text;
        if (titleText) {
            self.vasAdProperties[kAdTitleKey] = titleText;
        }
    }
    
    id<VASComponent> bodyComponent = [vasNativeAd component:kBodyCompId];
    if ([bodyComponent conformsToProtocol:@protocol(VASNativeTextComponent)]) {
        NSString *bodyText = ((id<VASNativeTextComponent>) bodyComponent).text;
        if (bodyText) {
            self.vasAdProperties[kAdTextKey] = bodyText;
        }
    }
    
    id<VASComponent> ctaComponent = [vasNativeAd component:kCTACompId];
    if ([ctaComponent conformsToProtocol:@protocol(VASNativeTextComponent)]) {
        NSString *ctaText = ((id<VASNativeTextComponent>) ctaComponent).text;
        if (ctaText) {
            self.vasAdProperties[kAdCTATextKey] = ctaText;
        }
    }
    
    id<VASComponent> ratingComponent = [vasNativeAd component:kRatingCompId];
    if ([ratingComponent conformsToProtocol:@protocol(VASNativeTextComponent)]) {
        NSString *ratingText = ((id<VASNativeTextComponent>) ratingComponent).text;
        if (ratingText) {
            self.vasAdProperties[kAdStarRatingKey] = @(ratingText.integerValue);
        }
    }
    
    id<VASComponent> mainImageComponent = [vasNativeAd component:kMainImageCompId];
    if ([mainImageComponent conformsToProtocol:@protocol(VASViewComponent)]) {
        UIView *mainImageView = ((id<VASViewComponent>) mainImageComponent).view;
        if (mainImageView) {
            self.vasAdProperties[kAdMainMediaViewKey] = mainImageView;
        }
    }
    
    id<VASComponent> iconImageComponent = [vasNativeAd component:kIconImageCompId];
    if ([iconImageComponent conformsToProtocol:@protocol(VASViewComponent)]) {
        UIView *iconView = ((id<VASViewComponent>) iconImageComponent).view;
        if (iconView) {
            self.vasAdProperties[kAdIconImageViewKey] = iconView;
        }
    }
    
    // Verizon Native Properties
    
    id<VASComponent> disclaimerComponent = [vasNativeAd component:kDisclaimerCompId];
    if ([disclaimerComponent conformsToProtocol:@protocol(VASNativeTextComponent)]) {
        NSString *disclaimerTest = ((id<VASNativeTextComponent>) disclaimerComponent).text;
        if (disclaimerTest) {
            self.vasAdProperties[kVASDisclaimerKey] = disclaimerTest;
        }
    }
    
    id<VASComponent> videoComponent = [vasNativeAd component:kVideoCompId];
    if ([videoComponent conformsToProtocol:@protocol(VASViewComponent)]) {
        UIView *videoView = ((id<VASViewComponent>) videoComponent).view;
        if (videoView) {
            self.vasAdProperties[kVASVideoViewKey] = videoView;
        }
    }
}

#pragma mark - MPNativeAdAdapter

- (NSDictionary *)properties
{
    return self.vasAdProperties;
}

- (NSURL *)defaultActionURL
{
    return nil;
}

- (UIView *)mainMediaView
{
    return self.vasAdProperties[kAdMainMediaViewKey];
}

- (UIView *)iconMediaView
{
    return self.vasAdProperties[kAdIconImageViewKey];
}

#pragma mark - Impression and Click Tracking

- (void)displayContentForURL:(NSURL *)URL rootViewController:(UIViewController *)controller
{
    [self.vasNativeAd invokeDefaultAction];
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(self) strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if ([strongSelf.delegate respondsToSelector:@selector(nativeAdDidClick:)]) {
                MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], self.siteId);
                [strongSelf.delegate nativeAdDidClick:strongSelf];
            }
            
            [strongSelf.delegate nativeAdWillPresentModalForAdapter:self];
        }
    });
}

- (void)willAttachToView:(UIView *)view
{
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], self.siteId);
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.siteId);
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], self.siteId);
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], self.siteId);
    
    [self.delegate nativeAdWillLogImpression:self];
    [self.vasNativeAd fireImpression];
}

#pragma mark - VASNativeAdDelegate

- (void)nativeAdClicked:(VASNativeAd *)nativeAd
          withComponent:(id<VASComponent>)component;
{
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(self) strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if ([strongSelf.delegate respondsToSelector:@selector(nativeAdDidClick:)]) {
                MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], self.siteId);
                [strongSelf.delegate nativeAdDidClick:strongSelf];
            }
            
            [strongSelf.delegate nativeAdWillPresentModalForAdapter:self];
        }
    });
}

- (void)nativeAdDidClose:(nonnull VASNativeAd *)nativeAd
{
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], self.siteId);
}

- (void)nativeAdDidFail:(nonnull VASNativeAd *)nativeAd withError:(nonnull VASErrorInfo *)errorInfo
{
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:errorInfo], self.siteId);
}

- (void)nativeAdDidLeaveApplication:(nonnull VASNativeAd *)nativeAd
{
    MPLogAdEvent([MPLogEvent adWillLeaveApplicationForAdapter:NSStringFromClass(self.class)], self.siteId);
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(self) strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf.delegate nativeAdWillLeaveApplicationFromAdapter:strongSelf];
        }
    });
}

- (void)nativeAdEvent:(nonnull VASNativeAd *)nativeAd source:(nonnull NSString *)source eventId:(nonnull NSString *)eventId arguments:(nonnull NSDictionary<NSString *,id> *)arguments
{
    MPLogTrace(@"VAS nativeAdEvent: %@, source: %@, eventId: %@, arguments: %@", nativeAd, source, eventId, arguments);
}

- (nullable UIViewController *)nativeAdPresentingViewController
{
    MPLogTrace(@"VAS native ad presenting VC requested.");
    return [self.delegate viewControllerForPresentingModalView];
}

@end
