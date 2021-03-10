//
//  FyberBannerCustomEvent.m
//  FyberMarketplaceTestApp
//
//  Created by Fyber 10/03/2021.
//  Copyright (c) 2021 Fyber. All rights reserved.
//

#import "FyberBannerCustomEvent.h"

#import "FyberAdapterConfiguration.h"

#import <IASDKCore/IASDKCore.h>
#import <IASDKMRAID/IASDKMRAID.h>

@interface FyberBannerCustomEvent () <IAUnitDelegate, IAMRAIDContentDelegate>

@property (nonatomic, strong) IAAdSpot *adSpot;
@property (nonatomic, strong) IAViewUnitController *bannerUnitController;
@property (nonatomic, strong) IAMRAIDContentController *MRAIDContentController;
@property (nonatomic, strong) NSString *spotID;
@property (nonatomic, strong) MPAdView *moPubAdView;
@property (nonatomic, copy) void (^fetchAdBlock)(void);

@property (nonatomic) BOOL isIABanner;
@property (atomic) BOOL clickTracked;

@end

@implementation FyberBannerCustomEvent {}

@dynamic delegate;
@dynamic localExtras;

#pragma mark -

/**
 *  @brief Is called each time the MoPub SDK requests a new banner ad. MoPub >= 5.13.
 *
 *  @discussion Also, when this method is invoked, this class is a new instance, it is not reused,
 * which makes call of this method only once per it's instance lifetime.
 *
 *  @param size Ad size.
 *  @param info An Info dictionary is a JSON object that is defined in the MoPub console.
 */

- (void)requestAdWithSize:(CGSize)size adapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    _isIABanner =
    ((size.width == kIADefaultIPhoneBannerWidth) && (size.height == kIADefaultIPhoneBannerHeight)) ||
    ((size.width == kIADefaultIPadBannerWidth) && (size.height == kIADefaultIPadBannerHeight));
    
#warning Set your spotID or define it @MoPub console inside the "extra" JSON:
    NSString *spotID = @"";
    
    if (info && [info isKindOfClass:NSDictionary.class] && info.count) {
        NSString *receivedSpotID = info[@"spotID"];
        
        if (receivedSpotID && [receivedSpotID isKindOfClass:NSString.class] && receivedSpotID.length) {
            spotID = receivedSpotID;
        }
        
        [FyberAdapterConfiguration configureIASDKWithInfo:info];
    }
    [FyberAdapterConfiguration collectConsentStatusFromMopub];
    
    IAUserData *userData = [IAUserData build:^(id<IAUserDataBuilder>  _Nonnull builder) {
#warning Set up targeting in order to increase revenue:
        /*
        builder.age = 34;
        builder.gender = IAUserGenderTypeMale;
        builder.zipCode = @"90210";
         */
    }];
    
    self.spotID = spotID;
	IAAdRequest *request = [IAAdRequest build:^(id<IAAdRequestBuilder>  _Nonnull builder) {
        builder.spotID = spotID;
		builder.timeout = BANNER_TIMEOUT_INTERVAL - 1;
		builder.userData = userData;

        builder.keywords = self.localExtras[@"keywords"];
	}];

	self.MRAIDContentController = [IAMRAIDContentController build:^(id<IAMRAIDContentControllerBuilder>  _Nonnull builder) {
		builder.MRAIDContentDelegate = self;
        builder.contentAwareBackground = YES;
	}];

	self.bannerUnitController = [IAViewUnitController build:^(id<IAViewUnitControllerBuilder>  _Nonnull builder) {
		builder.unitDelegate = self;
		[builder addSupportedContentController:self.MRAIDContentController];
	}];

	self.adSpot = [IAAdSpot build:^(id<IAAdSpotBuilder>  _Nonnull builder) {
		builder.adRequest = request;
		[builder addSupportedUnitController:self.bannerUnitController];
		builder.mediationType = [IAMediationMopub new];
	}];
	MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], self.spotID);
    self.clickTracked = NO;
    
    __weak __typeof__(self) weakSelf = self;
    
    self.fetchAdBlock = ^void() {
        [weakSelf.adSpot fetchAdWithCompletion:^(IAAdSpot * _Nullable adSpot, IAAdModel * _Nullable adModel, NSError * _Nullable error) {
            if (error) {
                [weakSelf treatError:error.localizedDescription];
            } else {
                if (adSpot.activeUnitController == weakSelf.bannerUnitController) {
                    if ([weakSelf.delegate inlineAdAdapterViewControllerForPresentingModalView:weakSelf].presentedViewController != nil) {
                        [weakSelf treatError:@"view hierarchy inconsistency"];
                    } else {
                        [MPLogging logEvent:[MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(weakSelf.class)] source:weakSelf.spotID fromClass:weakSelf.class];
                        [MPLogging logEvent:[MPLogEvent adShowAttemptForAdapter:NSStringFromClass(weakSelf.class)] source:weakSelf.spotID fromClass:weakSelf.class];
                        [MPLogging logEvent:[MPLogEvent adWillAppearForAdapter:NSStringFromClass(weakSelf.class)] source:weakSelf.spotID fromClass:weakSelf.class];
                        weakSelf.bannerUnitController.adView.bounds = CGRectMake(0, 0, size.width, size.height);
                        [weakSelf.delegate inlineAdAdapter:weakSelf didLoadAdWithAdView:weakSelf.bannerUnitController.adView];
                    }
                } else {
                    [weakSelf treatError:@"mismatched ad object entities"];
                }
            }
        }];
    };
    if (IASDKCore.sharedInstance.isInitialised) {
        [self performAdFetch:nil];
    } else {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(performAdFetch:) name:kIASDKInitCompleteNotification object:nil];
    }
}

- (void)performAdFetch:(NSNotification *)notification {
    if (self.fetchAdBlock) {
        void (^fetchAdBlock)(void) = self.fetchAdBlock;
        
        self.fetchAdBlock = nil;
        fetchAdBlock();
        
        [NSNotificationCenter.defaultCenter removeObserver:self name:kIASDKInitCompleteNotification object:self];
    }
}

/**
 *  @discussion This method is called only once per instance lifecycle.
 */
- (void)didDisplayAd {
    // set constraints for rotations support; this method override can be deleted, if rotations treatment is not needed;
    UIView *view = self.bannerUnitController.adView;
    
    if (view.superview) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
        
        [view.superview addConstraint:
         [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
        
        [view.superview addConstraint:
         [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
        
        [view.superview addConstraint:
         [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
        
        [view.superview addConstraint:
         [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    }
}

// new
- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO; // we will track it manually;
}

#pragma mark - Service

- (void)treatError:(NSString * _Nullable)reason {
    if (!reason.length) {
        reason = @"internal error";
    }
    
    NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey : reason};
    NSError *error = [NSError errorWithDomain:kIASDKMopubAdapterErrorDomain code:IASDKMopubAdapterErrorInternal userInfo:userInfo];
    
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.spotID);
    [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
}

#pragma mark - IAViewUnitControllerDelegate

- (UIViewController * _Nonnull)IAParentViewControllerForUnitController:(IAUnitController * _Nullable)unitController {
    return [self.delegate inlineAdAdapterViewControllerForPresentingModalView:self];
}

- (void)IAAdDidReceiveClick:(IAUnitController * _Nullable)unitController {
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], self.spotID);
    if (!self.clickTracked) {
        self.clickTracked = YES;
        [self.delegate inlineAdAdapterDidTrackClick:self]; // manual track;
    }
}

- (void)IAAdWillLogImpression:(IAUnitController * _Nullable)unitController {
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], self.spotID);
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], self.spotID);
    [self.delegate inlineAdAdapterDidTrackImpression:self]; // manual track;
}

- (void)IAUnitControllerWillPresentFullscreen:(IAUnitController * _Nullable)unitController {
    MPLogAdEvent([MPLogEvent adWillPresentModalForAdapter:NSStringFromClass(self.class)], self.spotID);
    [self.delegate inlineAdAdapterWillBeginUserAction:self];
}

- (void)IAUnitControllerDidPresentFullscreen:(IAUnitController * _Nullable)unitController {
    MPLogInfo(@"<Fyber> ad did present fullscreen;");
    UIView *view = self.bannerUnitController.adView;
    
    while (view.superview) {
        if ([view.superview isKindOfClass:MPAdView.class]) {
            self.moPubAdView = (MPAdView *)view.superview;
            [self.moPubAdView stopAutomaticallyRefreshingContents];
            break;
        } else {
            view = view.superview;
        }
    }
}

- (void)IAUnitControllerWillDismissFullscreen:(IAUnitController * _Nullable)unitController {
    MPLogInfo(@"<Fyber> ad will dismiss fullscreen;");
}

- (void)IAUnitControllerDidDismissFullscreen:(IAUnitController * _Nullable)unitController {
    [self.moPubAdView startAutomaticallyRefreshingContents];
    
    MPLogAdEvent([MPLogEvent adDidDismissModalForAdapter:NSStringFromClass(self.class)], self.spotID);
    [self.delegate inlineAdAdapterDidEndUserAction:self];
}

- (void)IAUnitControllerWillOpenExternalApp:(IAUnitController * _Nullable)unitController {
    MPLogAdEvent([MPLogEvent adWillLeaveApplicationForAdapter:NSStringFromClass(self.class)], self.spotID);
    [self.delegate inlineAdAdapterWillLeaveApplication:self];
}

#pragma mark - IAMRAIDContentDelegate

- (void)IAMRAIDContentController:(IAMRAIDContentController * _Nullable)contentController MRAIDAdWillResizeToFrame:(CGRect)frame {
    MPLogInfo(@"<Fyber> MRAID ad will resize;");
}

- (void)IAMRAIDContentController:(IAMRAIDContentController * _Nullable)contentController MRAIDAdDidResizeToFrame:(CGRect)frame {
    MPLogInfo(@"<Fyber> MRAID ad did resize;");
}

- (void)IAMRAIDContentController:(IAMRAIDContentController * _Nullable)contentController MRAIDAdWillExpandToFrame:(CGRect)frame {
    MPLogInfo(@"<Fyber> MRAID ad will expand;");

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([self.delegate respondsToSelector:@selector(inlineAdAdapterWillExpand:)]) {
        [self.delegate performSelector:@selector(inlineAdAdapterWillExpand:) withObject:self];
    }
#pragma clang diagnostic pop
}

- (void)IAMRAIDContentController:(IAMRAIDContentController * _Nullable)contentController MRAIDAdDidExpandToFrame:(CGRect)frame {
    MPLogInfo(@"<Fyber> MRAID ad did expand;");
}

- (void)IAMRAIDContentControllerMRAIDAdWillCollapse:(IAMRAIDContentController * _Nullable)contentController {
    MPLogInfo(@"<Fyber> MRAID ad will collapse;");
}

- (void)IAMRAIDContentControllerMRAIDAdDidCollapse:(IAMRAIDContentController * _Nullable)contentController {
    MPLogInfo(@"<Fyber> MRAID ad did collapse;");

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([self.delegate respondsToSelector:@selector(inlineAdAdapterDidCollapse:)]) {
        [self.delegate performSelector:@selector(inlineAdAdapterDidCollapse:) withObject:self];
    }
#pragma clang diagnostic pop
}

#pragma mark - Memory management

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], _spotID);
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], _spotID);
    MPLogDebug(@"%@ deallocated", NSStringFromClass(self.class));
}

@end
