#import "FyberInterstitialCustomEvent.h"

#import "FyberAdapterConfiguration.h"

#import <IASDKCore/IASDKCore.h>
#import <IASDKVideo/IASDKVideo.h>
#import <IASDKMRAID/IASDKMRAID.h>

@interface FyberInterstitialCustomEvent () <IAUnitDelegate, IAVideoContentDelegate, IAMRAIDContentDelegate>

@property (nonatomic, strong) IAAdSpot *adSpot;
@property (nonatomic, strong) IAFullscreenUnitController *interstitialUnitController;
@property (nonatomic, strong) IAMRAIDContentController *MRAIDContentController;
@property (nonatomic, strong) IAVideoContentController *videoContentController;
@property (nonatomic, strong) NSString *spotID;
@property (nonatomic) BOOL clickTracked;
@property (nonatomic, copy) void (^fetchAdBlock)(void);

/**
 *  @brief The view controller, that presents the Inneractive Interstitial Ad.
 */
@property (nonatomic, weak) UIViewController *interstitialRootViewController;

@end

@implementation FyberInterstitialCustomEvent {}

@dynamic delegate;
@dynamic hasAdAvailable;
@dynamic localExtras;

#pragma mark -

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    NSString *spotID = @"";
    
    if (info && [info isKindOfClass:NSDictionary.class] && info.count) {
        NSString *receivedSpotID = info[@"spotID"];
        
        if (receivedSpotID && [receivedSpotID isKindOfClass:NSString.class] && receivedSpotID.length) {
            spotID = receivedSpotID;
        }
        
        [FyberAdapterConfiguration configureIASDKWithInfo:info];
    }
    [FyberAdapterConfiguration collectConsentStatusFromMoPub];
    
    IAUserData *userData = [IAUserData build:^(id<IAUserDataBuilder>  _Nonnull builder) {
    }];
    
    self.spotID = spotID;
    IAAdRequest *request = [IAAdRequest build:^(id<IAAdRequestBuilder>  _Nonnull builder) {
        builder.spotID = spotID;
        builder.timeout = 15;
        builder.userData = userData;
        
        builder.keywords = self.localExtras[@"keywords"];
    }];
    
    self.videoContentController = [IAVideoContentController build:^(id<IAVideoContentControllerBuilder>  _Nonnull builder) {
        builder.videoContentDelegate = self;
    }];
    
    self.MRAIDContentController = [IAMRAIDContentController build:^(id<IAMRAIDContentControllerBuilder>  _Nonnull builder) {
        builder.MRAIDContentDelegate = self;
    }];
    
    self.interstitialUnitController = [IAFullscreenUnitController build:^(id<IAFullscreenUnitControllerBuilder>  _Nonnull builder) {
        builder.unitDelegate = self;
        
        [builder addSupportedContentController:self.videoContentController];
        [builder addSupportedContentController:self.MRAIDContentController];
    }];
    
    self.adSpot = [IAAdSpot build:^(id<IAAdSpotBuilder>  _Nonnull builder) {
        builder.adRequest = request;
        [builder addSupportedUnitController:self.interstitialUnitController];
        builder.mediationType = [IAMediationMopub new];
    }];
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], self.spotID);
    
    __weak __typeof__(self) weakSelf = self;
    
    self.fetchAdBlock = ^void() {
        [weakSelf.adSpot fetchAdWithCompletion:^(IAAdSpot * _Nullable adSpot, IAAdModel * _Nullable adModel, NSError * _Nullable error) {
            if (error) {
                [weakSelf handleLoadOrShowError:error.localizedDescription isLoad:YES];
            } else {
                if (adSpot.activeUnitController == weakSelf.interstitialUnitController) {
                    [MPLogging logEvent:[MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(weakSelf.class)] source:weakSelf.spotID fromClass:weakSelf.class];
                    [weakSelf.delegate fullscreenAdAdapterDidLoadAd:weakSelf];
                } else {
                    [weakSelf handleLoadOrShowError:nil isLoad:YES];
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

- (void)presentAdFromViewController:(UIViewController *)rootViewController {
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.spotID);
    
    NSString *errorString = nil;
    
    if (!rootViewController) {
        errorString = @"rootViewController must not be nil;";
    } else if (self.interstitialUnitController.isPresented) {
        errorString = @"the interstitial ad is already presented;";
    } else if (!self.interstitialUnitController.isReady) {
        errorString = @"ad did expire;";
    }
    
    if (errorString) {
        [self handleLoadOrShowError:errorString isLoad:NO];
    } else {
        self.interstitialRootViewController = rootViewController;
        [self.interstitialUnitController showAdAnimated:YES completion:nil];
    }
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

- (BOOL)isRewardExpected {
    return NO;
}

- (BOOL)hasAdAvailable {
    return self.interstitialUnitController.isReady;
}

- (void)handleDidPlayAd {
    if (!self.hasAdAvailable) {
        [self.delegate fullscreenAdAdapterDidExpire:self];
    }
}

#pragma mark - Service

- (void)handleLoadOrShowError:(NSString * _Nullable)reason isLoad:(BOOL)isLoad {
    if (!reason.length) {
        reason = @"internal error";
    }
    
    NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey : reason};
    NSError *error = [NSError errorWithDomain:kIASDKMoPubAdapterErrorDomain code:IASDKMopubAdapterErrorInternal userInfo:userInfo];
    
    if (isLoad) {
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.spotID);
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
    } else {
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], self.spotID);
        [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:error];
    }
}

#pragma mark - IAViewUnitControllerDelegate

- (UIViewController * _Nonnull)IAParentViewControllerForUnitController:(IAUnitController * _Nullable)unitController {
    return self.interstitialRootViewController;
}

- (void)IAAdDidReceiveClick:(IAUnitController * _Nullable)unitController {
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], self.spotID);
    [self.delegate fullscreenAdAdapterDidReceiveTap:self];
    [self.delegate fullscreenAdAdapterDidTrackClick:self];
}

- (void)IAAdWillLogImpression:(IAUnitController * _Nullable)unitController {
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], self.spotID);
    [self.delegate fullscreenAdAdapterDidTrackImpression:self];
}

- (void)IAUnitControllerWillPresentFullscreen:(IAUnitController * _Nullable)unitController {
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], self.spotID);
    [self.delegate fullscreenAdAdapterAdWillPresent:self];
}

- (void)IAUnitControllerDidPresentFullscreen:(IAUnitController * _Nullable)unitController {
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], self.spotID);
    [self.delegate fullscreenAdAdapterAdDidPresent:self];
}

- (void)IAUnitControllerWillDismissFullscreen:(IAUnitController * _Nullable)unitController {
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], self.spotID);
    [self.delegate fullscreenAdAdapterAdWillDismiss:self];
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
    
}

- (void)IAUnitControllerDidDismissFullscreen:(IAUnitController * _Nullable)unitController {
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], self.spotID);
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
    [self.delegate fullscreenAdAdapterAdDidDismiss:self];
}

- (void)IAUnitControllerWillOpenExternalApp:(IAUnitController * _Nullable)unitController {
    MPLogAdEvent([MPLogEvent adWillLeaveApplicationForAdapter:NSStringFromClass(self.class)], self.spotID);
    [self.delegate fullscreenAdAdapterWillLeaveApplication:self];
}

- (void)IAAdDidExpire:(IAUnitController * _Nullable)unitController {
    NSError *error = [NSError errorWithCode:MOPUBErrorVideoPlayerFailedToPlay
                       localizedDescription:@"Fyber ad is expired."];
    MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], self.spotID);
    [self.delegate fullscreenAdAdapterDidExpire:self];
    [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:error];
}

#pragma mark - IAMRAIDContentDelegate

// MRAID protocol related methods are not relevant in case of interstitial;

#pragma mark - IAVideoContentDelegate

- (void)IAVideoCompleted:(IAVideoContentController * _Nullable)contentController {
    MPLogInfo(@"video completed;");
}

- (void)IAVideoContentController:(IAVideoContentController * _Nullable)contentController videoInterruptedWithError:(NSError *)error {
    MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], self.spotID);
    [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:error];
}

- (void)IAVideoContentController:(IAVideoContentController * _Nullable)contentController videoDurationUpdated:(NSTimeInterval)videoDuration {
    MPLogInfo(@"Video duration updated: %.02lf", videoDuration);
}

#pragma mark - Memory management

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    MPLogDebug(@"%@ deallocated", NSStringFromClass(self.class));
}

@end
