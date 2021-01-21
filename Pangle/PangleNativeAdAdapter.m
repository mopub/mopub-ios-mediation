#import "PangleNativeAdAdapter.h"
#import <BUAdSDK/BUNativeAdRelatedView.h>
#if __has_include("MoPub.h")
    #import "MPNativeAd.h"
    #import "MPNativeAdConstants.h"
    #import "MPLogging.h"
#endif

@interface PangleNativeAdAdapter () <BUNativeAdDelegate>
@property (nonatomic, strong) UIView *mediaView;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) BUNativeAdRelatedView *relatedView;
@property (nonatomic, strong) BUNativeAd *nativeAd;
@property (nonatomic, copy) NSString *placementId;
@end

@implementation PangleNativeAdAdapter

- (instancetype)initWithBUNativeAd:(BUNativeAd *)nativeAd placementId:(NSString *)placementId {
    if (self = [super init]) {
        self.nativeAd = nativeAd;
        self.nativeAd.delegate = self;
        [self initViews];
        self.properties = [self nativeAdToDictionary];
        self.placementId = placementId;
    }
    return self;
}

- (void)initViews {
    self.iconView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.nativeAd.data.icon.width, self.nativeAd.data.icon.height)];
    self.iconView.userInteractionEnabled = YES;
    [self setImageViewImage:self.iconView urlString:self.nativeAd.data.icon.imageURL];
    
    self.mediaView = nil;
    self.relatedView = [[BUNativeAdRelatedView alloc] init];
    [self.relatedView refreshData:self.nativeAd];
    
    if (self.nativeAd.data.imageMode == BUFeedVideoAdModeImage ||
        self.nativeAd.data.imageMode == BUFeedVideoAdModePortrait ||
        self.nativeAd.data.imageMode == BUFeedADModeSquareVideo
        ) {
        self.mediaView = self.relatedView.videoAdView;
        self.mediaView.frame = CGRectMake(0, 0, self.nativeAd.data.videoResolutionWidth, self.nativeAd.data.videoResolutionHeight);
    } else {
        UIImageView *imageView = [[UIImageView alloc] init];
        if (self.nativeAd.data.imageAry.count > 0) {
            BUImage *img = self.nativeAd.data.imageAry.firstObject;
            if (img.imageURL.length > 0) {
                imageView.frame = CGRectMake(0, 0, img.width, img.height);
                [self setImageViewImage:imageView urlString:img.imageURL];
            }
        } else {
            if (self.nativeAd.data.icon.imageURL.length > 0) {
                imageView.frame = CGRectMake(0, 0, self.nativeAd.data.icon.width, self.nativeAd.data.icon.height);
                [self setImageViewImage:imageView urlString:self.nativeAd.data.icon.imageURL];
            }
        }
        self.mediaView = imageView;
    }
}

- (NSDictionary *)nativeAdToDictionary {
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:self.nativeAd.data.AdTitle forKey:kAdTitleKey];
    [dictionary setValue:self.nativeAd.data.AdDescription forKey:kAdTextKey];
    [dictionary setValue:self.nativeAd.data.buttonText forKey:kAdCTATextKey];
    [dictionary setValue:self.nativeAd.data.icon.imageURL forKey:kAdIconImageKey];
    [dictionary setValue:@(self.nativeAd.data.score) forKey:kAdStarRatingKey];
    if (self.nativeAd.data.imageAry.count > 0) {
        [dictionary setValue:self.nativeAd.data.imageAry.firstObject.imageURL forKey:kAdMainImageKey];
    }
    [dictionary setValue:self.mediaView forKey:kAdMainMediaViewKey];
    [dictionary setValue:self.nativeAd forKey:@"bu_nativeAd"];
    return [dictionary copy];
}

- (void)setImageViewImage:(UIImageView *)imageView urlString:(NSString *)urlString {
    if (urlString.length > 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [self loadImage:[NSURL URLWithString:urlString]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [imageView setImage:image];
            });
        });
    }
}

- (UIImage *)loadImage:(NSURL *)url {
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData: data];
    return image;
}

#pragma mark - BUNativeAdDelegate
/**
 This method is called when native ad slot has been shown.
 */
- (void)nativeAdDidBecomeVisible:(BUNativeAd *)nativeAd {
    MPLogInfo(@"Pangle nativeAdDidBecomeVisible");
    if ([self.delegate respondsToSelector:@selector(nativeAdWillLogImpression:)]){
        MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], self.placementId);
        MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], self.placementId);
        [self.delegate nativeAdWillLogImpression:self];
    }
}

/**
 This method is called when another controller has been closed.
 @param interactionType : open appstore in app or open the webpage or view video ad details page.
 */
- (void)nativeAdDidCloseOtherController:(BUNativeAd *)nativeAd interactionType:(BUInteractionType)interactionType {
    [self.delegate nativeAdDidDismissModalForAdapter:self];
}

/**
 This method is called when native ad is clicked.
 */
- (void)nativeAdDidClick:(BUNativeAd *)nativeAd withView:(UIView *_Nullable)view {
    MPLogInfo(@"Pangle media nativeAdDidClick");
    if ([self.delegate respondsToSelector:@selector(nativeAdDidClick:)]) {
        MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], self.placementId);
        [self.delegate nativeAdDidClick:self];
        [self.delegate nativeAdWillPresentModalForAdapter:self];
        [self.delegate nativeAdWillLeaveApplicationFromAdapter:self];
    }
}

#pragma mark - <MPNativeAdAdapter>
- (void)willAttachToView:(UIView *)view {
    if (self.nativeAd.data.imageMode == BUFeedVideoAdModeImage) {
        [self.nativeAd registerContainer:view withClickableViews:@[]];
    } else {
        [self.nativeAd registerContainer:view withClickableViews:@[]];
    }
}

- (void)willAttachToView:(UIView *)view withAdContentViews:(NSArray *)adContentViews {
    if (adContentViews.count > 0) {
        if (self.nativeAd.data.imageMode == BUFeedVideoAdModeImage) {
            [self.nativeAd registerContainer:view withClickableViews:adContentViews];
        } else {
            [self.nativeAd registerContainer:view withClickableViews:adContentViews];
        }
    } else {
        [self willAttachToView:view];
    }
}

- (BOOL)enableThirdPartyClickTracking {
    return NO;
}

- (UIView *)mainMediaView {
    return self.mediaView;
}

- (UIView *)iconMediaView {
    return self.iconView;
}

- (UIView *)privacyInformationIconView {
    return self.relatedView.logoADImageView;
}

@end
