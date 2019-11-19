//
//  MintegralNativeAdAdapter.m
//  MoPubSampleApp
//
//  Copyright © 2016年 MoPub. All rights reserved.
//

#import "MintegralNativeAdAdapter.h"
#import <MTGSDK/MTGNativeAdManager.h>
#import <MTGSDK/MTGCampaign.h>
#import <MTGSDK/MTGMediaView.h>
#import <MTGSDK/MTGAdChoicesView.h>

#if __has_include(<MoPubSDKFramework/MPNativeAdConstants.h>)
#import <MoPubSDKFramework/MPNativeAdConstants.h>
#else
#import "MPNativeAdConstants.h"
#endif

NSString *const kMTGVideoAdsEnabledKey = @"video_enabled";

@interface MintegralNativeAdAdapter () <MTGNativeAdManagerDelegate,MTGMediaViewDelegate,MTGMediaViewDelegate>

@property (nonatomic, readonly) MTGNativeAdManager *nativeAdManager;
@property (nonatomic, readonly) MTGCampaign *campaign;
@property (nonatomic) MTGMediaView *mediaView;

@property (nonatomic, strong) NSDictionary *mtgAdProperties;

@property (nonatomic, readwrite, copy) NSString *unitId;

@end
@implementation MintegralNativeAdAdapter

- (instancetype)initWithNativeAds:(NSArray *)nativeAds nativeAdManager:(MTGNativeAdManager *)nativeAdManager withUnitId:(NSString *)unitId videoSupport:(BOOL)videoSupport{

    if (self = [super init]) {
        _nativeAdManager = nativeAdManager;
        _nativeAdManager.delegate = self;
        
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

            _campaign = campaign;
            
            // If video ad is enabled, use mediaView, otherwise use coverImage.
            if (videoSupport) {
                [self mediaView];
            } else {
                if (campaign.imageUrl.length > 0) {
                    [properties setObject:campaign.imageUrl forKey:kAdMainImageKey];
                }
            }

        }
        _nativeAds = nativeAds;
        _mtgAdProperties = properties;
        _unitId = unitId;
        
    }
    return self;
}

-(void)dealloc{

    _nativeAdManager.delegate = nil;
    _nativeAdManager = nil;

    _mediaView.delegate = nil;
    _mediaView = nil;
}


#pragma mark - MVSDK NativeAdManager Delegate

- (void)nativeAdDidClick:(nonnull MTGCampaign *)nativeAd
{
    if ([self.delegate respondsToSelector:@selector(nativeAdDidClick:)]) {
        [self.delegate nativeAdDidClick:self];
    }
}

- (void)nativeAdClickUrlDidEndJump:(nullable NSURL *)finalUrl
                             error:(nullable NSError *)error{
}

- (void)nativeAdImpressionWithType:(MTGAdSourceType)type nativeManager:(nonnull MTGNativeAdManager *)nativeManager{
    if (type == MTGAD_SOURCE_API_OFFER) {
        if ([self.delegate respondsToSelector:@selector(nativeAdWillLogImpression:)]){
            [self.delegate nativeAdWillLogImpression:self];
        }
    }
}

- (void)nativeAdImpressionWithType:(MTGAdSourceType)type mediaView:(MTGMediaView *)mediaView{
    if (type == MTGAD_SOURCE_API_OFFER) {
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
    [self.nativeAdManager registerViewForInteraction:view withCampaign:_campaign];
}

- (UIView *)privacyInformationIconView
{
    if (CGSizeEqualToSize(_campaign.adChoiceIconSize, CGSizeZero)) {
        NSLog(@"adchoice size is 0");
        return nil;
    } else {
        NSLog(@"adchoice size is normal");
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
