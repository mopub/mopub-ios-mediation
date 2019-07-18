//
//  UnityRouter.m
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#import "UnityRouter.h"
#import "UnityAdsInstanceMediationSettings.h"
#import "UnityAdsAdapterConfiguration.h"

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
    #import <MoPubSDKFramework/MoPub.h>
#else
    #import "MoPub.h"
    #import "MPRewardedVideoError.h"
    #import "MPRewardedVideo.h"
#endif

@interface UnityRouter ()

@property (nonatomic, assign) BOOL isAdPlaying;
@property (nonatomic, weak) id<UnityRouterDelegate> delegate;

@property NSMutableDictionary* delegateMap;
@property id<UnityAdsBannerDelegate> bannerDelegate;

@property BOOL bannerLoadRequested;
@property NSString* bannerPlacementId;

@property (nonatomic, assign) int impressionOrdinal;
@property (nonatomic, assign) int missedImpressionOrdinal;

@end

@implementation UnityRouter

- (id) init {
    self = [super init];
    self.delegateMap = [[NSMutableDictionary alloc] init];

    return self;
}

+ (UnityRouter *)sharedRouter
{
    static UnityRouter * sharedRouter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedRouter = [[UnityRouter alloc] init];
    });
    return sharedRouter;
}

- (void)initializeWithGameId:(NSString *)gameId
{
    static dispatch_once_t unityInitToken;
    dispatch_once(&unityInitToken, ^{
        UADSMediationMetaData *mediationMetaData = [[UADSMediationMetaData alloc] init];
        [mediationMetaData setName:@"MoPub"];
        [mediationMetaData setVersion:[[MoPub sharedInstance] version]];
        [mediationMetaData set:@"adapter_version"  value:ADAPTER_VERSION];
        [mediationMetaData commit];
        
        [UnityAdsBanner setDelegate:self];
        [UnityAds initialize:gameId delegate:self testMode:false enablePerPlacementLoad:true];
    });
    [self setIfUnityAdsCollectsPersonalInfo];
}

- (void) setIfUnityAdsCollectsPersonalInfo
{
    // Collect and pass the user's consent/non-consent from MoPub to the Unity Ads SDK
    UADSMetaData *gdprConsentMetaData = [[UADSMetaData alloc] init];
    
    if ([[MoPub sharedInstance] isGDPRApplicable] == MPBoolYes){
        if ([[MoPub sharedInstance] allowLegitimateInterest] == YES){
            if ([[MoPub sharedInstance] currentConsentStatus] == MPConsentStatusDenied
                || [[MoPub sharedInstance] currentConsentStatus] == MPConsentStatusDoNotTrack) {
                
                [gdprConsentMetaData set:@"gdpr.consent" value:@NO];
            }
            else {
                [gdprConsentMetaData set:@"gdpr.consent" value:@YES];
            }
        } else {
            if ([[MoPub sharedInstance] canCollectPersonalInfo] == YES) {
                [gdprConsentMetaData set:@"gdpr.consent" value:@YES];
            }
            else {
                [gdprConsentMetaData set:@"gdpr.consent" value:@NO];
            }
        }
        [gdprConsentMetaData commit];
    }
}

- (void)requestVideoAdWithGameId:(NSString *)gameId placementId:(NSString *)placementId delegate:(id<UnityRouterDelegate>)delegate;
{
    //Call load first, to minimize reporting discrepencies
    [UnityAds load:placementId];
    
    if([UnityAds getPlacementState:placementId] == kUnityAdsPlacementStateNoFill){
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:nil];
        [delegate unityAdsDidFailWithError:error];
        return;
    }
    
    if (!self.isAdPlaying) {
        [self.delegateMap setObject:delegate forKey:placementId];
        
        if (![UnityAds isInitialized]) {
            [self initializeWithGameId:gameId];
        }

        // Need to check immediately as an ad may be cached.
        if ([UnityAds isReady:placementId]) {
            [self unityAdsReady:placementId];
        }
        // MoPub timeout will handle the case for an ad failing to load.
    } else {
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorUnknown userInfo:nil];
        [delegate unityAdsDidFailWithError:error];
    }
}

-(void)requestBannerAdWithGameId:(NSString *)gameId placementId:(NSString *)placementId delegate:(id <UnityAdsBannerDelegate>)delegate {
    [self initializeWithGameId:gameId];
    self.bannerDelegate = delegate;

    if ([UnityAds isReady:placementId]) {
        [UnityAdsBanner loadBanner:placementId];
    } else {
        self.bannerLoadRequested = YES;
        self.bannerPlacementId = placementId;
    }
}

- (BOOL)isAdAvailableForPlacementId:(NSString *)placementId
{
    return [UnityAds isReady:placementId];
}

- (void)presentVideoAdFromViewController:(UIViewController *)viewController customerId:(NSString *)customerId placementId:(NSString *)placementId settings:(UnityAdsInstanceMediationSettings *)settings delegate:(id<UnityRouterDelegate>)delegate
{
    if (!self.isAdPlaying && [self isAdAvailableForPlacementId:placementId]) {
        self.isAdPlaying = YES;
        self.currentPlacementId = placementId;
        
        UADSMediationMetaData* mediationMetaData = [[UADSMediationMetaData alloc] init];
        self.impressionOrdinal++;
        [mediationMetaData setOrdinal:self.impressionOrdinal];
        [mediationMetaData commit];
        [UnityAds show:viewController placementId:placementId];
    } else {
        UADSMediationMetaData* mediationMetaData = [[UADSMediationMetaData alloc] init];
        self.missedImpressionOrdinal++;
        [mediationMetaData setMissedImpressionOrdinal:self.missedImpressionOrdinal];
        [mediationMetaData commit];
        
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorUnknown userInfo:nil];
        [delegate unityAdsDidFailWithError:error];
    }
}

- (id<UnityRouterDelegate>)getDelegate:(NSString*) placementId {
    return [self.delegateMap valueForKey:placementId];
}

- (void)clearDelegate:(id<UnityRouterDelegate>)delegate
{
    if (self.delegate == delegate)
    {
        [self setDelegate:nil];
    }
}

-(void)clearBannerDelegate {
    self.bannerDelegate = nil;
    self.bannerPlacementId = nil;
    self.bannerLoadRequested = NO;
}

#pragma mark - UnityAdsExtendedDelegate

- (void)unityAdsReady:(NSString *)placementId
{
    if ([placementId isEqualToString:self.bannerPlacementId] && self.bannerLoadRequested) {
        self.bannerLoadRequested = NO;
        [UnityAdsBanner loadBanner:self.bannerPlacementId];
    } else if (!self.isAdPlaying) {
        id delegate = [self getDelegate:placementId];
        if (delegate != nil) {
            [delegate unityAdsReady:placementId];
        }
    }
}

- (void)unityAdsDidError:(UnityAdsError)error withMessage:(NSString *)message {
    id delegate = [self getDelegate:self.currentPlacementId];
    if (delegate != nil) {
        [delegate unityAdsDidError:error withMessage:message];
    }
}

- (void)unityAdsDidStart:(NSString *)placementId {
    id delegate = [self getDelegate:placementId];
    if (delegate != nil) {
        [delegate unityAdsDidStart:placementId];
    }
}

- (void)unityAdsDidFinish:(NSString *)placementId withFinishState:(UnityAdsFinishState)state {
    id delegate = [self getDelegate:placementId];
    if (delegate != nil) {
        [delegate unityAdsDidFinish:placementId withFinishState:state];
    }
    [self.delegateMap removeObjectForKey:placementId];
    self.isAdPlaying = NO;
}

- (void)unityAdsDidClick:(NSString *)placementId {
    id delegate = [self getDelegate:placementId];
    if (delegate != nil) {
        [delegate unityAdsDidClick:placementId];
    }
}

- (void)unityAdsPlacementStateChanged:(NSString *)placementId oldState:(UnityAdsPlacementState)oldState newState:(UnityAdsPlacementState)newState {
    id delegate = [self getDelegate:placementId];
    if (delegate != nil && [delegate respondsToSelector:@selector(unityAdsPlacementStateChanged:oldState:newState:)]) {
        [delegate unityAdsPlacementStateChanged:placementId oldState:oldState newState:newState];
    }
    
    if (delegate != nil && newState == kUnityAdsPlacementStateNoFill){
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorUnknown userInfo:nil];
        [delegate unityAdsDidFailWithError:error];
    }
}

#pragma mark - UnityAdsBannerDelegate

-(void)unityAdsBannerDidLoad:(NSString *)placementId view:(UIView *)view {
    [self.bannerDelegate unityAdsBannerDidLoad:placementId view:view];
}

-(void)unityAdsBannerDidUnload:(NSString *)placementId {
    [self.bannerDelegate unityAdsBannerDidUnload:placementId];
}
-(void)unityAdsBannerDidShow:(NSString *)placementId {
    [self.bannerDelegate unityAdsBannerDidShow:placementId];
}
-(void)unityAdsBannerDidHide:(NSString *)placementId {
    [self.bannerDelegate unityAdsBannerDidHide:placementId];
}
-(void)unityAdsBannerDidClick:(NSString *)placementId {
    [self.bannerDelegate unityAdsBannerDidClick:placementId];
}
-(void)unityAdsBannerDidError:(NSString *)message {
    [self.bannerDelegate unityAdsBannerDidError:message];
}

@end
