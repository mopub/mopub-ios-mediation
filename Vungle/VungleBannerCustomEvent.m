//
//  VungleBannerCustomEvent.m
//  MoPubSDK
//
//  Copyright © 2019 MoPub. All rights reserved.
//

#import <VungleSDK/VungleSDK.h>
#import "VungleBannerCustomEvent.h"
#if __has_include("MoPub.h")
    #import "MPLogging.h"
    #import "MoPub.h"
#endif
#import "VungleRouter.h"

@interface VungleBannerCustomEvent () <VungleRouterDelegate>

@property (nonatomic, copy) NSString *placementId;
@property (nonatomic, copy) NSDictionary *options;
@property (nonatomic, assign) NSDictionary *bannerInfo;
@property (nonatomic, assign) NSTimer *timeOutTimer;
@property (nonatomic, assign) BOOL isAdCached;
@property (nonatomic, assign) CGSize bannerSize;

@end

@implementation VungleBannerCustomEvent

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    self.placementId = [info objectForKey:kVunglePlacementIdKey];
    self.options = nil;
    
    NSString *format = [info objectForKey:@"adunit_format"];
    BOOL isMediumRectangleFormat = (format != nil ? [[format lowercaseString] containsString:@"medium_rectangle"] : NO);
    BOOL isBannerFormat = (format != nil ? [[format lowercaseString] containsString:@"banner"] : NO);

    //Vungle only supports Medium Rectangle or Banner
    if (!isMediumRectangleFormat && !isBannerFormat) {
        MPLogInfo(@"Vungle only supports 300*250, 320*50 and 728*90 sized ads. Please ensure your MoPub adunit's format is Medium Rectangle or Banner.");
        NSError *error = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd localizedDescription:@"Invalid sizes received. Vungle only supports 300 x 250, 320 x 50 and 728 x 90 ads."];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.placementId);
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
        
        return;
    }

    self.bannerSize = isMediumRectangleFormat ? kVNGMRECSize : [self sizeForCustomEventInfo:size];
    self.bannerInfo = info;
    self.isAdCached = NO;
    
    self.timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:BANNER_TIMEOUT_INTERVAL repeats:NO block:^(NSTimer * _Nonnull timer) {
        if (!self.isAdCached) {
            [[VungleRouter sharedRouter] clearDelegateForRequestingBanner];
        }
    }];
    
    [[VungleRouter sharedRouter] requestBannerAdWithCustomEventInfo:info size:self.bannerSize delegate:self];
}

- (void) invalidate
{
    [[VungleRouter sharedRouter] invalidateBannerAdViewForPlacementID:self.placementId delegate:self];
}

- (CGSize)sizeForCustomEventInfo:(CGSize)size
{
    CGFloat width = size.width;
    CGFloat height = size.height;

    if (height >= kVNGLeaderboardBannerSize.height && width >= kVNGLeaderboardBannerSize.width) {
        return kVNGLeaderboardBannerSize;
    } else if (height >= kVNGBannerSize.height && width >= kVNGBannerSize.width) {
        return kVNGBannerSize;
    } else if (height >= kVNGShortBannerSize.height && width >= kVNGShortBannerSize.width) {
        return kVNGShortBannerSize;
    } else {
        return kVNGShortBannerSize;
    }
}

#pragma mark - VungleRouterDelegate Methods

- (void)vungleAdDidLoad
{
    if (self.options) {
        self.options = nil;
    }
    
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    
    if (self.localExtras != nil && [self.localExtras count] > 0) {
        NSString *userId = [self.localExtras objectForKey:kVungleUserId];
        if (userId != nil) {
            NSString *userID = userId;
            if (userID.length > 0) {
                options[VunglePlayAdOptionKeyUser] = userID;
            }
        }
        
        NSString *ordinal = [self.localExtras objectForKey:kVungleUserId];
        if (ordinal != nil) {
            NSNumber *ordinalPlaceholder = [NSNumber numberWithLongLong:[ordinal longLongValue]];
            NSUInteger ordinal = ordinalPlaceholder.unsignedIntegerValue;
            
            if (ordinal > 0) {
                options[VunglePlayAdOptionKeyOrdinal] = @(ordinal);
            }
        }
        
        NSString *muted = [self.localExtras objectForKey:kVungleStartMuted];
        if (muted != nil) {
            BOOL startMutedPlaceholder = [muted boolValue];
            options[VunglePlayAdOptionKeyStartMuted] = @(startMutedPlaceholder);
        } else {
            options[VunglePlayAdOptionKeyStartMuted] = @(YES);
        }
    }
    self.options = options.count ? options : nil;
    
    UIView *bannerAdView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bannerSize.width, self.bannerSize.height)];
    
    bannerAdView = [[VungleRouter sharedRouter] renderBannerAdInView:bannerAdView options:self.options forPlacementID:self.placementId size:self.bannerSize];
    
    if (bannerAdView) {
        [[VungleRouter sharedRouter] completeBannerAdViewForPlacementID:self.placementId];
        [self.delegate bannerCustomEvent:self didLoadAd:bannerAdView];
        [self.delegate trackImpression];
        self.isAdCached = YES;
    } else {
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
    }
}

- (void)vungleAdWasTapped
{
    MPLogInfo(@"Vungle video banner was tapped");
    [self.delegate trackClick];
}

- (void)vungleAdDidFailToLoad:(NSError *)error
{
    NSError *loadFailError = nil;
    if (error) {
        loadFailError = error;
        MPLogInfo(@"Vungle video banner failed to load with error: %@", error.localizedDescription);
    }
    
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:loadFailError];
}

- (void)vungleAdWillLeaveApplication
{
    MPLogInfo(@"Vungle video banner will leave the application");
    [self.delegate bannerCustomEventWillLeaveApplication:self];
}

- (NSString *)getPlacementID
{
    return self.placementId;
}

- (CGSize)getBannerSize
{
    return self.bannerSize;
}

@end
