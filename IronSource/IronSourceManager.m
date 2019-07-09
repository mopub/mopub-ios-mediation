//
//  IronSourceManager.h
//

#import "IronSourceManager.h"
#if __has_include("MoPub.h")
    #import "MPLogging.h"
    #import "MoPub.h"
#endif

@interface IronSourceManager ()

@property(nonatomic)
NSMapTable<NSString *, id<IronSourceRewardedVideoDelegate>>
*rewardedAdapterDelegates;

@property(nonatomic)
NSMapTable<NSString *, id<IronSourceInterstitialDelegate>>
*interstitialAdapterDelegates;

@end

@implementation IronSourceManager

+ (instancetype)sharedManager {
    static IronSourceManager *sharedManager = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.rewardedAdapterDelegates =
        [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory
                              valueOptions:NSPointerFunctionsWeakMemory];
        self.interstitialAdapterDelegates =
        [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory
                              valueOptions:NSPointerFunctionsWeakMemory];
        [IronSource setMediationType:[NSString stringWithFormat:@"%@%@SDK%@",
                                      kIronSourceMediationName,kIronSourceMediationVersion, [IronSourceUtils getMoPubSdkVersion]]];
    }
    return self;
}

- (void)initIronSourceSDKWithAppKey:(NSString *)appKey forAdUnits:(NSSet *)adUnits {
    if([adUnits member:@[IS_INTERSTITIAL]] != nil){
        static dispatch_once_t onceTokenIS;

        dispatch_once(&onceTokenIS, ^{
            [IronSource setISDemandOnlyInterstitialDelegate:self];
            [IronSource initISDemandOnly:appKey adUnits:@[IS_INTERSTITIAL]];
        });
    }
    if([adUnits member:@[IS_REWARDED_VIDEO]] != nil){
        static dispatch_once_t onceTokenRV;

        dispatch_once(&onceTokenRV, ^{
            [IronSource setISDemandOnlyRewardedVideoDelegate:self];
            [IronSource initISDemandOnly:appKey adUnits:@[IS_REWARDED_VIDEO]];
        });
    }
}

- (void)loadRewardedAdWithDelegate:
(id<IronSourceRewardedVideoDelegate>)delegate instanceID:(NSString *)instanceID {
    id<IronSourceRewardedVideoDelegate> adapterDelegate = delegate;
    
    if (adapterDelegate == nil) {
        MPLogDebug(@"loadRewardedAdWithDelegate adapterDelegate is null");
        return;
    }
        [self addRewardedDelegate:adapterDelegate forInstanceID:instanceID];
        MPLogDebug(@"IronSourceManager - load Rewarded Video called for instance Id %@", instanceID);
        [IronSource loadISDemandOnlyRewardedVideo:instanceID];
    }

- (void)presentRewardedAdFromViewController:(nonnull UIViewController *)viewController
                                 instanceID:(NSString *)instanceID {
    MPLogDebug(@"IronSourceManager - show Rewarded Video called for instance Id %@", instanceID);
    [IronSource showISDemandOnlyRewardedVideo:viewController instanceId:instanceID];
}

- (void)requestInterstitialAdWithDelegate:
(id<IronSourceInterstitialDelegate>)delegate
                               instanceID:(NSString *)instanceID{
    id<IronSourceInterstitialDelegate> adapterDelegate = delegate;
    
    if (adapterDelegate == nil) {
        MPLogDebug(@"IronSourceManager - requestInterstitialAdWithDelegate adapterDelegate is null");
        return;
    }
    
    [self addInterstitialDelegate:adapterDelegate forInstanceID:instanceID];
    MPLogDebug(@"IronSourceManager - load Interstitial called for instance Id %@", instanceID);
    [IronSource loadISDemandOnlyInterstitial:instanceID];
}

- (void)presentInterstitialAdFromViewController:(nonnull UIViewController *)viewController
                                     instanceID: (NSString *) instanceID {
        [IronSource showISDemandOnlyInterstitial:viewController instanceId:instanceID];
}

#pragma mark ISDemandOnlyRewardedDelegate

- (void)rewardedVideoAdRewarded:(NSString *)instanceId {
    MPLogDebug(@"IronSourceManager rewarded user for instanceId %@", instanceId);

    id<IronSourceRewardedVideoDelegate> delegate =
    [self getRewardedDelegateForInstanceID:instanceId];

    if (delegate) {
        [delegate rewardedVideoAdRewarded:instanceId];
    } else {
        MPLogDebug(@"IronSourceManager - rewardedVideoAdRewarded adapterDelegate is null");
    }
}

- (void)rewardedVideoDidFailToShowWithError:(NSError *)error instanceId:(NSString *)instanceId {
    MPLogDebug(@"IronSourceManager got rewardedVideoDidFailToShowWithError for instanceId %@ with error: %@", instanceId, error);
    id<IronSourceRewardedVideoDelegate> delegate =
    [self getRewardedDelegateForInstanceID:instanceId];

    if (delegate) {
        [delegate rewardedVideoDidFailToShowWithError:error instanceId:instanceId];
        [self removeRewardedDelegateForInstanceID:instanceId];
    } else {
        MPLogDebug(@"IronSourceManager - rewardedVideoDidFailToShowWithError adapterDelegate is null");
    }
}

- (void)rewardedVideoDidOpen:(NSString *)instanceId {
    MPLogDebug(@"IronSourceManager got rewardedVideoDidOpen for instanceId %@", instanceId);
    id<IronSourceRewardedVideoDelegate> delegate =
    [self getRewardedDelegateForInstanceID:instanceId];

    if (delegate) {
        [delegate rewardedVideoDidOpen:instanceId];
    } else {
        MPLogDebug(@"IronSourceManager - rewardedVideoDidOpen adapterDelegate is null");
    }
}

- (void)rewardedVideoDidClose:(NSString *)instanceId {
    MPLogDebug(@"IronSourceManager got rewardedVideoDidClose for instanceId %@", instanceId);
    id<IronSourceRewardedVideoDelegate> delegate =
    [self getRewardedDelegateForInstanceID:instanceId];

    if (delegate) {
        [delegate rewardedVideoDidClose:instanceId];
        [self removeRewardedDelegateForInstanceID:instanceId];
    } else {
        MPLogDebug(@"IronSourceManager - rewardedVideoDidClose adapterDelegate is null");
    }
}

- (void)rewardedVideoDidClick:(NSString *)instanceId {
    MPLogDebug(@"IronSourceManager got rewardedVideoDidClick for instanceId %@", instanceId);
    id<IronSourceRewardedVideoDelegate> delegate =
    [self getRewardedDelegateForInstanceID:instanceId];

    if (delegate) {
        [delegate rewardedVideoDidClick:instanceId];
    } else {
        MPLogDebug(@"IronSourceManager - rewardedVideoDidClick adapterDelegate is null");
    }
}

- (void)rewardedVideoDidLoad:(NSString *)instanceId{
    MPLogDebug(@"IronSourceManager got rewardedVideoDidLoad for instanceId %@", instanceId);
    id<IronSourceRewardedVideoDelegate> delegate = [self getRewardedDelegateForInstanceID:instanceId];
    if(delegate){
        [delegate rewardedVideoDidLoad:instanceId];
    } else {
        MPLogDebug(@"IronSourceManager - rewardedVideoDidLoad adapterDelegate is null");
    }
}

- (void)rewardedVideoDidFailToLoadWithError:(NSError *)error instanceId:(NSString *)instanceId{
    MPLogDebug(@"IronSourceManager got rewardedVideoDidFailToLoadWithError for instanceId %@ with error: %@", instanceId, error);
    id<IronSourceRewardedVideoDelegate> delegate = [self getRewardedDelegateForInstanceID:instanceId];
    if(delegate){
        [delegate rewardedVideoDidFailToLoadWithError:error instanceId:instanceId];
        [self removeRewardedDelegateForInstanceID:instanceId];
    } else {
        MPLogDebug(@"IronSourceManager - rewardedVideoDidFailToLoadWithError adapterDelegate is null");
    }
}

#pragma mark ISDemandOnlyInterstitialDelegate

- (void)interstitialDidLoad:(NSString *)instanceId {
    MPLogDebug(@"IronSourceManager got interstitialDidLoad for instanceId %@", instanceId);
    id<IronSourceInterstitialDelegate> delegate =
    [self getInterstitialDelegateForInstanceID:instanceId];
    if (delegate) {
        [delegate interstitialDidLoad:instanceId];
    } else {
        MPLogDebug(@"IronSourceManager - didClickInterstitial adapterDelegate is null");
    }
}

- (void)interstitialDidFailToLoadWithError:(NSError *)error instanceId:(NSString *)instanceId {
    MPLogDebug(@"IronSourceManager got interstitialDidFailToLoadWithError for instanceId %@ with error: %@", instanceId, error);
    id<IronSourceInterstitialDelegate> delegate =
    [self getInterstitialDelegateForInstanceID:instanceId];
    if (delegate) {
        [delegate interstitialDidFailToLoadWithError:error instanceId:instanceId];
        [self removeInterstitialDelegateForInstanceID:instanceId];
    } else {
        MPLogDebug(@"IronSourceManager - interstitialDidFailToLoadWithError adapterDelegate is null");
    }
}

- (void)interstitialDidOpen:(NSString *)instanceId {
    MPLogDebug(@"IronSourceManager got interstitialDidOpen for instanceId %@", instanceId);
    id<IronSourceInterstitialDelegate> delegate =
    [self getInterstitialDelegateForInstanceID:instanceId];
    if (delegate) {
        [delegate interstitialDidOpen:instanceId];
    } else {
        MPLogDebug(@"IronSourceManager - interstitialDidOpen adapterDelegate is null");
    }
}

- (void)interstitialDidClose:(NSString *)instanceId {
    MPLogDebug(@"IronSourceManager got interstitialDidClose for instanceId %@", instanceId);
    id<IronSourceInterstitialDelegate> delegate =
    [self getInterstitialDelegateForInstanceID:instanceId];
    if (delegate) {
        [delegate interstitialDidClose:instanceId];
        [self removeInterstitialDelegateForInstanceID:instanceId];
    } else {
        MPLogDebug(@"IronSourceManager - interstitialDidClose adapterDelegate is null");
    }
}

- (void)interstitialDidFailToShowWithError:(NSError *)error instanceId:(NSString *)instanceId {
    MPLogDebug(@"IronSourceManager got didClickInterstitial for instanceId %@ with error: %@", instanceId, error);
    id<IronSourceInterstitialDelegate> delegate =
    [self getInterstitialDelegateForInstanceID:instanceId];
    if (delegate) {
        [delegate interstitialDidFailToShowWithError:error instanceId:instanceId];
        [self removeInterstitialDelegateForInstanceID:instanceId];
    } else {
        MPLogDebug(@"IronSourceManager - interstitialDidFailToShowWithError adapterDelegate is null");
    }
}

- (void)didClickInterstitial:(NSString *)instanceId {
    MPLogDebug(@"IronSourceManager got didClickInterstitial for instanceId %@", instanceId);
    id<IronSourceInterstitialDelegate> delegate =
    [self getInterstitialDelegateForInstanceID:instanceId];
    if (delegate) {
        [delegate didClickInterstitial:instanceId];
    } else {
        MPLogDebug(@"IronSourceManager - didClickInterstitial adapterDelegate is null");
    }
}

#pragma Map Utils methods

- (void)addRewardedDelegate:
(id<IronSourceRewardedVideoDelegate>)adapterDelegate
              forInstanceID:(NSString *)instanceID {
    @synchronized(self.rewardedAdapterDelegates) {
        [self.rewardedAdapterDelegates setObject:adapterDelegate forKey:instanceID];
    }
}

- (id<IronSourceRewardedVideoDelegate>)
getRewardedDelegateForInstanceID:(NSString *)instanceID {
    id<IronSourceRewardedVideoDelegate> delegate;
    @synchronized(self.rewardedAdapterDelegates) {
        delegate = [self.rewardedAdapterDelegates objectForKey:instanceID];
    }
    return delegate;
}

- (void)removeRewardedDelegateForInstanceID:(NSString *)InstanceID {
    @synchronized(self.rewardedAdapterDelegates) {
        [self.rewardedAdapterDelegates removeObjectForKey:InstanceID];
    }
}

- (void)addInterstitialDelegate:
(id<IronSourceInterstitialDelegate>)adapterDelegate
                  forInstanceID:(NSString *)instanceID {
    @synchronized(self.interstitialAdapterDelegates) {
        [self.interstitialAdapterDelegates setObject:adapterDelegate forKey:instanceID];
    }
}

- (id<IronSourceInterstitialDelegate>)
getInterstitialDelegateForInstanceID:(NSString *)instanceID {
    id<IronSourceInterstitialDelegate> delegate;
    @synchronized(self.interstitialAdapterDelegates) {
        delegate = [self.interstitialAdapterDelegates objectForKey:instanceID];
    }
    return delegate;
}

- (void)removeInterstitialDelegateForInstanceID:(NSString *)InstanceID {
    @synchronized(self.interstitialAdapterDelegates) {
        [self.interstitialAdapterDelegates removeObjectForKey:InstanceID];
    }
}

@end
