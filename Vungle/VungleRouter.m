//
//  VungleRouter.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import <VungleSDK/VungleSDK.h>
#import <VungleSDK/VungleSDKHeaderBidding.h>
#import <VungleSDK/VungleSDKNativeAds.h>
#if __has_include("MoPub.h")
    #import "MPLogging.h"
    #import "MoPub.h"
#endif
#import "VungleAdapterConfiguration.h"
#import "VungleInstanceMediationSettings.h"
#import "VungleRouter.h"

NSString *const kVungleAppIdKey = @"appId";
NSString *const kVunglePlacementIdKey = @"pid";
NSString *const kVungleUserId = @"userId";
NSString *const kVungleOrdinal = @"ordinal";
NSString *const kVungleStartMuted = @"muted";
NSString *const kVungleSupportedOrientations = @"orientations";

NSString *const kVungleSDKCollectDevice = @"collectDevice";
NSString *const kVungleSDKMinSpaceForInit = @"vungleMinimumFileSystemSizeForInit";
NSString *const kVungleSDKMinSpaceForAdRequest = @"vungleMinimumFileSystemSizeForAdRequest";
NSString *const kVungleSDKMinSpaceForAssetLoad = @"vungleMinimumFileSystemSizeForAssetDownload";

const CGSize kVNGMRECSize = {.width = 300.0f, .height = 250.0f};
const CGSize kVNGBannerSize = {.width = 320.0f, .height = 50.0f};
const CGSize kVNGShortBannerSize = {.width = 300.0f, .height = 50.0f};
const CGSize kVNGLeaderboardBannerSize = {.width = 728.0f, .height = 90.0f};

typedef NS_ENUM(NSUInteger, SDKInitializeState) {
    SDKInitializeStateNotInitialized,
    SDKInitializeStateInitializing,
    SDKInitializeStateInitialized
};

@interface VungleRouter () <VungleSDKDelegate, VungleSDKNativeAds, VungleSDKHBDelegate>

@property (nonatomic, copy) NSString *vungleAppID;
@property (nonatomic, weak) id<VungleRouterDelegate> playingFullScreenAdDelegate;
@property (nonatomic) SDKInitializeState sdkInitializeState;

@property (nonatomic) NSMutableDictionary *waitingListDict;
@property (nonatomic) NSMapTable<NSString *, id<VungleRouterDelegate>> *delegatesDict;
@property (nonatomic) NSMapTable<NSString *, id<VungleRouterDelegate>> *bannerDelegates;

@end

@implementation VungleRouter

- (instancetype)init
{
    if (self = [super init]) {
        self.sdkInitializeState = SDKInitializeStateNotInitialized;
        self.delegatesDict = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory
                                                   valueOptions:NSPointerFunctionsWeakMemory];
        self.waitingListDict = [NSMutableDictionary dictionary];
        self.bannerDelegates = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory
                                                     valueOptions:NSPointerFunctionsWeakMemory];
        self.playingFullScreenAdDelegate = nil;
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
            BOOL started = [[VungleSDK sharedSDK] startWithAppId:appId options:initOptions error:&error];
            if (!started && error.code == VungleSDKErrorSDKAlreadyInitializing) {
                MPLogInfo(@"Vungle:SDK already has been initialized.");
                self.sdkInitializeState = SDKInitializeStateInitialized;
                [self clearWaitingList];
            }
            [[VungleSDK sharedSDK] setDelegate:self];
            [[VungleSDK sharedSDK] setNativeAdsDelegate:self];
            [[VungleSDK sharedSDK] setSdkHBDelegate:self];
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
            [self addToWaitingListWithDelegate:delegate];
            [self initializeSdkWithInfo:info];
        }
        else if (self.sdkInitializeState == SDKInitializeStateInitializing) {
            [self addToWaitingListWithDelegate:delegate];
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
            [self addToWaitingListWithDelegate:delegate];
            [self initializeSdkWithInfo:info];
        }
        else if (self.sdkInitializeState == SDKInitializeStateInitializing) {
            [self addToWaitingListWithDelegate:delegate];
        }
        else if (self.sdkInitializeState == SDKInitializeStateInitialized) {
            [self requestAdWithCustomEventInfo:info delegate:delegate];
        }
    } else {
        NSError *error = [NSError errorWithDomain:MoPubRewardedAdsSDKDomain code:MPRewardedAdErrorUnknown userInfo:nil];
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
            [self addToWaitingListWithDelegate:delegate];
            [self initializeSdkWithInfo:info];
        } else if (self.sdkInitializeState == SDKInitializeStateInitializing) {
            [self addToWaitingListWithDelegate:delegate];
        } else if (self.sdkInitializeState == SDKInitializeStateInitialized) {
            [self requestBannerAdWithDelegate:delegate];
        }
    } else {
        MPLogError(@"Vungle: A banner ad type was requested with the size which Vungle SDK doesn't support.");
        [delegate vungleAdDidFailToLoad:nil];
    }
}

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info
                            delegate:(id<VungleRouterDelegate>)delegate
{
    [self setDelegateIntoTable:self.delegatesDict delegate:delegate];
    
    if ([self isAdAvailableForDelegate:delegate]) {
        MPLogDebug(@"Vungle: Placement ID is already cached. Trigger DidLoadAd delegate directly: %@", [delegate getPlacementID]);
        [delegate vungleAdDidLoad];
        return;
    }

    NSString *placementId = [delegate getPlacementID];
    NSError *error = nil;
    if ([[VungleSDK sharedSDK] loadPlacementWithID:placementId adMarkup:[delegate getAdMarkup] error:&error]) {
        MPLogInfo(@"Vungle: Start to load an ad for Placement ID :%@", placementId);
    } else {
        if (error) {
            MPLogError(@"Vungle: Unable to load an ad for Placement ID :%@, Error %@", placementId, error);
        }
        [delegate vungleAdDidFailToLoad:error];
    }
}

- (void)requestBannerAdWithDelegate:(id<VungleRouterDelegate>)delegate
{
    @synchronized (self) {
        [self setDelegateIntoTable:self.bannerDelegates delegate:delegate];
        
        NSString *placementID = [delegate getPlacementID];
        if ([self isBannerAdAvailableForDelegate:delegate]) {
            MPLogInfo(@"Vungle: Banner ad already cached for Placement ID :%@", placementID);
            delegate.bannerState = BannerRouterDelegateStateCached;
            [delegate vungleAdDidLoad];
        } else {
            delegate.bannerState = BannerRouterDelegateStateRequesting;
            
            CGSize size = [delegate getBannerSize];
            NSError *error = nil;
            if (CGSizeEqualToSize(size, kVNGMRECSize)) {
                if ([[VungleSDK sharedSDK] loadPlacementWithID:placementID adMarkup:[delegate getAdMarkup] error:&error]) {
                    MPLogInfo(@"Vungle: Start to load an ad for Placement ID :%@", placementID);
                } else {
                    [self requestBannerAdFailedWithError:error
                                             placementID:placementID
                                                delegate:delegate];
                }
            } else {
                if ([[VungleSDK sharedSDK] loadPlacementWithID:placementID adMarkup:[delegate getAdMarkup] withSize:[self getVungleBannerAdSizeType:size] error:&error]) {
                    MPLogInfo(@"Vungle: Start to load an ad for Placement ID :%@", placementID);
                } else {
                    [self requestBannerAdFailedWithError:error
                                             placementID:placementID
                                                delegate:delegate];
                }
            }
        }
    }
}

- (BOOL)isAdAvailableForDelegate:(id<VungleRouterDelegate>)delegate
{
    return [[VungleSDK sharedSDK] isAdCachedForPlacementID:[delegate getPlacementID] adMarkup:[delegate getAdMarkup]];
}

- (BOOL)isBannerAdAvailableForDelegate:(id<VungleRouterDelegate>)delegate
{
    CGSize size = [delegate getBannerSize];
    NSString *placementId = [delegate getPlacementID];
    NSString *adMarkup = [delegate getAdMarkup];
    if (CGSizeEqualToSize(size, kVNGMRECSize)) {
        return [[VungleSDK sharedSDK] isAdCachedForPlacementID:placementId adMarkup:adMarkup];
    }

    return [[VungleSDK sharedSDK] isAdCachedForPlacementID:placementId adMarkup:adMarkup
                                                  withSize:[self getVungleBannerAdSizeType:size]];
}

- (NSString *)currentSuperToken {
    return [[VungleSDK sharedSDK] currentSuperTokenForSize:1000];
}

- (void)presentInterstitialAdFromViewController:(UIViewController *)viewController
                                        options:(NSDictionary *)options
                                       delegate:(id<VungleRouterDelegate>)delegate
{
    if (self.playingFullScreenAdDelegate) {
        if ([[self getKeyFromDelegate:self.playingFullScreenAdDelegate] isEqualToString:[self getKeyFromDelegate:delegate]]) {
            MPLogDebug(@"Vungle: Attempting to play the same placement %@", [delegate getPlacementID]);
            return;
        }
        
        MPLogDebug(@"Vungle: Another full screen ad is already playing: %@. Cannot display %@", [self getKeyFromDelegate:self.playingFullScreenAdDelegate], [self getKeyFromDelegate:delegate]);
        [delegate vungleAdDidFailToPlay:nil];
        return;
    }
    
    if (![self isAdAvailableForDelegate:delegate]) {
        MPLogDebug(@"Vungle: Placement no longer available. Unable to display: %@", [delegate getPlacementID]);
        [delegate vungleAdDidFailToPlay:nil];
        return;
    }
    
    NSString *placementId = [delegate getPlacementID];
    self.playingFullScreenAdDelegate = delegate;
    NSError *error = nil;
    BOOL success = [[VungleSDK sharedSDK] playAd:viewController options:options placementID:placementId adMarkup:[delegate getAdMarkup] error:&error];
    if (!success) {
        [delegate vungleAdDidFailToPlay:error ?: [NSError errorWithCode:MOPUBErrorVideoPlayerFailedToPlay localizedDescription:@"Failed to play Vungle Interstitial Ad."]];
        self.playingFullScreenAdDelegate = nil;
    }
}

- (void)presentRewardedVideoAdFromViewController:(UIViewController *)viewController
                                      customerId:(NSString *)customerId
                                        settings:(VungleInstanceMediationSettings *)settings
                                        delegate:(id<VungleRouterDelegate>)delegate
{
    if (self.playingFullScreenAdDelegate) {
        if ([[self getKeyFromDelegate:self.playingFullScreenAdDelegate] isEqualToString:[self getKeyFromDelegate:delegate]]) {
            MPLogDebug(@"Vungle: Attempting to play the same placement %@", [delegate getPlacementID]);
            return;
        }
        
        MPLogDebug(@"Vungle: Another full screen ad is already playing: %@. Cannot display %@", [self getKeyFromDelegate:self.playingFullScreenAdDelegate], [self getKeyFromDelegate:delegate]);
        NSError *error = [NSError errorWithDomain:MoPubRewardedAdsSDKDomain code:MPRewardedAdErrorNoAdsAvailable userInfo:nil];
        [delegate vungleAdDidFailToPlay:error];
        return;
    }
    
    if (![self isAdAvailableForDelegate:delegate]) {
        MPLogDebug(@"Vungle: Placement no longer available. Unable to display: %@", [delegate getPlacementID]);
        NSError *error = [NSError errorWithDomain:MoPubRewardedAdsSDKDomain code:MPRewardedAdErrorNoAdsAvailable userInfo:nil];
        [delegate vungleAdDidFailToPlay:error];
        return;
    }
    
    NSString *placementId = [delegate getPlacementID];
    self.playingFullScreenAdDelegate = delegate;
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    if (customerId.length > 0) {
        options[VunglePlayAdOptionKeyUser] = customerId;
    } else if (settings && settings.userIdentifier.length > 0) {
        options[VunglePlayAdOptionKeyUser] = settings.userIdentifier;
    }
    if (settings.ordinal > 0) {
        options[VunglePlayAdOptionKeyOrdinal] = @(settings.ordinal);
    }
    if (settings.startMuted) {
        options[VunglePlayAdOptionKeyStartMuted] = @(settings.startMuted);
    }
    
    int appOrientation = [settings.orientations intValue];
    if (appOrientation == 0 && [VungleAdapterConfiguration orientations] != nil) {
        appOrientation = [[VungleAdapterConfiguration orientations] intValue];
    }
    
    NSNumber *orientations = @(UIInterfaceOrientationMaskAll);
    if (appOrientation == 1) {
        orientations = @(UIInterfaceOrientationMaskLandscape);
    } else if (appOrientation == 2) {
        orientations = @(UIInterfaceOrientationMaskPortrait);
    }
    
    options[VunglePlayAdOptionKeyOrientations] = orientations;
    
    NSError *error = nil;
    BOOL success = [[VungleSDK sharedSDK] playAd:viewController options:options placementID:placementId adMarkup:[delegate getAdMarkup] error:&error];
    if (!success) {
        [delegate vungleAdDidFailToPlay:error ?: [NSError errorWithCode:MOPUBErrorVideoPlayerFailedToPlay localizedDescription:@"Failed to play Vungle Rewarded Video Ad."]];
        self.playingFullScreenAdDelegate = nil;
    }
}

- (UIView *)renderBannerAdInView:(UIView *)bannerView
                        delegate:(id<VungleRouterDelegate>)delegate
                         options:(NSDictionary *)options
                  forPlacementID:(NSString *)placementID
                            size:(CGSize)size
{
    NSError *bannerError = nil;
    
    if ([self isBannerAdAvailableForDelegate:delegate]) {
        BOOL success = [[VungleSDK sharedSDK] addAdViewToView:bannerView withOptions:options placementID:placementID adMarkup:[delegate getAdMarkup] error:&bannerError];
        
        if (success) {
            [self completeOldBannerAdViewForDelegate:delegate];
            MPLogInfo(@"Vungle: Rendering a Banner ad for %@ adMarkup %@", placementID, [delegate getAdMarkup]);
            // For a refresh banner delegate, if the Banner view is constructed successfully,
            // it will replace the old banner delegate.
            [self replaceOldBannerDelegateWithDelegate:delegate];
            return bannerView;
        }
    } else {
        bannerError = [NSError errorWithDomain:NSStringFromClass([self class]) code:8769 userInfo:@{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Ad not cached for placement %@", placementID]}];
    }
    
    MPLogError(@"Vungle: Banner loading error: %@", bannerError.localizedDescription);
    return nil;
}

- (void)completeOldBannerAdViewForDelegate:(id<VungleRouterDelegate>)newDelegate
{
    @synchronized (self) {
        NSString *placementID = [newDelegate getPlacementID];
        id<VungleRouterDelegate> oldDelegate;
        NSMapTable<NSString *, id<VungleRouterDelegate>> *bannerDelegatesCopy = [self.bannerDelegates mutableCopy];
        for(NSString *key in bannerDelegatesCopy) {
            oldDelegate = [bannerDelegatesCopy objectForKey:key];
            if ([key containsString:placementID] && [oldDelegate bannerState] == BannerRouterDelegateStatePlaying) {
                BOOL isHeaderBidding = [newDelegate getAdMarkup] || [oldDelegate getAdMarkup];
                if (isHeaderBidding && [oldDelegate getAdMarkup] == [newDelegate getAdMarkup]) {
                    continue;
                }
                MPLogInfo(@"Vungle: Triggering a Banner ad completion call in refresh for %@ adMarkup: %@", placementID, [oldDelegate getAdMarkup]);
                [[VungleSDK sharedSDK] finishDisplayingAd:placementID adMarkup:[oldDelegate getAdMarkup]];
                oldDelegate.bannerState = BannerRouterDelegateStateClosing;
                [self.bannerDelegates removeObjectForKey:[self getKeyFromDelegate:oldDelegate]];
            }
        }
    }
}

- (void)completeBannerAdViewForDelegate:(id<VungleRouterDelegate>)delegate
{
    @synchronized (self) {
        if ([delegate bannerState] == BannerRouterDelegateStatePlaying) {
            MPLogInfo(@"Vungle: Triggering a Banner ad completion call in dealloc for %@ adMarkup: %@", [delegate getPlacementID], [delegate getAdMarkup]);
            [[VungleSDK sharedSDK] finishDisplayingAd:[delegate getPlacementID] adMarkup:[delegate getAdMarkup]];
            delegate.bannerState = BannerRouterDelegateStateClosing;
            [self.bannerDelegates removeObjectForKey:[self getKeyFromDelegate:delegate]];
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
    __weak VungleRouter *weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself clearBannerDelegateWithState:BannerRouterDelegateStateRequesting];
    });
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

- (NSString *)getKeyFromDelegate:(id<VungleRouterDelegate>)delegate
{
    return [NSString stringWithFormat:@"%@|%@", [delegate getPlacementID], [delegate getAdMarkup]];
}

- (void)setDelegateIntoTable:(NSMapTable *)table
                    delegate:(id<VungleRouterDelegate>)delegate
{
    NSString *key = [self getKeyFromDelegate:delegate];
    // Always set the latest delegate to be tracked
    [table setObject:delegate forKey:key];
}

- (void)clearBannerDelegateWithState:(BannerRouterDelegateState)state
{
    @synchronized (self) {
        NSArray *array = [self.bannerDelegates.keyEnumerator allObjects];
        for (NSString *key in array) {
            if ([[self.bannerDelegates objectForKey:key] bannerState] == state) {
                [self.bannerDelegates removeObjectForKey:key];
            }
        }
    }
}

- (void)cleanupFullScreenDelegate:(id<VungleRouterDelegate>)delegate
{
    @synchronized (self) {
        NSString *key = [self getKeyFromDelegate:delegate];
        [self.delegatesDict removeObjectForKey:key];
    }
}

- (void)removeDelegatesIfContainsPlacement:(NSString *)placementID
                                dictionary:(NSMutableDictionary *)dictionary
{
    @synchronized (self) {
        NSArray *array = [dictionary.keyEnumerator allObjects];
        for (NSString *key in array) {
            if ([key containsString:placementID]) {
                [dictionary removeObjectForKey:key];
            }
        }
    }
}

- (void)removeDelegatesIfContainsPlacement:(NSString *)placementID
                                     table:(NSMapTable *)table
{
    @synchronized (self) {
        NSArray *array = [table.keyEnumerator allObjects];
        for (NSString *key in array) {
            if ([key containsString:placementID]) {
                [table removeObjectForKey:key];
            }
        }
    }
}

- (void)addToWaitingListWithDelegate:(id<VungleRouterDelegate>)delegate
{
    NSString *key = [self getKeyFromDelegate:delegate];
    if (![self.waitingListDict objectForKey:key]) {
        [self.waitingListDict setObject:delegate forKey:key];
    }
}

- (void)clearWaitingList
{
    for (id key in self.waitingListDict) {
        id<VungleRouterDelegate> delegateInstance = [self.waitingListDict objectForKey:key];
        if ([delegateInstance respondsToSelector:@selector(getBannerSize)]) {
            [self requestBannerAdWithDelegate:delegateInstance];
        } else {
            [self requestAdWithCustomEventInfo:nil delegate:delegateInstance];
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
        NSString *errorMessage = [NSString stringWithFormat:@"Vungle: Unable to load an ad for Placement ID :%@.", placementID];
        error = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd
                  localizedDescription:errorMessage];
        MPLogError(@"%@", errorMessage);
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
                                            adMarkup:(NSString *)adMarkup
                                     withBannerState:(BannerRouterDelegateState)state
{
    id<VungleRouterDelegate> targetDelegate = [self getFullScreenDelegateWithPlacement:placementID
                                                                              adMarkup:adMarkup];
    if (!targetDelegate) {
        targetDelegate = [self getBannerDelegateWithPlacement:placementID adMarkup:adMarkup withBannerState:state];
    }
    
    return targetDelegate;
}

- (id<VungleRouterDelegate>)getFullScreenDelegateWithPlacement:(NSString *)placementID
                                                      adMarkup:(NSString *)adMarkup
{
    if (!placementID.length && !adMarkup.length) {
        return nil;
    }
    NSString *identifier = adMarkup ?: placementID;
    for(NSString *key in self.delegatesDict) {
        if ([key containsString:identifier]) {
            return [self.delegatesDict objectForKey:key];
        }
    }
    return nil;
}

- (id<VungleRouterDelegate>)getBannerDelegateWithPlacement:(NSString *)placementID
                                                  adMarkup:(NSString *)adMarkup
{
    if (!placementID.length && !adMarkup.length) {
        return nil;
    }
    NSString *identifier = adMarkup ?: placementID;
    for(NSString *key in self.bannerDelegates) {
        if ([key containsString:identifier]) {
            return [self.bannerDelegates objectForKey:key];
        }
    }
    return nil;
}

- (id<VungleRouterDelegate>)getBannerDelegateWithPlacement:(NSString *)placementID
                                                  adMarkup:(NSString *)adMarkup
                                           withBannerState:(BannerRouterDelegateState)state
{
    id<VungleRouterDelegate> targetDelegate = [self getBannerDelegateWithPlacement:placementID adMarkup:adMarkup];
    if (targetDelegate.bannerState != state) {
        return nil;
    }

    return targetDelegate;
}

- (void)replaceOldBannerDelegateWithDelegate:(id<VungleRouterDelegate>)delegate
{
    @synchronized (self) {
        id<VungleRouterDelegate> bannerDelegate = [self getBannerDelegateWithPlacement:[delegate getPlacementID] adMarkup:[delegate getAdMarkup]];
        if (bannerDelegate != delegate) {
            [self.bannerDelegates setObject:delegate forKey:[self getKeyFromDelegate:delegate]];
        }
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
                      placementID:(nullable NSString *)placementID
                            error:(nullable NSError *)error
{
    if (!placementID.length) {
        return;
    }
    [self vungleAdPlayabilityUpdate:isAdPlayable placementID:placementID adMarkup:nil error:error];
}

- (void)vungleWillShowAdForPlacementID:(nullable NSString *)placementID
{
    if (!placementID.length) {
        return;
    }
    [self vungleWillShowAdForPlacementID:placementID adMarkup:nil];
}

- (void)vungleDidShowAdForPlacementID:(nullable NSString *)placementID
{
    [self vungleDidShowAdForPlacementID:placementID adMarkup:nil];
}

- (void)vungleAdViewedForPlacement:(NSString *)placementID
{
    if (!placementID.length) {
        return;
    }
    [self vungleAdViewedForPlacementID:placementID adMarkup:nil];
}

- (void)vungleWillCloseAdForPlacementID:(nonnull NSString *)placementID
{
    [self vungleWillCloseAdForPlacementID:placementID adMarkup:nil];
}

- (void)vungleDidCloseAdForPlacementID:(nonnull NSString *)placementID
{
    if (!placementID.length) {
        return;
    }
    [self vungleDidCloseAdForPlacementID:placementID adMarkup:nil];
}

- (void)vungleTrackClickForPlacementID:(nullable NSString *)placementID
{
    if (!placementID.length) {
        return;
    }
    [self vungleTrackClickForPlacementID:placementID adMarkup:nil];
}

- (void)vungleRewardUserForPlacementID:(nullable NSString *)placementID
{
    [self vungleRewardUserForPlacementID:placementID adMarkup:nil];
}

- (void)vungleWillLeaveApplicationForPlacementID:(nullable NSString *)placementID
{
    [self vungleWillLeaveApplicationForPlacementID:placementID adMarkup:nil];
}

#pragma mark - VungleSDKHBDelegate Methods

- (void)vungleAdPlayabilityUpdate:(BOOL)isAdPlayable
                      placementID:(NSString *)placementID
                         adMarkup:(NSString *)adMarkup
                            error:(NSError *)error
{
    NSString *message = nil;
    NSError *playabilityError = nil;
    if (isAdPlayable) {
        MPLogInfo(@"Vungle: Ad playability update returned ad is playable for Placement ID: %@", placementID);
    } else {
        message = error ? [NSString stringWithFormat:@"Vungle: Ad playability update returned error for Placement ID: %@, Error: %@", placementID, error.localizedDescription] : [NSString stringWithFormat:@"Vungle: Ad playability update returned Ad is not playable for Placement ID: %@.", placementID];
        playabilityError = error ? : [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd localizedDescription:message];
    }

    id<VungleRouterDelegate> targetDelegate = [self getFullScreenDelegateWithPlacement:placementID
                                                                              adMarkup:adMarkup];
    if (targetDelegate) {
        if (isAdPlayable) {
            [targetDelegate vungleAdDidLoad];
        } else {
            MPLogInfo(@"%@", message);
            // Ignore any playability update if the delegate is the playing ad
            // The SDK will fire playability updates during a successful playback
            // to relay the status. We don't want to trigger the fail load if it
            // is successfully playing. But don't block other placement load fails
            if (!([[self.playingFullScreenAdDelegate getPlacementID] isEqualToString:placementID] &&
                [[self.playingFullScreenAdDelegate getAdMarkup] isEqualToString:adMarkup])) {
                [targetDelegate vungleAdDidFailToLoad:playabilityError];
            }
        }
    } else {
        @synchronized (self) {
            id<VungleRouterDelegate> bannerDelegate =
            [self getBannerDelegateWithPlacement:placementID
                                        adMarkup:adMarkup
                                 withBannerState:BannerRouterDelegateStateRequesting];
            if (bannerDelegate) {
                if (isAdPlayable) {
                    [bannerDelegate vungleAdDidLoad];
                    bannerDelegate.bannerState = BannerRouterDelegateStateCached;
                } else {
                    MPLogInfo(@"%@", message);
                    [bannerDelegate vungleAdDidFailToLoad:playabilityError];
                    bannerDelegate.bannerState = BannerRouterDelegateStateClosed;
                    [self clearBannerDelegateWithState:BannerRouterDelegateStateClosed];
                }
            }
        }
    }
}

- (void)vungleWillShowAdForPlacementID:(NSString *)placementID
                              adMarkup:(NSString *)adMarkup
{
    id<VungleRouterDelegate> targetDelegate = [self getFullScreenDelegateWithPlacement:placementID adMarkup:adMarkup];
    if (!targetDelegate) {
        @synchronized (self) {
            id<VungleRouterDelegate> bannerDelegate =
            [self getBannerDelegateWithPlacement:placementID
                                        adMarkup:adMarkup
                                 withBannerState:BannerRouterDelegateStateCached];
            if (bannerDelegate) {
                bannerDelegate.bannerState = BannerRouterDelegateStatePlaying;
            }
        }
    }

    if ([targetDelegate respondsToSelector:@selector(vungleAdWillAppear)]) {
        [targetDelegate vungleAdWillAppear];
    }
}

- (void)vungleDidShowAdForPlacementID:(NSString *)placementID
                             adMarkup:(NSString *)adMarkup
{
    id<VungleRouterDelegate> targetDelegate = [self getFullScreenDelegateWithPlacement:placementID adMarkup:adMarkup];
    if ([targetDelegate respondsToSelector:@selector(vungleAdDidAppear)]) {
        [targetDelegate vungleAdDidAppear];
    }
}

- (void)vungleAdViewedForPlacementID:(NSString *)placementID
                            adMarkup:(NSString *)adMarkup
{
    id<VungleRouterDelegate> targetDelegate = [self getFullScreenDelegateWithPlacement:placementID adMarkup:adMarkup];
    if (!targetDelegate) {
        @synchronized (self) {
            targetDelegate =
            [self getBannerDelegateWithPlacement:placementID
                                        adMarkup:adMarkup
                                 withBannerState:BannerRouterDelegateStatePlaying];
        }
    }
    [targetDelegate vungleAdViewed];
}

- (void)vungleWillCloseAdForPlacementID:(NSString *)placementID
                               adMarkup:(NSString *)adMarkup
{
    id<VungleRouterDelegate> targetDelegate = [self getFullScreenDelegateWithPlacement:placementID adMarkup:adMarkup];
    if ([targetDelegate respondsToSelector:@selector(vungleAdWillDisappear)]) {
        [targetDelegate vungleAdWillDisappear];
        self.playingFullScreenAdDelegate = nil;
    }
}

- (void)vungleDidCloseAdForPlacementID:(NSString *)placementID
                              adMarkup:(NSString *)adMarkup
{
    id<VungleRouterDelegate> targetDelegate = [self getFullScreenDelegateWithPlacement:placementID adMarkup:adMarkup];
    if (!targetDelegate) {
        @synchronized (self) {
            id<VungleRouterDelegate> bannerDelegate =
            [self getBannerDelegateWithPlacement:placementID
                                         adMarkup:adMarkup
                                 withBannerState:BannerRouterDelegateStateClosing];
            if (bannerDelegate) {
                bannerDelegate.bannerState = BannerRouterDelegateStateClosed;
                [self clearBannerDelegateWithState:BannerRouterDelegateStateClosed];
            }
        }
    }

    if ([targetDelegate respondsToSelector:@selector(vungleAdDidDisappear)]) {
        [targetDelegate vungleAdDidDisappear];
    }
}

- (void)vungleTrackClickForPlacementID:(NSString *)placementID
                              adMarkup:(NSString *)adMarkup
{
    id<VungleRouterDelegate> targetDelegate = [self getDelegateWithPlacement:placementID
                                                                     adMarkup:adMarkup
                                                             withBannerState:BannerRouterDelegateStatePlaying];
    [targetDelegate vungleAdTrackClick];
}

- (void)vungleRewardUserForPlacementID:(NSString *)placementID
                              adMarkup:(NSString *)adMarkup
{
    id<VungleRouterDelegate> targetDelegate = [self getFullScreenDelegateWithPlacement:placementID adMarkup:adMarkup];
    if ([targetDelegate respondsToSelector:@selector(vungleAdRewardUser)]) {
        [targetDelegate vungleAdRewardUser];
    }
}

- (void)vungleWillLeaveApplicationForPlacementID:(NSString *)placementID
                                        adMarkup:(NSString *)adMarkup
{
    id<VungleRouterDelegate> targetDelegate = [self getDelegateWithPlacement:placementID
                                                                     adMarkup:adMarkup
                                                             withBannerState:BannerRouterDelegateStatePlaying];
    [targetDelegate vungleAdWillLeaveApplication];
}

- (void)invalidateObjectsForPlacementID:(nullable NSString *)placementID
{
    if (!placementID.length) {
        return;
    }
    [self removeDelegatesIfContainsPlacement:placementID dictionary:self.waitingListDict];
    [self removeDelegatesIfContainsPlacement:placementID table:self.delegatesDict];
    [self removeDelegatesIfContainsPlacement:placementID table:self.bannerDelegates];
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
