//
//  VungleBannerCustomEvent.m
//  VungleMoPubAdapter
//
//  Created by Clarke Bishop on 9/24/18.
//  Copyright © 2018 Vungle. All rights reserved.
//

#import <VungleSDK/VungleSDK.h>
#import "VungleBannerCustomEvent.h"
#if __has_include("MoPub.h")
    #import "MPLogging.h"
    #import "MoPub.h"
#endif
#import "VungleRouter.h"

// If you need to play ads with vungle options, you may modify playVungleAdFromRootViewController and create an options dictionary and call the playAd:withOptions: method on the vungle SDK.

static const CGFloat kVGNMoPubMRECWidthFor280Height = 336.0f;

@interface VungleBannerCustomEvent () <VungleRouterDelegate>

@property (nonatomic, copy) NSString *placementId;
@property (nonatomic, copy) NSDictionary *options;
@property (nonatomic) CGSize bannerSize;
@property (nonatomic, assign) NSDictionary *bannerInfo;
@property (nonatomic, assign) NSTimer *timeOutTimer;
@property (nonatomic, assign) BOOL isAdCached;

@end

@implementation VungleBannerCustomEvent

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    self.placementId = [info objectForKey:kVunglePlacementIdKey];
    self.options = nil;
    
    // Since MoPub supports two sizes MREC Ad (300 x 250 and 336 x 280)),
    // if they pass 336 x 280 size, we will convert it to 300 x 250 size
    if (CGSizeEqualToSize(size, CGSizeMake(kVGNMoPubMRECWidthFor280Height, kMPPresetMaxAdSize280Height.height))) {
        size = kVGNMRECSize;
    }
    self.bannerSize = size;
    self.bannerInfo = info;
    self.isAdCached = NO;
    
    self.timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:BANNER_TIMEOUT_INTERVAL repeats:NO block:^(NSTimer * _Nonnull timer) {
        if (!self.isAdCached) {
            [[VungleRouter sharedRouter] clearDelegateForRequestingBanner];
        }
    }];
    
    [[VungleRouter sharedRouter] requestBannerAdWithCustomEventInfo:info size:size delegate:self];
}

- (void)dealloc {
    // call router event to transmit close to SDK for report ad finalization / clean up
//    [[VungleRouter sharedRouter] completeBannerAdViewForPlacementID:self.placementId];
}

#pragma mark - VungleRouterDelegate Methods

- (void)vungleAdDidLoad
{
        if (self.options) {
            // In the event that options have been updated
            self.options = nil;
        }

        NSMutableDictionary *options = [NSMutableDictionary dictionary];

        // VunglePlayAdOptionKeyUser
        if ([self.localExtras objectForKey:kVungleUserId]) {
            NSString *userID = [self.localExtras objectForKey:kVungleUserId];
            if (userID.length > 0) {
                options[VunglePlayAdOptionKeyUser] = userID;
            }
        }

        // Ordinal
        if ([self.localExtras objectForKey:kVungleOrdinal]) {
            NSNumber *ordinalPlaceholder = [NSNumber numberWithLongLong:[[self.localExtras objectForKey:kVungleOrdinal] longLongValue]];
            NSUInteger ordinal = ordinalPlaceholder.unsignedIntegerValue;
            if (ordinal > 0) {
                options[VunglePlayAdOptionKeyOrdinal] = @(ordinal);
            }
        }

        // Start Muted
        if ([self.localExtras objectForKey:kVungleStartMuted]) {
            BOOL startMutedPlaceholder = [[self.localExtras objectForKey:kVungleStartMuted] boolValue];
            options[VunglePlayAdOptionKeyStartMuted] = @(startMutedPlaceholder);
        } else {
            // Set mrec ad start-muted as default unless a user set.
            options[VunglePlayAdOptionKeyStartMuted] = @(NO);
        }

        self.options = options.count ? options : nil;

        // generate view with size
        UIView *mrecAdView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bannerSize.width, self.bannerSize.height)];

        // router call to add ad view to view - should return the updated view.
        mrecAdView = [[VungleRouter sharedRouter] renderBannerAdInView:mrecAdView options:self.options forPlacementID:self.placementId];
        // if a view is returned, then we hit the methods below.
        if (mrecAdView) {
            // call router event to transmit close to SDK for report ad finalization / clean up
            [[VungleRouter sharedRouter] completeBannerAdViewForPlacementID:self.placementId];
            [self.delegate bannerCustomEvent:self didLoadAd:mrecAdView];
            self.isAdCached = YES;
        } else {
            [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
        }
}

- (void)vungleAdWillAppear
{
    MPLogInfo(@"Vungle video banner will appear");
}

- (void)vungleAdDidAppear {
    MPLogInfo(@"Vungle video banner did appear");
}

- (void)vungleAdWillDisappear
{
    MPLogInfo(@"Vungle video banner will disappear");
}

- (void)vungleAdDidDisappear
{
    MPLogInfo(@"Vungle video banner did disappear");
}

- (void)vungleAdWasTapped
{
    MPLogInfo(@"Vungle video banner was tapped");
}

- (void)vungleAdDidFailToLoad:(NSError *)error
{
    NSError *loadFailError = nil;
    if(error) {
        loadFailError = error;
        MPLogInfo(@"Vungle video banner failed to load with error: %@", error.localizedDescription);
    }

    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:loadFailError];
}

- (void)vungleAdDidFailToPlay:(NSError *)error
{
    // verify - is this necessary?
    MPLogInfo(@"Vungle video banner failed to play with error: %@", error.localizedDescription);
}

- (void)vungleAdWillLeaveApplication {
    MPLogInfo(@"Vungle video banner will leave the application");
    [self.delegate bannerCustomEventWillLeaveApplication:self];
}

- (NSString *)getPlacementID {
    return self.placementId;
}

@end
