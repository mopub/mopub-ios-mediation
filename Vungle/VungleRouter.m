//
//  VungleRouter.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#if __has_include("MoPub.h")
    #import "MPLogging.h"
    #import "MPRewardedVideo.h"
    #import "MPRewardedVideoError.h"
    #import "MoPub.h"
#endif
#import <VungleSDK/VungleSDKHeaderBidding.h>
#import "VungleAdapterConfiguration.h"
#import "VungleInstanceMediationSettings.h"
#import "VungleRouter.h"

NSString * const kVungleAppIdKey = @"appId";
NSString * const kVunglePlacementIdKey = @"pid";
NSString * const kVungleFlexViewAutoDismissSeconds = @"flexViewAutoDismissSeconds";
NSString * const kVungleUserId = @"userId";
NSString * const kVungleOrdinal = @"ordinal";
NSString * const kVungleStartMuted = @"muted";
NSString * const kVungleSupportedOrientations = @"orientations";

NSString * const kVungleSDKCollectDevice = @"collectDevice";
NSString * const kVungleSDKMinSpaceForInit = @"vungleMinimumFileSystemSizeForInit";
NSString * const kVungleSDKMinSpaceForAdRequest = @"vungleMinimumFileSystemSizeForAdRequest";
NSString * const kVungleSDKMinSpaceForAssetLoad = @"vungleMinimumFileSystemSizeForAssetDownload";

static NSString * const kVungleBannerDelegateKey = @"bannerDelegate";
static NSString * const kVungleBannerDelegateStateKey = @"bannerState";

const CGSize kVNGMRECSize = {.width = 300.0f, .height = 250.0f};
const CGSize kVNGBannerSize = {.width = 320.0f, .height = 50.0f};
const CGSize kVNGShortBannerSize = {.width = 300.0f, .height = 50.0f};
const CGSize kVNGLeaderboardBannerSize = {.width = 728.0f, .height = 90.0f};

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
@property (nonatomic) BOOL isAdPlaying;
@property (nonatomic) SDKInitializeState sdkInitializeState;

@property (nonatomic) NSMutableDictionary *delegatesDict;
@property (nonatomic) NSMutableDictionary *waitingListDict;
@property (nonatomic) NSMutableArray *bannerDelegates;

@end

@implementation VungleRouter

- (instancetype)init
{
    if (self = [super init]) {
        self.sdkInitializeState = SDKInitializeStateNotInitialized;
        self.delegatesDict = [NSMutableDictionary dictionary];
        self.waitingListDict = [NSMutableDictionary dictionary];
        self.bannerDelegates = [NSMutableArray array];
        self.isAdPlaying = NO;
    }
    return self;
}

+ (VungleRouter *)sharedRouter
{
    static VungleRouter * sharedRouter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedRouter = [[VungleRouter alloc] init];
    });
    return sharedRouter;
}

- (void)collectConsentStatusFromMoPub
{
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

- (void)initializeSdkWithInfo:(NSDictionary *)info
{
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
       
        // Get delegate instance and set init options
        NSString *placementID = [info objectForKey:kVunglePlacementIdKey];
        id<VungleRouterDelegate> delegateInstance = [self.waitingListDict objectForKey:placementID];
        NSMutableDictionary *initOptions = [NSMutableDictionary dictionary];
        
        if (placementID.length && delegateInstance) {
            [initOptions setObject:placementID forKey:VungleSDKInitOptionKeyPriorityPlacementID];

            NSInteger priorityPlacementAdSize = 1;
            if ([delegateInstance respondsToSelector:@selector(getBannerSize)]) {
                CGSize size = [delegateInstance getBannerSize];
                priorityPlacementAdSize = [self getVungleBannerAdSizeType:size];
                [initOptions setObject:[NSNumber numberWithInteger:priorityPlacementAdSize] forKey:VungleSDKInitOptionKeyPriorityPlacementAdSize];
            }
        }
              
        self.sdkInitializeState = SDKInitializeStateInitializing;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError * error = nil;
            // Disable refresh functionality for all banners
            [[VungleSDK sharedSDK] disableBannerRefresh];
            [[VungleSDK sharedSDK] startWithAppId:appId options:initOptions error:&error];
            [[VungleSDK sharedSDK] setDelegate:self];
            [[VungleSDK sharedSDK] setNativeAdsDelegate:self];
        });
    });
}

- (void)setShouldCollectDeviceId:(BOOL)shouldCollectDeviceId
{
    // This should ONLY be set if the SDK has not been initialized
    if (self.sdkInitializeState == SDKInitializeStateNotInitialized) {
        [VungleSDK setPublishIDFV:shouldCollectDeviceId];
    }
}

- (void)setSDKOptions:(NSDictionary *)sdkOptions
{
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

- (void)requestInterstitialAdWithCustomEventInfo:(NSDictionary *)info
                                        delegate:(id<VungleRouterDelegate>)delegate
{
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

- (void)requestRewardedVideoAdWithCustomEventInfo:(NSDictionary *)info
                                         delegate:(id<VungleRouterDelegate>)delegate
{
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

- (void)requestBannerAdWithCustomEventInfo:(NSDictionary *)info
                                      size:(CGSize)size
                                  delegate:(id<VungleRouterDelegate>)delegate
{
    [self collectConsentStatusFromMoPub];
    
    if ([self validateInfoData:info] && (CGSizeEqualToSize(size, kVNGMRECSize) ||
                                         CGSizeEqualToSize(size, kVNGBannerSize) ||
                                         CGSizeEqualToSize(size, kVNGLeaderboardBannerSize) ||
                                         CGSizeEqualToSize(size, kVNGShortBannerSize))) {
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
            [self requestBannerAdWithPlacementID:placementID size:size delegate:delegate];
        }
    } else {
        MPLogError(@"A banner ad type was requested with the size which Vungle SDK doesn't support.");
        [delegate vungleAdDidFailToLoad:nil];
    }
}

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info
                            delegate:(id<VungleRouterDelegate>)delegate
{
    NSString *placementId = [info objectForKey:kVunglePlacementIdKey];
    if (![self.delegatesDict objectForKey:placementId]) {
        [self.delegatesDict setObject:delegate forKey:placementId];
    }
    
    NSError *error = nil;
    if ([[VungleSDK sharedSDK] loadPlacementWithID:placementId error:&error]) {
        MPLogInfo(@"Vungle: Start to load an ad for Placement ID :%@", placementId);
    } else {
        if (error) {
            MPLogError(@"Vungle: Unable to load an ad for Placement ID :%@, Error %@", placementId, error);
        }
        [delegate vungleAdDidFailToLoad:error];
    }
}

- (void)requestBannerAdWithPlacementID:(NSString *)placementID
                                  size:(CGSize)size
                              delegate:(id<VungleRouterDelegate>)delegate
{
    @synchronized (self ) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        if ([self isBannerAdAvailableForPlacementId:placementID size:size]) {
            [delegate vungleAdDidLoad];

            [dictionary setObject:delegate forKey:kVungleBannerDelegateKey];
            [dictionary setObject:[NSNumber numberWithInt:BannerRouterDelegateStateCached] forKey:kVungleBannerDelegateStateKey];
            [self.bannerDelegates addObject:dictionary];
        } else {
            [dictionary setObject:delegate forKey:kVungleBannerDelegateKey];
            [dictionary setObject:[NSNumber numberWithInt:BannerRouterDelegateStateRequesting] forKey:kVungleBannerDelegateStateKey];
            [self.bannerDelegates addObject:dictionary];

            NSError *error = nil;
            if (CGSizeEqualToSize(size, kVNGMRECSize)) {
                if ([[VungleSDK sharedSDK] loadPlacementWithID:placementID error:&error]) {
                    MPLogInfo(@"Vungle: Start to load an ad for Placement ID :%@", placementID);
                } else {
                    [self requestBannerAdFailedWithError:error
                                             placementID:placementID
                                                delegate:delegate];
                }
            } else {
                if ([[VungleSDK sharedSDK] loadPlacementWithID:placementID withSize:[self getVungleBannerAdSizeType:size] error:&error]) {
                    MPLogInfo(@"Vungle: Start to load an ad for Placement ID :%@", placementID);
                } else {
                    if ((error) && (error.code != VungleSDKResetPlacementForDifferentAdSize)) {
                        [self requestBannerAdFailedWithError:error
                                                 placementID:placementID
                                                    delegate:delegate];
                    }
                }
            }
        }
    }
}

- (BOOL)isAdAvailableForPlacementId:(NSString *)placementId
{
    return [[VungleSDK sharedSDK] isAdCachedForPlacementID:placementId];
}

- (BOOL)isBannerAdAvailableForPlacementId:(NSString *)placementId size:(CGSize)size
{
    if (CGSizeEqualToSize(size, kVNGMRECSize)) {
        return [[VungleSDK sharedSDK] isAdCachedForPlacementID:placementId];
    }

    return [[VungleSDK sharedSDK] isAdCachedForPlacementID:placementId
                                                  withSize:[self getVungleBannerAdSizeType:size]];
}

- (NSString *)currentSuperToken {
    if (self.sdkInitializeState == SDKInitializeStateInitialized) {
        return [[VungleSDK sharedSDK] currentSuperToken];
    }
    return nil;
}

- (void)presentInterstitialAdFromViewController:(UIViewController *)viewController
                                        options:(NSDictionary *)options
                                 forPlacementId:(NSString *)placementId
{
    if (!self.isAdPlaying && [self isAdAvailableForPlacementId:placementId]) {
        self.isAdPlaying = YES;
        NSError *error = nil;
        BOOL success = [[VungleSDK sharedSDK] playAd:viewController options:options placementID:placementId error:&error];
        if (!success) {
            [[self.delegatesDict objectForKey:placementId] vungleAdDidFailToPlay:error ?: [NSError errorWithCode:MOPUBErrorVideoPlayerFailedToPlay localizedDescription:@"Failed to play Vungle Interstitial Ad."]];
            self.isAdPlaying = NO;
        }
    } else {
        [[self.delegatesDict objectForKey:placementId] vungleAdDidFailToPlay:nil];
    }
}

- (void)presentRewardedVideoAdFromViewController:(UIViewController *)viewController
                                      customerId:(NSString *)customerId
                                        settings:(VungleInstanceMediationSettings *)settings
                                  forPlacementId:(NSString *)placementId
{
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
        
        NSError *error = nil;
        BOOL success = [[VungleSDK sharedSDK] playAd:viewController options:options placementID:placementId error:&error];
        
        if (!success) {
            [[self.delegatesDict objectForKey:placementId] vungleAdDidFailToPlay:error ?: [NSError errorWithCode:MOPUBErrorVideoPlayerFailedToPlay localizedDescription:@"Failed to play Vungle Rewarded Video Ad."]];
            self.isAdPlaying = NO;
        }
    } else {
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:nil];
        [[self.delegatesDict objectForKey:placementId] vungleAdDidFailToPlay:error];
    }
}

- (UIView *)renderBannerAdInView:(UIView *)bannerView
                         options:(NSDictionary *)options
                  forPlacementID:(NSString *)placementID
                            size:(CGSize)size
{
    NSError *bannerError = nil;
    
    if ([self isBannerAdAvailableForPlacementId:placementID size:size]) {
        BOOL success = [[VungleSDK sharedSDK] addAdViewToView:bannerView withOptions:options placementID:placementID error:&bannerError];
        
        if (success) {
            return bannerView;
        }
    } else {
        bannerError = [NSError errorWithDomain:NSStringFromClass([self class]) code:8769 userInfo:@{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Ad not cached for placement %@", placementID]}];
    }
    
    MPLogError(@"Banner loading error: %@", bannerError.localizedDescription);
    return nil;
}

- (void)completeBannerAdViewForPlacementID:(NSString *)placementID
{
    @synchronized (self) {
        if (placementID.length > 0) {
            MPLogInfo(@"Vungle: Triggering an ad completion call for %@", placementID);
            for (int i = 0; i < self.bannerDelegates.count; i++) {
                if (([[(id<VungleRouterDelegate>)[self.bannerDelegates[i] valueForKey:kVungleBannerDelegateKey] getPlacementID] isEqualToString:placementID]) && ((BannerRouterDelegateState)[[self.bannerDelegates[i] valueForKey:kVungleBannerDelegateStateKey] intValue] == BannerRouterDelegateStatePlaying)) {
                    [[VungleSDK sharedSDK] finishDisplayingAd:placementID];
                    [self.bannerDelegates[i] setObject:[NSNumber numberWithInt:BannerRouterDelegateStateClosing] forKey:kVungleBannerDelegateStateKey];
                    break;
                }
            }
        }
    }
}

- (void)invalidateBannerAdViewForPlacementID:(NSString *)placementID
                                    delegate:(id<VungleRouterDelegate>)delegate
{
    @synchronized (self) {
        if (placementID.length > 0) {
            MPLogInfo(@"Vungle: Triggering a Banner ad invalidation for %@", placementID);
            for (int i = 0; i < self.bannerDelegates.count; i++) {
                if ([self.bannerDelegates[i] valueForKey:kVungleBannerDelegateKey] == delegate) {
                    if ((BannerRouterDelegateState)[[self.bannerDelegates[i] valueForKey:kVungleBannerDelegateStateKey] intValue] == BannerRouterDelegateStatePlaying) {
                        [[VungleSDK sharedSDK] finishDisplayingAd:placementID];
                        [self.bannerDelegates[i] setObject:[NSNumber numberWithInt:BannerRouterDelegateStateClosing] forKey:kVungleBannerDelegateStateKey];
                    } else {
                        [self.bannerDelegates removeObjectAtIndex:i];
                    }
                    break;
                }
            }
        }
    }
}

- (void)updateConsentStatus:(VungleConsentStatus)status
{
    [[VungleSDK sharedSDK] updateConsentStatus:status consentMessageVersion:@""];
}

- (VungleConsentStatus)getCurrentConsentStatus
{
    return [[VungleSDK sharedSDK] getCurrentConsentStatus];
}

- (void)clearDelegateForRequestingBanner
{
    [self clearDelegateWithState:BannerRouterDelegateStateRequesting placementID:nil];
}

- (void)clearDelegateForPlacementId:(NSString *)placementId
{
    [self clearDelegateWithState:BannerRouterDelegateStateUnknown placementID:placementId];
}

#pragma mark - private

- (BOOL)validateInfoData:(NSDictionary *)info
{
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

- (void)clearDelegateWithState:(BannerRouterDelegateState)state placementID:(NSString *)placementID
{
    @synchronized (self) {
        if (placementID.length > 0) {
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
}

- (void)clearWaitingList
{
    for (id key in self.waitingListDict) {
        id<VungleRouterDelegate> delegateInstance = [self.waitingListDict objectForKey:key];
        
        if ([delegateInstance respondsToSelector:@selector(getBannerSize)]) {
            NSString *id = [delegateInstance getPlacementID];
            CGSize size = [delegateInstance getBannerSize];
            [self requestBannerAdWithPlacementID:id size:size delegate:delegateInstance];
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

- (void)requestBannerAdFailedWithError:(NSError *)error
                           placementID:(NSString *)placementID
                              delegate:(id<VungleRouterDelegate>)delegate
{
    if (error) {
        MPLogError(@"Vungle: Unable to load an ad for Placement ID :%@, Error %@", placementID, error);
    } else {
        error = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd
                  localizedDescription:[NSString stringWithFormat:@"Vungle: Unable to load an ad for Placement ID :%@.", placementID]];
    }
    [delegate vungleAdDidFailToLoad:error];
}

- (VungleAdSize)getVungleBannerAdSizeType:(CGSize)size
{
    if (CGSizeEqualToSize(size, kVNGBannerSize)) {
        return VungleAdSizeBanner;
    } else if (CGSizeEqualToSize(size, kVNGShortBannerSize)) {
        return VungleAdSizeBannerShort;
    } else if (CGSizeEqualToSize(size, kVNGLeaderboardBannerSize)) {
        return VungleAdSizeBannerLeaderboard;
    }
    
    return VungleAdSizeUnknown;
}

- (id<VungleRouterDelegate>)getDelegateWithPlacement:(NSString *)placementID
                                     withBannerState:(BannerRouterDelegateState)state {
    if (!placementID.length) {
        return nil;
    }

    @synchronized (self) {
        id<VungleRouterDelegate> targetDelegate = [self.delegatesDict objectForKey:placementID];
        if (!targetDelegate) {
            for (int i = 0; i < self.bannerDelegates.count; i++) {
                if (([[(id<VungleRouterDelegate>)[self.bannerDelegates[i] valueForKey:kVungleBannerDelegateKey] getPlacementID] isEqualToString:placementID]) && ((BannerRouterDelegateState)[[self.bannerDelegates[i] valueForKey:kVungleBannerDelegateStateKey] intValue] == state)) {
                    targetDelegate = [self.bannerDelegates[i] objectForKey:kVungleBannerDelegateKey];
                    break;
                }
            }
        }
        return targetDelegate;
    }
}

#pragma mark - VungleSDKDelegate Methods

- (void) vungleSDKDidInitialize
{
    MPLogInfo(@"Vungle: the SDK has been initialized successfully.");
    self.sdkInitializeState = SDKInitializeStateInitialized;
    [self clearWaitingList];
}

- (void)vungleAdPlayabilityUpdate:(BOOL)isAdPlayable
                      placementID:(NSString *)placementID
                            error:(NSError *)error
{
    if (!placementID.length) {
        return;
    }

    if ([self.delegatesDict objectForKey:placementID]) {
        if (isAdPlayable) {
            [[self.delegatesDict objectForKey:placementID] vungleAdDidLoad];
        } else {
            NSError *playabilityError = nil;
            if (error) {
                MPLogInfo(@"Vungle: Ad playability update returned error for Placement ID: %@, Error: %@", placementID, error.localizedDescription);
                playabilityError = error;
            } else {
                playabilityError = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd localizedDescription:@"Vungle: Ad playability update returned Ad is not playable."];
            }

            if (!self.isAdPlaying) {
                [[self.delegatesDict objectForKey:placementID] vungleAdDidFailToLoad:playabilityError];
            }
        }
    } else {
        @synchronized (self) {
            BOOL needToClearDelegate = NO;
            for (int i = 0; i < self.bannerDelegates.count; i++) {
                if (([[(id<VungleRouterDelegate>)[self.bannerDelegates[i] valueForKey:kVungleBannerDelegateKey] getPlacementID] isEqualToString:placementID]) && ((BannerRouterDelegateState)[[self.bannerDelegates[i] valueForKey:kVungleBannerDelegateStateKey] intValue] == BannerRouterDelegateStateRequesting)) {
                    if (isAdPlayable) {
                        [[self.bannerDelegates[i] objectForKey:kVungleBannerDelegateKey] vungleAdDidLoad];
                        [self.bannerDelegates[i] setObject:[NSNumber numberWithInt:BannerRouterDelegateStateCached] forKey:kVungleBannerDelegateStateKey];
                    } else {
                        NSError *playabilityError = nil;
                        if (error) {
                            MPLogInfo(@"Vungle: Ad playability update returned error for Placement ID: %@, Error: %@", placementID, error.localizedDescription);
                            playabilityError = error;
                        } else {
                            playabilityError = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd localizedDescription:@"Vungle: Ad playability update returned Ad is not playable."];
                        }
                        [[self.bannerDelegates[i] objectForKey:kVungleBannerDelegateKey] vungleAdDidFailToLoad:playabilityError];

                        [self.bannerDelegates[i] setObject:[NSNumber numberWithInt:BannerRouterDelegateStateClosed] forKey:kVungleBannerDelegateStateKey];
                        needToClearDelegate = YES;
                    }
                }
            }

            if (needToClearDelegate) {
                [self clearDelegateWithState:BannerRouterDelegateStateClosed placementID:nil];
            }
        }
    }
}

- (void)vungleWillShowAdForPlacementID:(nullable NSString *)placementID
{
    if (!placementID.length) {
        return;
    }

    id<VungleRouterDelegate> targetDelegate = [self.delegatesDict objectForKey:placementID];
    if (!targetDelegate) {
        @synchronized (self) {
            for (int i = 0; i < self.bannerDelegates.count; i++) {
                if (([[(id<VungleRouterDelegate>)[self.bannerDelegates[i] valueForKey:kVungleBannerDelegateKey] getPlacementID] isEqualToString:placementID]) && ((BannerRouterDelegateState)[[self.bannerDelegates[i] valueForKey:kVungleBannerDelegateStateKey] intValue] == BannerRouterDelegateStateCached)) {
                    [self.bannerDelegates[i] setObject:[NSNumber numberWithInt:BannerRouterDelegateStatePlaying] forKey:kVungleBannerDelegateStateKey];
                    break;
                }
            }
        }
    }

    if ([targetDelegate respondsToSelector:@selector(vungleAdWillAppear)]) {
        [targetDelegate vungleAdWillAppear];
    }
}

- (void)vungleDidShowAdForPlacementID:(NSString *)placementID
{
    id<VungleRouterDelegate> targetDelegate = [self.delegatesDict objectForKey:placementID];
    if ([targetDelegate respondsToSelector:@selector(vungleAdDidAppear)]) {
        [targetDelegate vungleAdDidAppear];
    }
}

- (void)vungleWillCloseAdForPlacementID:(nonnull NSString *)placementID
{
    id<VungleRouterDelegate> targetDelegate = [self.delegatesDict objectForKey:placementID];
    if ([targetDelegate respondsToSelector:@selector(vungleAdWillDisappear)]) {
        [targetDelegate vungleAdWillDisappear];
        self.isAdPlaying = NO;
    }
}

- (void)vungleDidCloseAdForPlacementID:(nonnull NSString *)placementID
{
    if (!placementID.length) {
        return;
    }

    id<VungleRouterDelegate> targetDelegate = [self.delegatesDict objectForKey:placementID];
    if (!targetDelegate) {
        @synchronized (self) {
            BOOL needToClearDelegate = NO;
            for (int i = 0; i < self.bannerDelegates.count; i++) {
                if (([[(id<VungleRouterDelegate>)[self.bannerDelegates[i] valueForKey:kVungleBannerDelegateKey] getPlacementID] isEqualToString:placementID]) && ((BannerRouterDelegateState)[[self.bannerDelegates[i] valueForKey:kVungleBannerDelegateStateKey] intValue] == BannerRouterDelegateStateClosing)) {
                    [self.bannerDelegates[i] setObject:[NSNumber numberWithInt:BannerRouterDelegateStateClosed] forKey:kVungleBannerDelegateStateKey];
                    needToClearDelegate = YES;
                }
            }

            if (needToClearDelegate) {
                [self clearDelegateWithState:BannerRouterDelegateStateClosed placementID:nil];
            }
        }
    }

    if ([targetDelegate respondsToSelector:@selector(vungleAdDidDisappear)]) {
        [targetDelegate vungleAdDidDisappear];
    }
}

- (void)vungleTrackClickForPlacementID:(nullable NSString *)placementID
{
    id<VungleRouterDelegate> targetDelegate = [self getDelegateWithPlacement:placementID
                                                             withBannerState:BannerRouterDelegateStatePlaying];
    [targetDelegate vungleAdTrackClick];
}

- (void)vungleRewardUserForPlacementID:(nullable NSString *)placementID
{
    id<VungleRouterDelegate> targetDelegate = [self.delegatesDict objectForKey:placementID];
    if ([targetDelegate respondsToSelector:@selector(vungleAdRewardUser)]) {
        [targetDelegate vungleAdRewardUser];
    }
}

- (void)vungleWillLeaveApplicationForPlacementID:(nullable NSString *)placementID
{
    id<VungleRouterDelegate> targetDelegate = [self getDelegateWithPlacement:placementID
                                                             withBannerState:BannerRouterDelegateStatePlaying];
    [targetDelegate vungleAdWillLeaveApplication];
}

#pragma mark - VungleSDKNativeAds delegate methods

- (void)nativeAdsPlacementDidLoadAd:(NSString *)placement
{
    // Ad loaded successfully. We allow the playability update to notify the
    // Banner Custom Event class of successful ad loading.
}

- (void)nativeAdsPlacement:(NSString *)placement didFailToLoadAdWithError:(NSError *)error
{
    // Ad failed to load. We allow the playability update to notify the
    // Banner Custom Event class of unsuccessful ad loading.
}

- (void)nativeAdsPlacementWillTriggerURLLaunch:(NSString *)placement
{
    [[self.delegatesDict objectForKey:placement] vungleAdWillLeaveApplication];
}

@end
