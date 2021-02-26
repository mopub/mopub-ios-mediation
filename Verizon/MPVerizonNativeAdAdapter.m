#import <VerizonAdsNativePlacement/VerizonAdsNativePlacement.h>
#import <VerizonAdsVerizonNativeController/VerizonAdsVerizonNativeController.h>
#import "MPVerizonNativeAdAdapter.h"
#import "VerizonAdapterConfiguration.h"
#if __has_include("MoPub.h")
#import "MPNativeAdConstants.h"
#import "MPLogging.h"
#endif

NSString * const kVASNativeAd       = @"vasNativeAd";
NSString * const kTitleCompId       = @"title";
NSString * const kBodyCompId        = @"body";
NSString * const kCTACompId         = @"callToAction";
NSString * const kRatingCompId      = @"rating";
NSString * const kDisclaimerCompId  = @"disclaimer";
NSString * const kMainImageCompId   = @"mainImage";
NSString * const kIconImageCompId   = @"iconImage";

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
    
    self.vasAdProperties[kVASNativeAd] = self.vasNativeAd;
    
    id<VASComponent> titleComponent = [vasNativeAd component:kTitleCompId];
    if ([titleComponent conformsToProtocol:@protocol(VASNativeTextComponent)]) {
        self.vasAdProperties[kTitleCompId] = titleComponent;
    }

    id<VASComponent> bodyComponent = [vasNativeAd component:kBodyCompId];
    if ([bodyComponent conformsToProtocol:@protocol(VASNativeTextComponent)]) {
        self.vasAdProperties[kBodyCompId] = bodyComponent;
    }
    
    id<VASComponent> ctaComponent = [vasNativeAd component:kCTACompId];
    if ([ctaComponent conformsToProtocol:@protocol(VASNativeTextComponent)]) {
        self.vasAdProperties[kCTACompId] = ctaComponent;
    }
    
    id<VASComponent> ratingComponent = [vasNativeAd component:kRatingCompId];
    if ([ratingComponent conformsToProtocol:@protocol(VASNativeTextComponent)]) {
        NSString *ratingText = ((id<VASNativeTextComponent>) ratingComponent).text;
        if (ratingText) {
            self.vasAdProperties[kAdStarRatingKey] = @(ratingText.integerValue);
        }
    }
    
    id<VASComponent> disclaimerComponent = [vasNativeAd component:kDisclaimerCompId];
    if ([disclaimerComponent conformsToProtocol:@protocol(VASNativeTextComponent)]) {
        self.vasAdProperties[kDisclaimerCompId] = disclaimerComponent;
    }
  
    id<VASComponent> mainImageComponent = [vasNativeAd component:kMainImageCompId];
    if ([mainImageComponent conformsToProtocol:@protocol(VASViewComponent)]) {
        self.vasAdProperties[kMainImageCompId] = mainImageComponent;
    }
    
    id<VASComponent> iconImageComponent = [vasNativeAd component:kIconImageCompId];
    if ([iconImageComponent conformsToProtocol:@protocol(VASViewComponent)]) {
        self.vasAdProperties[kIconImageCompId] = iconImageComponent;
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

- (void)nativeAd:(nonnull VASNativeAd *)nativeAd event:(nonnull NSString *)eventId source:(nonnull NSString *)source arguments:(nonnull NSDictionary<NSString *,id> *)arguments
{
    MPLogTrace(@"VAS nativeAdEvent: %@, source: %@, eventId: %@, arguments: %@", nativeAd, source, eventId, arguments);
    
    if ([eventId isEqualToString:kMoPubVASAdImpressionEventId]) {
      __weak __typeof__(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong __typeof__(self) strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [strongSelf.delegate nativeAdWillLogImpression:strongSelf];
            }
        });
    }
}

- (nullable UIViewController *)nativeAdPresentingViewController
{
    MPLogTrace(@"VAS native ad presenting VC requested.");
    return [self.delegate viewControllerForPresentingModalView];
}

@end
