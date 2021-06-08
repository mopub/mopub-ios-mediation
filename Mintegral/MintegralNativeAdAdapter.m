#import "MintegralNativeAdAdapter.h"
#import <MTGSDK/MTGNativeAdManager.h>
#import <MTGSDK/MTGBidNativeAdManager.h>
#import <MTGSDK/MTGCampaign.h>
#import <MTGSDK/MTGMediaView.h>
#import <MTGSDK/MTGAdChoicesView.h>

#if __has_include("MoPub.h")
#import "MPNativeAdConstants.h"
#import "MPLogging.h"
#endif

NSString *const kMTGVideoAdsEnabledKey = @"video_enabled";

@interface MintegralNativeAdAdapter () <MTGNativeAdManagerDelegate, MTGMediaViewDelegate, MTGBidNativeAdManagerDelegate>

@property (nonatomic, copy) NSString *adm;
@property (nonatomic, readonly) MTGCampaign *campaign;
@property (nonatomic) MTGMediaView *mediaView;
@property (nonatomic, strong) NSDictionary *mtgAdProperties;
@property (nonatomic, readonly) MTGNativeAdManager *nativeAdManager;
@property (nonatomic, strong) MTGBidNativeAdManager *nativeBidAdManager;
@property (nonatomic, readwrite, copy) NSString *unitId;

@end
@implementation MintegralNativeAdAdapter

- (instancetype)initWithNativeAds:(NSArray *)nativeAds
                  nativeAdManager:(MTGNativeAdManager *)nativeAdManager
                     bidAdManager:(MTGBidNativeAdManager *)bidAdManager
                       withUnitId:(NSString *)unitId{
    if (self = [super init]) {
        if (nativeAdManager) {
            _nativeAdManager = nativeAdManager;
            _nativeAdManager.delegate = self;
        } else if (bidAdManager) {
            _nativeBidAdManager = bidAdManager;
            _nativeBidAdManager.delegate = self;
        }
        
        NSMutableDictionary *properties = [NSMutableDictionary dictionary];
        
        if (nativeAds.count > 0) {
            MTGCampaign *campaign = nativeAds[0];
            [properties setObject:campaign.appName forKey:kAdTitleKey];
            if (campaign.appDesc) {
                [properties setObject:campaign.appDesc forKey:kAdTextKey];
            }
            
            if (campaign.adCall.length > 0) {
                [properties setObject:campaign.adCall forKey:kAdCTATextKey];
            }
            
            if ([campaign valueForKey:@"star"] ) {
                [properties setValue:@([[campaign valueForKey:@"star"] intValue])forKey:kAdStarRatingKey];
            }
            
            if (campaign.iconUrl.length > 0) {
                [properties setObject:campaign.iconUrl forKey:kAdIconImageKey];
            }
            if (campaign.imageUrl.length > 0) {
                [properties setObject:campaign.imageUrl forKey:kAdMainImageKey];
            }
            _campaign = campaign;
            [self mediaView];
        }
        _nativeAds = nativeAds;
        _mtgAdProperties = properties;
        _unitId = unitId;
    }
    return self;
}

-(void)dealloc {
    if (_nativeAdManager) {
        _nativeAdManager.delegate = nil;
        _nativeAdManager = nil;
    }
    
    if (_nativeBidAdManager) {
        _nativeBidAdManager.delegate = nil;
        _nativeBidAdManager = nil;
    }
    
    _mediaView.delegate = nil;
    _mediaView = nil;
}

#pragma mark - MVSDK NativeAdManager Delegate

- (void)nativeAdDidClick:(nonnull MTGCampaign *)nativeAd nativeManager:(nonnull MTGNativeAdManager *)nativeManager
{
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], self.unitId);
    
    if ([self.delegate respondsToSelector:@selector(nativeAdDidClick:)]) {
        [self.delegate nativeAdDidClick:self];
        [self.delegate nativeAdWillPresentModalForAdapter:self];
        [self.delegate nativeAdWillLeaveApplicationFromAdapter:self];
    }
}

- (void)nativeAdDidClick:(MTGCampaign *)nativeAd bidNativeManager:(MTGBidNativeAdManager *)bidNativeManager{
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], self.unitId);
    
    if ([self.delegate respondsToSelector:@selector(nativeAdDidClick:)]) {
        [self.delegate nativeAdDidClick:self];
        [self.delegate nativeAdWillPresentModalForAdapter:self];
        [self.delegate nativeAdWillLeaveApplicationFromAdapter:self];
    }
}

- (void)nativeAdDidClick:(MTGCampaign *)nativeAd mediaView:(MTGMediaView *)mediaView{
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], self.unitId);
    
    if ([self.delegate respondsToSelector:@selector(nativeAdDidClick:)]) {
        [self.delegate nativeAdDidClick:self];
        [self.delegate nativeAdWillPresentModalForAdapter:self];
        [self.delegate nativeAdWillLeaveApplicationFromAdapter:self];
    }
}

- (void)nativeAdImpressionWithType:(MTGAdSourceType)type nativeManager:(nonnull MTGNativeAdManager *)nativeManager{
    if (type == MTGAD_SOURCE_API_OFFER) {
        MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], self.unitId);
        MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], self.unitId);
        
        if ([self.delegate respondsToSelector:@selector(nativeAdWillLogImpression:)]){
            [self.delegate nativeAdWillLogImpression:self];
        }
    }
}

- (void)nativeAdImpressionWithType:(MTGAdSourceType)type bidNativeManager:(MTGBidNativeAdManager *)bidNativeManager{
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], self.unitId);
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], self.unitId);
    
    if ([self.delegate respondsToSelector:@selector(nativeAdWillLogImpression:)]){
        [self.delegate nativeAdWillLogImpression:self];
    }
}

- (void)nativeAdImpressionWithType:(MTGAdSourceType)type mediaView:(MTGMediaView *)mediaView{
    if (type == MTGAD_SOURCE_API_OFFER) {
        MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], self.unitId);
        MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], self.unitId);
        
        if ([self.delegate respondsToSelector:@selector(nativeAdWillLogImpression:)]){
            [self.delegate nativeAdWillLogImpression:self];
        }
    }
}

#pragma mark - MPNativeAdAdapter
- (NSDictionary *)properties {
    return _mtgAdProperties;
}

- (NSURL *)defaultActionURL {
    return nil;
}

- (BOOL)enableThirdPartyClickTracking
{
    return YES;
}

- (void)willAttachToView:(UIView *)view
{
    if (_mediaView) {
        UIView *sView = _mediaView.superview;
        [sView.superview bringSubviewToFront:sView];
    }
    
    if (_nativeAdManager) {
        [self.nativeAdManager registerViewForInteraction:view withCampaign:_campaign];
    } else if (_nativeBidAdManager){
        [self.nativeBidAdManager registerViewForInteraction:view withCampaign:_campaign];
    }
}

- (UIView *)privacyInformationIconView
{
    if (CGSizeEqualToSize(_campaign.adChoiceIconSize, CGSizeZero)) {
        return nil;
    } else {
        MTGAdChoicesView * adChoicesView = [[MTGAdChoicesView alloc] initWithFrame:CGRectMake(0, 0, _campaign.adChoiceIconSize.width, _campaign.adChoiceIconSize.height)];
        adChoicesView.campaign = _campaign;
        
        return adChoicesView;
    }
}

- (UIView *)mainMediaView
{
    [_mediaView setMediaSourceWithCampaign:_campaign unitId:_unitId];
    return _mediaView;
}

-(MTGMediaView *)mediaView{
    if (_mediaView) {
        return _mediaView;
    }
    
    MTGMediaView *mediaView = [[MTGMediaView alloc] initWithFrame:CGRectZero];
    mediaView.delegate = self;
    _mediaView = mediaView;
    
    return mediaView;
}

@end
