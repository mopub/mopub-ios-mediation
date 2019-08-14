//
//  VungleRouter.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "VungleRouter.h"
#if __has_include("MoPub.h")
    #import "MPLogging.h"
    #import "MPRewardedVideoError.h"
    #import "MPRewardedVideo.h"
    #import "MoPub.h"
#endif
#import "VungleInstanceMediationSettings.h"

static NSString *const VungleAdapterVersion = @"6.4.2.0";

NSString *const kVungleAppIdKey = @"appId";
NSString *const kVunglePlacementIdKey = @"pid";
NSString *const kVungleFlexViewAutoDismissSeconds = @"flexViewAutoDismissSeconds";
NSString *const kVungleUserId = @"userId";
NSString *const kVungleOrdinal = @"ordinal";
NSString *const kVungleStartMuted = @"muted";
NSString *const kVungleSupportedOrientations = @"orientations";

NSString *const kVungleSDKCollectDevice = @"collectDevice";
NSString *const kVungleSDKMinSpaceForInit = @"vungleMinimumFileSystemSizeForInit";
NSString *const kVungleSDKMinSpaceForAdRequest = @"vungleMinimumFileSystemSizeForAdRequest";
NSString *const kVungleSDKMinSpaceForAssetLoad = @"vungleMinimumFileSystemSizeForAssetDownload";

static NSString *const kVungleBannerDelegateKey = @"bannerDelegate";
static NSString *const kVungleBannerDelegateStateKey = @"bannerState";

const CGSize kVGNMRECSize = {.width = 300.0f, .height = 250.0f};

typedef NS_ENUM(NSUInteger, SDKInitializeState) {
    SDKInitializeStateNotInitialized,
    SDKInitializeStateInitializing,
    SDKInitializeStateInitialized
};

typedef NS_ENUM(NSUInteger, BannerRouterDelegateState) {
    BannerRouterDelegateStateRequesting,
    BannerRouterDelegateStateCached,
    BannerRouterDelegateStatePlaying,
    BannerRouterDelegateStateClosing,
    BannerRouterDelegateStateClosed,
    BannerRouterDelegateStateUnknown
};

@interface VungleRouter ()

@property (nonatomic, copy) NSString *vungleAppID;
@property (nonatomic, assign) BOOL isAdPlaying;
@property (nonatomic, assign) SDKInitializeState sdkInitializeState;

@property (nonatomic, strong) NSMutableDictionary *delegatesDic;
@property (nonatomic, strong) NSMutableDictionary *waitingListDic;

@property (nonatomic, copy) NSString *bannerPlacementID;
@property (nonatomic, strong) NSMutableArray *bannerDelegates;

@end

@implementation VungleRouter

- (instancetype)init {
    if (self = [super init]) {
        self.sdkInitializeState = SDKInitializeStateNotInitialized;
        self.delegatesDic = [NSMutableDictionary dictionary];
        self.waitingListDic = [NSMutableDictionary dictionary];
        self.bannerDelegates = [NSMutableArray array];
        self.isAdPlaying = NO;
    }
    return self;
}

+ (VungleRouter *)sharedRouter {
    static VungleRouter * sharedRouter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedRouter = [[VungleRouter alloc] init];
    });
    return sharedRouter;
}

- (void)collectConsentStatusFromMoPub {
    // Collect and pass the user's consent from MoPub onto the Vungle SDK
    if ([[MoPub sharedInstance] isGDPRApplicable] == MPBoolYes) {
        if ([[MoPub sharedInstance] allowLegitimateInterest] == YES) {
            if ([[MoPub sharedInstance] currentConsentStatus] == MPConsentStatusDenied
                || [[MoPub sharedInstance] currentConsentStatus] == MPConsentStatusDoNotTrack
                || [[MoPub sharedInstance] currentConsentStatus] == MPConsentStatusPotentialWhitelist) {
                [[VungleSDK sharedSDK] updateConsentStatus:(VungleConsentDenied) consentMessageVersion:@""];
            } else {
                [[VungleSDK sharedSDK] updateConsentStatus:(VungleConsentAccepted) consentMessageVersion:@""];
            }
        } else {
            BOOL canCollectPersonalInfo = [[MoPub sharedInstance] canCollectPersonalInfo];
            [[VungleSDK sharedSDK] updateConsentStatus:(canCollectPersonalInfo) ? VungleConsentAccepted : VungleConsentDenied consentMessageVersion:@""];
        }
    }
}

- (void)initializeSdkWithInfo:(NSDictionary *)info {
    NSString *appId = [info objectForKey:kVungleAppIdKey];
    if (!self.vungleAppID) {
        self.vungleAppID = appId;
    }
    static dispatch_once_t vungleInitToken;
    dispatch_once(&vungleInitToken, ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [[VungleSDK sharedSDK] performSelector:@selector(setPluginName:version:) withObject:@"mopub" withObject:VungleAdapterVersion];
#pragma clang diagnostic pop

        self.sdkInitializeState = SDKInitializeStateInitializing;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError * error = nil;
            [[VungleSDK sharedSDK] startWithAppId:appId error:&error];
            [[VungleSDK sharedSDK] setDelegate:self];
            [[VungleSDK sharedSDK] setNativeAdsDelegate:self];
        });
    });
}

- (void)setShouldCollect:(BOOL)shouldCollect {
    // This should ONLY be set if the SDK has not be initialized
    if (self.sdkInitializeState == SDKInitializeStateNotInitialized) {
        [VungleSDK setPublishIDFV:shouldCollect];
    }
}

- (void)setSDKOptions:(NSDictionary *)sdkOptions {
    // right now, this is just for the checks used to verify amount of
    // storage availalable before attempting specific operations
    if (sdkOptions[kVungleSDKMinSpaceForInit]) {
        NSNumber *tempInit = sdkOptions[kVungleSDKMinSpaceForInit];
        if ([tempInit isEqual:@(0)] && [[NSUserDefaults standardUserDefaults] valueForKey:kVungleSDKMinSpaceForInit]) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kVungleSDKMinSpaceForInit];
        } else if (tempInit.integerValue > 0) {
            [[NSUserDefaults standardUserDefaults] setInteger:tempInit.intValue forKey:kVungleSDKMinSpaceForInit];
        }
    }
    
    if (sdkOptions[kVungleSDKMinSpaceForAdRequest]) {
        NSNumber *tempAdRequest = sdkOptions[kVungleSDKMinSpaceForAdRequest];
        if ([tempAdRequest isEqual:@(0)] && [[NSUserDefaults standardUserDefaults] valueForKey:kVungleSDKMinSpaceForAdRequest]) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kVungleSDKMinSpaceForAdRequest];
        } else if (tempAdRequest.integerValue > 0) {
            [[NSUserDefaults standardUserDefaults] setInteger:tempAdRequest.intValue forKey:kVungleSDKMinSpaceForAdRequest];
        }
    }
    if (sdkOptions[kVungleSDKMinSpaceForAssetLoad]) {
        NSNumber *tempAssetLoad = sdkOptions[kVungleSDKMinSpaceForAssetLoad];
        if ([tempAssetLoad isEqual:@(0)] && [[NSUserDefaults standardUserDefaults] valueForKey:kVungleSDKMinSpaceForAssetLoad]) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kVungleSDKMinSpaceForAssetLoad];
        } else if (tempAssetLoad.integerValue > 0) {
            [[NSUserDefaults standardUserDefaults] setInteger:tempAssetLoad.intValue forKey:kVungleSDKMinSpaceForAssetLoad];
        }
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)requestInterstitialAdWithCustomEventInfo:(NSDictionary *)info delegate:(id<VungleRouterDelegate>)delegate {
    [self collectConsentStatusFromMoPub];

    if ([self validateInfoData:info]) {
        if (self.sdkInitializeState == SDKInitializeStateNotInitialized) {
            [self.waitingListDic setObject:delegate forKey:[info objectForKey:kVunglePlacementIdKey]];
            [self initializeSdkWithInfo:info];
        }
        else if (self.sdkInitializeState == SDKInitializeStateInitializing) {
            [self.waitingListDic setObject:delegate forKey:[info objectForKey:kVunglePlacementIdKey]];
        }
        else if (self.sdkInitializeState == SDKInitializeStateInitialized) {
            [self requestAdWithCustomEventInfo:info delegate:delegate];
        }
    }
    else {
        [delegate vungleAdDidFailToLoad:nil];
    }
}

- (void)requestRewardedVideoAdWithCustomEventInfo:(NSDictionary *)info delegate:(id<VungleRouterDelegate>)delegate {
    [self collectConsentStatusFromMoPub];

    if ([self validateInfoData:info]) {
        if (self.sdkInitializeState == SDKInitializeStateNotInitialized) {
            [self.waitingListDic setObject:delegate forKey:[info objectForKey:kVunglePlacementIdKey]];
            [self initializeSdkWithInfo:info];
        }
        else if (self.sdkInitializeState == SDKInitializeStateInitializing) {
            [self.waitingListDic setObject:delegate forKey:[info objectForKey:kVunglePlacementIdKey]];
        }
        else if (self.sdkInitializeState == SDKInitializeStateInitialized) {
            [self requestAdWithCustomEventInfo:info delegate:delegate];
        }
    }
    else {
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorUnknown userInfo:nil];
        [delegate vungleAdDidFailToLoad:error];
    }
}

- (void)requestBannerAdWithCustomEventInfo:(NSDictionary *)info size:(CGSize)size delegate:(id<VungleRouterDelegate>)delegate {
    [self collectConsentStatusFromMoPub];

    // Verify if PlacementID is nil (first MREC request) or PlacementID is the same one requested
    if (self.bannerPlacementID != nil && ![[info objectForKey:kVunglePlacementIdKey] isEqualToString:self.bannerPlacementID]) {

        MPLogInfo(@"A banner ad type has been already instanciated. Multiple banner ads are not supported with Vungle iOS SDK version %@ and adapter version %@.", VungleSDKVersion, VungleAdapterVersion);
        [delegate vungleAdDidFailToLoad:nil];
        return;
    }

    if ([self validateInfoData:info] && CGSizeEqualToSize(size, kVGNMRECSize)) {
        self.bannerPlacementID = [info objectForKey:kVunglePlacementIdKey];

        if (self.sdkInitializeState == SDKInitializeStateNotInitialized) {
            if (![self.waitingListDic objectForKey:[info objectForKey:kVunglePlacementIdKey]]) {
                [self.waitingListDic setObject:delegate forKey:[info objectForKey:kVunglePlacementIdKey]];
            }
            [self initializeSdkWithInfo:info];
        } else if (self.sdkInitializeState == SDKInitializeStateInitializing) {
            if (![self.waitingListDic objectForKey:[info objectForKey:kVunglePlacementIdKey]]) {
                [self.waitingListDic setObject:delegate forKey:[info objectForKey:kVunglePlacementIdKey]];
            }
        } else if (self.sdkInitializeState == SDKInitializeStateInitialized) {
            NSString *placementID = [info objectForKey:kVunglePlacementIdKey];
            [self requestBannerMrecAdWithPlacementID:placementID delegate:delegate];
        }
    } else {
        // if size is incorrect, should we send that back as an error response?
        [delegate vungleAdDidFailToLoad:nil];
    }
}

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info delegate:(id<VungleRouterDelegate>)delegate {
    NSString *placementId = [info objectForKey:kVunglePlacementIdKey];
    if (![self.delegatesDic objectForKey:placementId]) {
        [self.delegatesDic setObject:delegate forKey:placementId];
    }

    NSError *error = nil;
    if ([[VungleSDK sharedSDK] loadPlacementWithID:placementId error:&error]) {
        MPLogInfo(@"Vungle: Start to load an ad for Placement ID :%@", placementId);
    } else {
        if (error) {
            MPLogInfo(@"Vungle: Unable to load an ad for Placement ID :%@, Error %@", placementId, error);
        }
        [delegate vungleAdDidFailToLoad:error];
    }
}

- (void)requestBannerMrecAdWithPlacementID:(NSString *)placementID delegate:(id<VungleRouterDelegate>)delegate {
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
    if ([[VungleSDK sharedSDK]  isAdCachedForPlacementID:placementID]) {
        [delegate vungleAdDidLoad];

        [tempDic setObject:delegate forKey:kVungleBannerDelegateKey];
        [tempDic setObject:[NSNumber numberWithInt:BannerRouterDelegateStateCached] forKey:kVungleBannerDelegateStateKey];
        [self.bannerDelegates addObject:tempDic];
    } else {
        [tempDic setObject:delegate forKey:kVungleBannerDelegateKey];
        [tempDic setObject:[NSNumber numberWithInt:BannerRouterDelegateStateRequesting] forKey:kVungleBannerDelegateStateKey];
        [self.bannerDelegates addObject:tempDic];

        NSError *error = nil;
        if ([[VungleSDK sharedSDK] loadPlacementWithID:placementID error:&error]) {
            NSLog(@"Vungle: Start to load an ad for Placement ID :%@", placementID);
        } else {
            if (error) {
                NSLog(@"Vungle: Unable to load an ad for Placement ID :%@, Error %@", placementID, error);
            }
            [delegate vungleAdDidFailToLoad:error];
        }
    }
}

- (BOOL)isAdAvailableForPlacementId:(NSString *) placementId {
    return [[VungleSDK sharedSDK] isAdCachedForPlacementID:placementId];
}

- (void)presentInterstitialAdFromViewController:(UIViewController *)viewController options:(NSDictionary *)options forPlacementId:(NSString *)placementId {
    if (!self.isAdPlaying && [self isAdAvailableForPlacementId:placementId]) {
        self.isAdPlaying = YES;
        NSError *error;
        BOOL success = [[VungleSDK sharedSDK] playAd:viewController options:options placementID:placementId error:&error];
        if (!success) {
            [[self.delegatesDic objectForKey:placementId] vungleAdDidFailToPlay:nil];
            self.isAdPlaying = NO;
        }
    } else {
        [[self.delegatesDic objectForKey:placementId] vungleAdDidFailToPlay:nil];
    }
}

- (void)presentRewardedVideoAdFromViewController:(UIViewController *)viewController customerId:(NSString *)customerId settings:(VungleInstanceMediationSettings *)settings forPlacementId:(NSString *)placementId {
    if (!self.isAdPlaying && [self isAdAvailableForPlacementId:placementId]) {
        self.isAdPlaying = YES;
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
        if (customerId.length > 0) {
            options[VunglePlayAdOptionKeyUser] = customerId;
        } else if (settings && settings.userIdentifier.length > 0) {
            options[VunglePlayAdOptionKeyUser] = settings.userIdentifier;
        }
        if (settings.ordinal > 0)
            options[VunglePlayAdOptionKeyOrdinal] = @(settings.ordinal);
        if (settings.flexViewAutoDismissSeconds > 0)
            options[VunglePlayAdOptionKeyFlexViewAutoDismissSeconds] = @(settings.flexViewAutoDismissSeconds);
        if (settings.startMuted) {
            options[VunglePlayAdOptionKeyStartMuted] = @(settings.startMuted);
        }
        
        int appOrientation = [settings.orientations intValue];
        NSNumber *orientations = @(UIInterfaceOrientationMaskAll);
        if (appOrientation == 1) {
            orientations = @(UIInterfaceOrientationMaskLandscape);
        } else if (appOrientation == 2) {
            orientations = @(UIInterfaceOrientationMaskPortrait);
        }
        options[VunglePlayAdOptionKeyOrientations] = orientations;

        BOOL success = [[VungleSDK sharedSDK] playAd:viewController options:options placementID:placementId error:nil];
        if (!success) {
            [[self.delegatesDic objectForKey:placementId] vungleAdDidFailToPlay:nil];
            self.isAdPlaying = NO;
        }
    } else {
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:nil];
        [[self.delegatesDic objectForKey:placementId] vungleAdDidFailToPlay:error];
    }
}

- (UIView *)renderBannerAdInView:(UIView *)bannerView options:(NSDictionary *)options forPlacementID:(NSString *)placementID {
    NSError *bannerError = nil;
    if ([[VungleSDK sharedSDK] isAdCachedForPlacementID:placementID]) {
        BOOL success = [[VungleSDK sharedSDK] addAdViewToView:bannerView withOptions:options placementID:placementID error:&bannerError];
        if (success) {
            return bannerView;
        }
    } else {
        bannerError = [NSError errorWithDomain:@"com.vungle.sdk" code:8769 userInfo:@{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Ad not cached for placement %@", placementID]}];
    }
    NSLog(@"Banner loading error: %@", bannerError.localizedDescription);
    return nil;
}

- (void)completeBannerAdViewForPlacementID:(NSString *)placementID {
    if (placementID) {
        NSLog(@"Vungle: Triggering an ad completion call for %@", placementID);
        for (int i = 0; i < self.bannerDelegates.count; i++) {
            if ((BannerRouterDelegateState)[[self.bannerDelegates[i] valueForKey:kVungleBannerDelegateStateKey] intValue] == BannerRouterDelegateStatePlaying) {
                [[VungleSDK sharedSDK] finishedDisplayingAd];
                [self.bannerDelegates[i] setObject:[NSNumber numberWithInt:BannerRouterDelegateStateClosing] forKey:kVungleBannerDelegateStateKey];
            }
        }
    }
}

- (void)updateConsentStatus:(VungleConsentStatus)status {
    [[VungleSDK sharedSDK] updateConsentStatus:status consentMessageVersion:@""];
}

- (VungleConsentStatus)getCurrentConsentStatus {
    return [[VungleSDK sharedSDK] getCurrentConsentStatus];
}

- (void)clearDelegateForRequestingBanner {
    [self clearDelegateWithState:BannerRouterDelegateStateRequesting placementID:nil];
}

- (void)clearDelegateForPlacementId:(NSString *)placementId {
    [self clearDelegateWithState:BannerRouterDelegateStateUnknown placementID:placementId];
}

#pragma mark - private

- (BOOL)validateInfoData:(NSDictionary *)info {
    BOOL isValid = YES;

    NSString *appId = [info objectForKey:kVungleAppIdKey];
    if ([appId length] == 0) {
        isValid = NO;
        MPLogInfo(@"Vungle: AppID is empty. Setup appID on MoPub dashboard.");
    }
    else {
        if (self.vungleAppID && ![self.vungleAppID isEqualToString:appId]) {
            isValid = NO;
            MPLogInfo(@"Vungle: AppID is different from the one used for initialization. Make sure you set the same network App ID for all AdUnits in this application on MoPub dashboard.");
        }
    }

    NSString *placementId = [info objectForKey:kVunglePlacementIdKey];
    if ([placementId length] == 0) {
        isValid = NO;
        MPLogInfo(@"Vungle: PlacementID is empty. Setup placementID on MoPub dashboard.");
    }

    if (isValid) {
        MPLogInfo(@"Vungle: Info data for the Ad Unit is valid.");
    }

    return isValid;
}

- (void)clearDelegateWithState:(BannerRouterDelegateState)state placementID:(NSString *)placementID {
    if (placementID) {
        [self.delegatesDic removeObjectForKey:placementID];
    } else if (state != BannerRouterDelegateStateUnknown) {
        for (int i = 0; i < self.bannerDelegates.count; i++) {
            if ((BannerRouterDelegateState)[[self.bannerDelegates[i] valueForKey:kVungleBannerDelegateStateKey] intValue] == state) {
                [self.bannerDelegates removeObjectAtIndex:i];
            }
        }
    }
}

- (void)clearWaitingList {
    for (id key in self.waitingListDic) {
        id<VungleRouterDelegate> delegateInstance = [self.waitingListDic objectForKey:key];
        if ([[delegateInstance getPlacementID] isEqualToString:self.bannerPlacementID]) {
            NSString *tempPlacementID = [delegateInstance getPlacementID];
            [self requestBannerMrecAdWithPlacementID:tempPlacementID delegate:delegateInstance];
        }
        else {
            if (![self.delegatesDic objectForKey:key]) {
                [self.delegatesDic setObject:delegateInstance forKey:key];
            }

            NSError *error = nil;
            if ([[VungleSDK sharedSDK] loadPlacementWithID:key error:&error]) {
                MPLogInfo(@"Vungle: Start to load an ad for Placement ID :%@", key);
            }
            else {
                if (error) {
                    MPLogInfo(@"Vungle: Unable to load an ad for Placement ID :%@, Error %@", key, error);
                }
                [delegateInstance vungleAdDidFailToLoad:error];
            }
        }
    }

    [self.waitingListDic removeAllObjects];
}

#pragma mark - VungleSDKDelegate Methods

- (void) vungleSDKDidInitialize {
    MPLogInfo(@"Vungle: the SDK has been initialized successfully.");
    self.sdkInitializeState = SDKInitializeStateInitialized;
    [self clearWaitingList];
}

- (void)vungleAdPlayabilityUpdate:(BOOL)isAdPlayable placementID:(NSString *)placementID error:(NSError *)error {
    if ([placementID isEqualToString:self.bannerPlacementID]) {
        for (int i = 0; i < self.bannerDelegates.count; i++) {
            if ((BannerRouterDelegateState)[[self.bannerDelegates[i] valueForKey:kVungleBannerDelegateStateKey] intValue] == BannerRouterDelegateStateRequesting) {
                if (isAdPlayable) {
                    [[self.bannerDelegates[i] objectForKey:kVungleBannerDelegateKey] vungleAdDidLoad];
                    [self.bannerDelegates[i] setObject:[NSNumber numberWithInt:BannerRouterDelegateStateCached] forKey:kVungleBannerDelegateStateKey];
                }
                else {
                    NSError *playabilityError;
                    if (error) {
                        MPLogInfo(@"Vungle: Ad playability update returned error for Placement ID: %@, Error: %@", placementID, error.localizedDescription);
                        playabilityError = error;
                    }
                    if (!self.isAdPlaying) {
                        [[self.bannerDelegates[i] objectForKey:kVungleBannerDelegateKey] vungleAdDidFailToLoad:playabilityError];
                    }
                    [self.bannerDelegates[i] setObject:[NSNumber numberWithInt:BannerRouterDelegateStateClosed] forKey:kVungleBannerDelegateStateKey];
                    [self clearDelegateWithState:BannerRouterDelegateStateClosed placementID:nil];
                }
            }
        }
    }
    else {
        if (isAdPlayable) {
            [[self.delegatesDic objectForKey:placementID] vungleAdDidLoad];
        }
        else {
            if(placementID) {
                NSError *playabilityError;
                if (error) {
                    MPLogInfo(@"Vungle: Ad playability update returned error for Placement ID: %@, Error: %@", placementID, error.localizedDescription);
                    playabilityError = error;
                }
                if (!self.isAdPlaying) {
                    [[self.delegatesDic objectForKey:placementID] vungleAdDidFailToLoad:playabilityError];
                }
            }
        }
    }
}

- (void)vungleWillShowAdForPlacementID:(nullable NSString *)placementID {
    id<VungleRouterDelegate> targetDelegate;
    if ([placementID isEqualToString:self.bannerPlacementID]) {
        for (int i = 0; i < self.bannerDelegates.count; i++) {
            if ((BannerRouterDelegateState)[[self.bannerDelegates[i] valueForKey:kVungleBannerDelegateStateKey] intValue] == BannerRouterDelegateStateCached) {
                targetDelegate = [self.bannerDelegates[i] objectForKey:kVungleBannerDelegateKey];
                [self.bannerDelegates[i] setObject:[NSNumber numberWithInt:BannerRouterDelegateStatePlaying] forKey:kVungleBannerDelegateStateKey];
            }
        }
    }
    else {
        targetDelegate = [self.delegatesDic objectForKey:placementID];
    }

    if (targetDelegate) {
        [targetDelegate vungleAdWillAppear];
    }
}

- (void)vungleDidShowAdForPlacementID:(NSString *)placementID {
    id<VungleRouterDelegate> targetDelegate = [self.delegatesDic objectForKey:placementID];
    if (targetDelegate) {
        [targetDelegate vungleAdDidAppear];
    }
}

- (void)vungleWillCloseAdWithViewInfo:(VungleViewInfo *)info placementID:(NSString *)placementID {
    id<VungleRouterDelegate> targetDelegate;
    if ([placementID isEqualToString:self.bannerPlacementID]) {
        for (int i = 0; i < self.bannerDelegates.count; i++) {
            if ((BannerRouterDelegateState)[[self.bannerDelegates[i] valueForKey:kVungleBannerDelegateStateKey] intValue] == BannerRouterDelegateStateClosing) {
                targetDelegate = [self.bannerDelegates[i] objectForKey:kVungleBannerDelegateKey];
            }
        }
    }
    else {
        targetDelegate = [self.delegatesDic objectForKey:placementID];
    }

    if(targetDelegate) {
        if ([info.completedView boolValue] && [targetDelegate respondsToSelector:@selector(vungleAdShouldRewardUser)]) {
            [targetDelegate vungleAdShouldRewardUser];
        }

        [targetDelegate vungleAdWillDisappear];
        self.isAdPlaying = NO;
    }
}

- (void)vungleDidCloseAdWithViewInfo:(VungleViewInfo *)info placementID:(NSString *)placementID {
    id<VungleRouterDelegate> targetDelegate;
    if ([placementID isEqualToString:self.bannerPlacementID]) {
        for (int i = 0; i < self.bannerDelegates.count; i++) {
            if ((BannerRouterDelegateState)[[self.bannerDelegates[i] valueForKey:kVungleBannerDelegateStateKey] intValue] == BannerRouterDelegateStateClosing) {
                targetDelegate = [self.bannerDelegates[i] objectForKey:kVungleBannerDelegateKey];
                [self.bannerDelegates[i] setObject:[NSNumber numberWithInt:BannerRouterDelegateStateClosed] forKey:kVungleBannerDelegateStateKey];
                [self clearDelegateWithState:BannerRouterDelegateStateClosed placementID:nil];
            }
        }
    }
    else {
        targetDelegate = [self.delegatesDic objectForKey:placementID];
    }

    if (targetDelegate) {
        [targetDelegate vungleAdDidDisappear];
    }
}

#pragma mark - VungleSDKNativeAds delegate methods

- (void)nativeAdsPlacementDidLoadAd:(NSString *)placement {
    // Ad loaded successfully
    // We allow the playability update to notify the
    // Banner Custom Event class of successful ad loading.
}

- (void)nativeAdsPlacement:(NSString *)placement didFailToLoadAdWithError:(NSError *)error {
    // Ad failed to load
    // We allow the playability update to notify the
    // Banner Custom Event class of unsuccessful ad loading.
}

- (void)nativeAdsPlacementWillTriggerURLLaunch:(NSString *)placement {
    // Ad has triggered action that will take the user out of the application
    [[self.delegatesDic objectForKey:placement] vungleAdWillLeaveApplication];
}

@end
