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
#import "VungleAdapterConfiguration.h"

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

const CGSize kVNGMRECSize = {.width = 300.0f, .height = 250.0f};

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

@property (nonatomic, strong) NSMutableDictionary *delegatesDict;
@property (nonatomic, strong) NSMutableDictionary *waitingListDict;

@property (nonatomic, copy) NSString *bannerPlacementID;
@property (nonatomic, strong) NSMutableArray *bannerDelegates;
@property (nonatomic, assign) BOOL isInvalidatedBannerForPlacementID;

@end

@implementation VungleRouter

- (instancetype)init {
    if (self = [super init]) {
        self.sdkInitializeState = SDKInitializeStateNotInitialized;
        self.delegatesDict = [NSMutableDictionary dictionary];
        self.waitingListDict = [NSMutableDictionary dictionary];
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
        [[VungleSDK sharedSDK] performSelector:@selector(setPluginName:version:) withObject:@"mopub" withObject:[[[VungleAdapterConfiguration alloc] init] adapterVersion]];
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

- (void)setShouldCollectDeviceId:(BOOL)shouldCollectDeviceId {
    // This should ONLY be set if the SDK has not been initialized
    if (self.sdkInitializeState == SDKInitializeStateNotInitialized) {
        [VungleSDK setPublishIDFV:shouldCollectDeviceId];
    }
}

- (void)setSDKOptions:(NSDictionary *)sdkOptions {
    // right now, this is just for the checks used to verify amount of
    // storage available before attempting specific operations
    if (sdkOptions[kVungleSDKMinSpaceForInit]) {
        NSNumber *minSizeForInit = sdkOptions[kVungleSDKMinSpaceForInit];
        if ([minSizeForInit isEqual:@(0)] && [[NSUserDefaults standardUserDefaults] valueForKey:kVungleSDKMinSpaceForInit]) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kVungleSDKMinSpaceForInit];
        } else if (minSizeForInit.integerValue > 0) {
            [[NSUserDefaults standardUserDefaults] setInteger:minSizeForInit.intValue forKey:kVungleSDKMinSpaceForInit];
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
            [self.waitingListDict setObject:delegate forKey:[info objectForKey:kVunglePlacementIdKey]];
            [self initializeSdkWithInfo:info];
        }
        else if (self.sdkInitializeState == SDKInitializeStateInitializing) {
            [self.waitingListDict setObject:delegate forKey:[info objectForKey:kVunglePlacementIdKey]];
        }
        else if (self.sdkInitializeState == SDKInitializeStateInitialized) {
            [self requestAdWithCustomEventInfo:info delegate:delegate];
        }
    } else {
        [delegate vungleAdDidFailToLoad:nil];
    }
}

- (void)requestRewardedVideoAdWithCustomEventInfo:(NSDictionary *)info delegate:(id<VungleRouterDelegate>)delegate {
    [self collectConsentStatusFromMoPub];
    
    if ([self validateInfoData:info]) {
        if (self.sdkInitializeState == SDKInitializeStateNotInitialized) {
            [self.waitingListDict setObject:delegate forKey:[info objectForKey:kVunglePlacementIdKey]];
            [self initializeSdkWithInfo:info];
        }
        else if (self.sdkInitializeState == SDKInitializeStateInitializing) {
            [self.waitingListDict setObject:delegate forKey:[info objectForKey:kVunglePlacementIdKey]];
        }
        else if (self.sdkInitializeState == SDKInitializeStateInitialized) {
            [self requestAdWithCustomEventInfo:info delegate:delegate];
        }
    } else {
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorUnknown userInfo:nil];
        [delegate vungleAdDidFailToLoad:error];
    }
}

- (void)requestBannerAdWithCustomEventInfo:(NSDictionary *)info size:(CGSize)size delegate:(id<VungleRouterDelegate>)delegate {
    [self collectConsentStatusFromMoPub];
    
    // Verify if PlacementID is nil (first MREC request) or PlacementID is the same one requested
    if (self.bannerDelegates.count > 0) {
        if (self.bannerPlacementID != nil && ![[info objectForKey:kVunglePlacementIdKey] isEqualToString:self.bannerPlacementID]) {
            
            MPLogInfo(@"A banner ad type has been already instantiated. Multiple banner ads are not supported with Vungle iOS SDK version %@ and adapter version %@.", VungleSDKVersion, [[[VungleAdapterConfiguration alloc] init] adapterVersion]);
            [delegate vungleAdDidFailToLoad:nil];
            return;
        }
    }
    
    if ([self validateInfoData:info] && CGSizeEqualToSize(size, kVNGMRECSize)) {
        self.bannerPlacementID = [info objectForKey:kVunglePlacementIdKey];
        self.isInvalidatedBannerForPlacementID = NO;
        
        if (self.sdkInitializeState == SDKInitializeStateNotInitialized) {
            if (![self.waitingListDict objectForKey:[info objectForKey:kVunglePlacementIdKey]]) {
                [self.waitingListDict setObject:delegate forKey:[info objectForKey:kVunglePlacementIdKey]];
            }
            [self initializeSdkWithInfo:info];
        } else if (self.sdkInitializeState == SDKInitializeStateInitializing) {
            if (![self.waitingListDict objectForKey:[info objectForKey:kVunglePlacementIdKey]]) {
                [self.waitingListDict setObject:delegate forKey:[info objectForKey:kVunglePlacementIdKey]];
            }
        } else if (self.sdkInitializeState == SDKInitializeStateInitialized) {
            NSString *placementID = [info objectForKey:kVunglePlacementIdKey];
            [self requestBannerMrecAdWithPlacementID:placementID delegate:delegate];
        }
    } else {
        [delegate vungleAdDidFailToLoad:nil];
    }
}

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info delegate:(id<VungleRouterDelegate>)delegate {
    NSString *placementId = [info objectForKey:kVunglePlacementIdKey];
    if (![self.delegatesDict objectForKey:placementId]) {
        [self.delegatesDict setObject:delegate forKey:placementId];
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
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if ([[VungleSDK sharedSDK]  isAdCachedForPlacementID:placementID]) {
        [delegate vungleAdDidLoad];
        
        [dictionary setObject:delegate forKey:kVungleBannerDelegateKey];
        [dictionary setObject:[NSNumber numberWithInt:BannerRouterDelegateStateCached] forKey:kVungleBannerDelegateStateKey];
        [self.bannerDelegates addObject:dictionary];
    } else {
        [dictionary setObject:delegate forKey:kVungleBannerDelegateKey];
        [dictionary setObject:[NSNumber numberWithInt:BannerRouterDelegateStateRequesting] forKey:kVungleBannerDelegateStateKey];
        [self.bannerDelegates addObject:dictionary];
        
        NSError *error = nil;
        
        if ([[VungleSDK sharedSDK] loadPlacementWithID:placementID error:&error]) {
            MPLogInfo(@"Vungle: Start to load an ad for Placement ID :%@", placementID);
        } else {
            if (error) {
                MPLogInfo(@"Vungle: Unable to load an ad for Placement ID :%@, Error %@", placementID, error);
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
            [[self.delegatesDict objectForKey:placementId] vungleAdDidFailToPlay:nil];
            self.isAdPlaying = NO;
        }
    } else {
        [[self.delegatesDict objectForKey:placementId] vungleAdDidFailToPlay:nil];
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
            [[self.delegatesDict objectForKey:placementId] vungleAdDidFailToPlay:nil];
            self.isAdPlaying = NO;
        }
    } else {
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:nil];
        [[self.delegatesDict objectForKey:placementId] vungleAdDidFailToPlay:error];
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
        bannerError = [NSError errorWithDomain:NSStringFromClass([self class]) code:8769 userInfo:@{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Ad not cached for placement %@", placementID]}];
        
    }
    
    MPLogInfo(@"Banner loading error: %@", bannerError.localizedDescription);
    return nil;
}

- (void)completeBannerAdViewForPlacementID:(NSString *)placementID
{
    if (placementID) {
        MPLogInfo(@"Vungle: Triggering an ad completion call for %@", placementID);
        
        for (int i = 0; i < self.bannerDelegates.count; i++) {
            if ((BannerRouterDelegateState)[[self.bannerDelegates[i] valueForKey:kVungleBannerDelegateStateKey] intValue] == BannerRouterDelegateStatePlaying) {
                [[VungleSDK sharedSDK] finishedDisplayingAd];
                [self.bannerDelegates[i] setObject:[NSNumber numberWithInt:BannerRouterDelegateStateClosing] forKey:kVungleBannerDelegateStateKey];
            }
        }
    }
}

- (void)invalidateBannerAdViewForPlacementID:(NSString *)placementID delegate:(id<VungleRouterDelegate>)delegate {
    
    if (placementID) {
        MPLogInfo(@"Vungle: Triggering an ad completion call for %@", placementID);
        
        for (int i = 0; i < self.bannerDelegates.count; i++) {
            if ([self.bannerDelegates[i] valueForKey:kVungleBannerDelegateKey] != delegate) return;
            if (([self.bannerDelegates[i] valueForKey:kVungleBannerDelegateKey] == delegate) && ((BannerRouterDelegateState)[[self.bannerDelegates[i] valueForKey:kVungleBannerDelegateStateKey] intValue] == BannerRouterDelegateStatePlaying)) {
                [[VungleSDK sharedSDK] finishedDisplayingAd];
                [self.bannerDelegates[i] setObject:[NSNumber numberWithInt:BannerRouterDelegateStateClosing] forKey:kVungleBannerDelegateStateKey];
                self.isInvalidatedBannerForPlacementID = YES;
                break;
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
    } else {
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
        [self.delegatesDict removeObjectForKey:placementID];
    } else if (state != BannerRouterDelegateStateUnknown) {
        NSMutableArray *array = [NSMutableArray new];
        
        for (int i = 0; i < self.bannerDelegates.count; i++) {
            if ((BannerRouterDelegateState)[[self.bannerDelegates[i] valueForKey:kVungleBannerDelegateStateKey] intValue] == state) {
                [array addObject:self.bannerDelegates[i]];
            }
        }
        
        [self.bannerDelegates removeObjectsInArray:array];
    }
}

- (void)clearWaitingList {
    for (id key in self.waitingListDict) {
        id<VungleRouterDelegate> delegateInstance = [self.waitingListDict objectForKey:key];
        
        if ([[delegateInstance getPlacementID] isEqualToString:self.bannerPlacementID]) {
            NSString *id = [delegateInstance getPlacementID];
            [self requestBannerMrecAdWithPlacementID:id delegate:delegateInstance];
        } else {
            if (![self.delegatesDict objectForKey:key]) {
                [self.delegatesDict setObject:delegateInstance forKey:key];
            }
            
            NSError *error = nil;
            if ([[VungleSDK sharedSDK] loadPlacementWithID:key error:&error]) {
                MPLogInfo(@"Vungle: Start to load an ad for Placement ID :%@", key);
            } else {
                if (error) {
                    MPLogInfo(@"Vungle: Unable to load an ad for Placement ID :%@, Error %@", key, error);
                }
                [delegateInstance vungleAdDidFailToLoad:error];
            }
        }
    }
    
    [self.waitingListDict removeAllObjects];
}

#pragma mark - VungleSDKDelegate Methods

- (void) vungleSDKDidInitialize {
    MPLogInfo(@"Vungle: the SDK has been initialized successfully.");
    self.sdkInitializeState = SDKInitializeStateInitialized;
    [self clearWaitingList];
}

- (void)vungleAdPlayabilityUpdate:(BOOL)isAdPlayable placementID:(NSString *)placementID error:(NSError *)error {
    if ([placementID isEqualToString:self.bannerPlacementID]) {
        BOOL needToClearDelegate = NO;
        
        for (int i = 0; i < self.bannerDelegates.count; i++) {
            if ((BannerRouterDelegateState)[[self.bannerDelegates[i] valueForKey:kVungleBannerDelegateStateKey] intValue] == BannerRouterDelegateStateRequesting) {
                if (isAdPlayable) {
                    [[self.bannerDelegates[i] objectForKey:kVungleBannerDelegateKey] vungleAdDidLoad];
                    [self.bannerDelegates[i] setObject:[NSNumber numberWithInt:BannerRouterDelegateStateCached] forKey:kVungleBannerDelegateStateKey];
                } else {
                    NSError *playabilityError;
                    if (error) {
                        MPLogInfo(@"Vungle: Ad playability update returned error for Placement ID: %@, Error: %@", placementID, error.localizedDescription);
                        playabilityError = error;
                    }
                    
                    if (!self.isAdPlaying) {
                        [[self.bannerDelegates[i] objectForKey:kVungleBannerDelegateKey] vungleAdDidFailToLoad:playabilityError];
                    }
                    
                    [self.bannerDelegates[i] setObject:[NSNumber numberWithInt:BannerRouterDelegateStateClosed] forKey:kVungleBannerDelegateStateKey];
                    needToClearDelegate = YES;
                }
            }
        }
        
        if (needToClearDelegate) {
            [self clearDelegateWithState:BannerRouterDelegateStateClosed placementID:nil];
        }
    } else {
        if (isAdPlayable) {
            [[self.delegatesDict objectForKey:placementID] vungleAdDidLoad];
        } else {
            if (placementID) {
                NSError *playabilityError;
                if (error) {
                    MPLogInfo(@"Vungle: Ad playability update returned error for Placement ID: %@, Error: %@", placementID, error.localizedDescription);
                    playabilityError = error;
                }
                
                if (!self.isAdPlaying) {
                    [[self.delegatesDict objectForKey:placementID] vungleAdDidFailToLoad:playabilityError];
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
    } else {
        targetDelegate = [self.delegatesDict objectForKey:placementID];
    }
    
    if (targetDelegate && [targetDelegate respondsToSelector:@selector(vungleAdWillAppear)]) {
        [targetDelegate vungleAdWillAppear];
    }
}

- (void)vungleDidShowAdForPlacementID:(NSString *)placementID {
    id<VungleRouterDelegate> targetDelegate = [self.delegatesDict objectForKey:placementID];
    
    if (targetDelegate && [targetDelegate respondsToSelector:@selector(vungleAdDidAppear)]) {
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
    } else {
        targetDelegate = [self.delegatesDict objectForKey:placementID];
    }
    
    if (targetDelegate) {
        if ([info.didDownload isEqual:@YES]) {
            [targetDelegate vungleAdWasTapped];
        }
        
        if ([info.completedView boolValue] && [targetDelegate respondsToSelector:@selector(vungleAdShouldRewardUser)]) {
            [targetDelegate vungleAdShouldRewardUser];
        }
        
        if ([targetDelegate respondsToSelector:@selector(vungleAdWillDisappear)]) {
            [targetDelegate vungleAdWillDisappear];
        }
        self.isAdPlaying = NO;
    }
}

- (void)vungleDidCloseAdWithViewInfo:(VungleViewInfo *)info placementID:(NSString *)placementID {
    id<VungleRouterDelegate> targetDelegate;
    
    if ([placementID isEqualToString:self.bannerPlacementID]) {
        BOOL needToClearDelegate = NO;
        for (int i = 0; i < self.bannerDelegates.count; i++) {
            if ((BannerRouterDelegateState)[[self.bannerDelegates[i] valueForKey:kVungleBannerDelegateStateKey] intValue] == BannerRouterDelegateStateClosing) {
                targetDelegate = [self.bannerDelegates[i] objectForKey:kVungleBannerDelegateKey];
                [self.bannerDelegates[i] setObject:[NSNumber numberWithInt:BannerRouterDelegateStateClosed] forKey:kVungleBannerDelegateStateKey];
                needToClearDelegate = YES;
            }
        }
        
        if (needToClearDelegate) {
            [self clearDelegateWithState:BannerRouterDelegateStateClosed placementID:nil];
        }
        
        if (self.isInvalidatedBannerForPlacementID) {
            self.bannerPlacementID = nil;
            self.isInvalidatedBannerForPlacementID = NO;
        }
    } else {
        targetDelegate = [self.delegatesDict objectForKey:placementID];
    }
    
    if (targetDelegate && [targetDelegate respondsToSelector:@selector(vungleAdDidDisappear)]) {
        [targetDelegate vungleAdDidDisappear];
    }
}

#pragma mark - VungleSDKNativeAds delegate methods

- (void)nativeAdsPlacementDidLoadAd:(NSString *)placement {
    // Ad loaded successfully. We allow the playability update to notify the
    // Banner Custom Event class of successful ad loading.
}

- (void)nativeAdsPlacement:(NSString *)placement didFailToLoadAdWithError:(NSError *)error {
    // Ad failed to load. We allow the playability update to notify the
    // Banner Custom Event class of unsuccessful ad loading.
}

- (void)nativeAdsPlacementWillTriggerURLLaunch:(NSString *)placement {
    [[self.delegatesDict objectForKey:placement] vungleAdWillLeaveApplication];
}

@end
