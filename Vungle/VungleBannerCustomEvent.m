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
@property (nonatomic) CGSize bannerSize;

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
    
    //Vungle only supports Medium Rectangle
    if (!isMediumRectangleFormat) {
        MPLogInfo(@"Vungle only supports 300*250 ads. Please ensure your MoPub ad unit format is Medium Rectangle.");
        NSError *error = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd localizedDescription:@"Invalid sizes received. Vungle only supports 300 x 250 ads."];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], nil);
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
        
        return;
    }

    self.bannerSize = kVNGMRECSize;
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

#pragma mark - VungleRouterDelegate Methods

- (void)vungleAdDidLoad
{
    if (self.options) {
        // In the event that options have been updated
        self.options = nil;
    }
    
    /** If you need to play ads with Vungle options, you may modify
     playVungleAdFromRootViewController and create an options dictionary and call
     the playAd:withOptions: method on the Vungle SDK. */
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
    
    UIView *mrecAdView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bannerSize.width, self.bannerSize.height)];
    
    mrecAdView = [[VungleRouter sharedRouter] renderBannerAdInView:mrecAdView options:self.options forPlacementID:self.placementId];
    
    if (mrecAdView) {
        [[VungleRouter sharedRouter] completeBannerAdViewForPlacementID:self.placementId];
        [self.delegate bannerCustomEvent:self didLoadAd:mrecAdView];
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

@end
