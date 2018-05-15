//
//  MOPUBRVAdapterIronSource.m
//

#import "IronSourceRewardedVideoCustomEvent.h"
#import "IronSourceConstants.h"
#import "MPLogging.h"
#import "MoPub.h"

@interface IronSourceRewardedVideoCustomEvent()

#pragma mark Mopub properties
@property (nonatomic, strong) MPRewardedVideoReward *reward;

#pragma mark Class local properties
@property (nonatomic, assign) NSString *placementName;
@property (nonatomic, strong) NSString *instanceId;
@property (nonatomic, assign) BOOL isTestEnabled;
@end

static BOOL initRewardedVideoSuccessfully = NO;

@implementation IronSourceRewardedVideoCustomEvent

#pragma mark Mopub IronSourceRVCustomEvent Methods

- (void)initializeSdkWithParameters:(NSDictionary *)parameters {
    [self parseCredentials:parameters];
    NSString *appKey = [parameters objectForKey:kIronSourceAppKey];
    [self initializeRewardedVideoIronSourceSDKWithApplicationKey:appKey];
}

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info {
    [self parseCredentials:info];
    
    // Collect and pass the user's consent from MoPub onto the ironSource SDK
    if ([[MoPub sharedInstance] isGDPRApplicable] == MPBoolYes) {
        BOOL canCollectPersonalInfo = [[MoPub sharedInstance] canCollectPersonalInfo];
        [IronSource setConsent:canCollectPersonalInfo];
    }

    [self logInfo:@"Requesting IronSource Rewarded Video ad"];
    NSString *appKey = [info objectForKey:kIronSourceAppKey];
    [self initializeRewardedVideoIronSourceSDKWithApplicationKey:appKey];
    
    if (initRewardedVideoSuccessfully) {
        id<MPRewardedVideoCustomEventDelegate> strongDelegate = self.delegate;
        
        if ([self hasAdAvailable]) {
            [strongDelegate rewardedVideoDidLoadAdForCustomEvent:self];
        } else {
            [self logError:@"IronSource rewarded video ad was not available"];
            NSError *error = [self createErrorWith:@"IronSource adapter failed to request rewarded video"
                                         andReason:@"no more fill"
                                     andSuggestion:@""];
            [strongDelegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
        }
    }
    else {
        // We are waiting for a response from IronSource SDK (see: 'rewardedVideoHasChangedAvailability').
        // Once we retrived a response we notify MOPUB for avialbilty.
        // From then on for every other load we update MOPUB with IronSource rewarded video current availability (see: 'hasAdAvailable').
    }
}

- (BOOL)hasAdAvailable {
    return [IronSource hasISDemandOnlyRewardedVideo:_instanceId];
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController {
    
    if([self hasAdAvailable]) {
        [self logInfo:@"IronSource rewarded video ad will be presented"];
        if ([self isEmpty:_placementName]) {
            [IronSource showISDemandOnlyRewardedVideo:viewController instanceId:_instanceId];
        } else {
            [IronSource showISDemandOnlyRewardedVideo:viewController placement:_placementName instanceId:_instanceId];
        }
    } else {
        id<MPRewardedVideoCustomEventDelegate> strongDelegate = self.delegate;
        [self logError:@"IronSource rewarded video ad was not available"];
        NSError *error = [self createErrorWith:@"IronSource adapter failed to request rewarded video"
                                     andReason:@"no more fill"
                                 andSuggestion:@""];
        [strongDelegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
    }
}

- (void)handleCustomEventInvalidated {
    // do nothing
}

- (void)handleAdPlayedForCustomEventNetwork {
    // do nothing
}

#pragma mark IronSource RV Methods

- (void)initializeRewardedVideoIronSourceSDKWithApplicationKey:(NSString *)applicationKey {
    
    if (![self isEmpty:applicationKey]) {
        [IronSource setISDemandOnlyRewardedVideoDelegate:self];
        
        if (!initRewardedVideoSuccessfully) {
            [self logInfo:@"IronSource SDK initialization complete"];
            [IronSource setMediationType:kIronSourceMediationName];
            [IronSource initISDemandOnly:applicationKey adUnits:@[IS_REWARDED_VIDEO]];
        }
    } else {
        [self logError:@"IronSource Adapter failed to request RewardedVideo, 'applicationKey' parameter is missing. make sure that 'applicationKey' server parameter is added"];
        NSError *error = [self createErrorWith:@"IronSource Adapter failed to request RewardedVideo"
                                     andReason:@"applicationKey parameter is missing"
                                 andSuggestion:@"make sure that 'applicationKey' server parameter is added"];
        
        id<MPRewardedVideoCustomEventDelegate> strongDelegate = self.delegate;
        [strongDelegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
    }
}

#pragma mark Utiles Methods
- (void)parseCredentials:(NSDictionary *)parameters {
    
    if ([parameters objectForKey:kIronSourcePlacementName] != nil){
        _placementName = [parameters objectForKey:kIronSourcePlacementName];
    }
    
    _instanceId = @"0";
   if (![[parameters objectForKey:kIronSourceInstanceId] isEqualToString:@""] && [parameters objectForKey:kIronSourceInstanceId] != nil )
    {
        _instanceId = [parameters objectForKey:kIronSourceInstanceId];
    }
    
    if ([parameters objectForKey:kIronSourceIsTestEnabled] != nil){
        _isTestEnabled = [[parameters objectForKey:kIronSourceIsTestEnabled] boolValue];
    }
}

- (void)logInfo:(NSString *)log {
    if (_isTestEnabled) {
        MPLogInfo(log);
    }
}

- (void)logError:(NSString *)log {
    if (_isTestEnabled) {
        MPLogError(log);
    }
}

- (BOOL)isEmpty:(id)value {
    return value == nil
    || [value isKindOfClass:[NSNull class]]
    || ([value respondsToSelector:@selector(length)] && [(NSString *)value length] == 0)
    || ([value respondsToSelector:@selector(length)] && [(NSData *)value length] == 0)
    || ([value respondsToSelector:@selector(count)] && [(NSArray *)value count] == 0);
}

- (NSError *)createErrorWith:(NSString *)description andReason:(NSString *)reaason andSuggestion:(NSString *)suggestion {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(description, nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(reaason, nil),
                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(suggestion, nil)
                               };
    
    return [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:userInfo];
}

#pragma mark IronSource RV Events

/*!
 * @discussion Invoked when there is a change in the ad availability status.
 *
 *              hasAvailableAds - value will change to YES when rewarded videos are available.
 *              You can then show the video. Value will change to NO when no videos are available.
 */
- (void)rewardedVideoHasChangedAvailability:(BOOL)available instanceId:(NSString *)instanceId {
    [self logInfo: [NSString stringWithFormat:@"RewardedVideo has changed availability - %@, for instance: %@ " , available ? @"YES" : @"NO", instanceId]];
    
    if(![_instanceId isEqualToString:instanceId])
        return;
    
    id<MPRewardedVideoCustomEventDelegate> strongDelegate = self.delegate;
    
    // Invoke only for first load, ignore for all others and rely on 'hasAdAvailable'
    if (!initRewardedVideoSuccessfully) {
        if (available) {
            [strongDelegate rewardedVideoDidLoadAdForCustomEvent:self];
        } else  {
            [strongDelegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:nil];
        }
        initRewardedVideoSuccessfully = YES;
    }
}

/*!
 * @discussion Invoked when the user completed the video and should be rewarded.
 *
 *              If using server-to-server callbacks you may ignore these events and wait for the callback from the IronSource server.
 *              placementInfo - IronSourcePlacementInfo - an object contains the placement's reward name and amount
 */
- (void)didReceiveRewardForPlacement:(ISPlacementInfo *)placementInfo instanceId:(NSString *)instanceId {
    
    if (placementInfo) {
        NSString *rewardName = [placementInfo rewardName];
        NSNumber *rewardAmount = [placementInfo rewardAmount];
        id<MPRewardedVideoCustomEventDelegate> strongDelegate = self.delegate;
        _reward = [[MPRewardedVideoReward alloc] initWithCurrencyType:rewardName amount:rewardAmount];
        [strongDelegate rewardedVideoShouldRewardUserForCustomEvent:self reward:_reward];
        [self logInfo:[NSString stringWithFormat:@"IronSource received reward for placement %@ ,for instance:%@",rewardName ,instanceId]];
    } else {
        [self logError:@"IronSource received reward for placement - without placement info"];
    }
}

/*!
 * @discussion Invoked when an Ad failed to display.
 *
 *          error - NSError which contains the reason for the failure.
 *          The error contains error.code and error.message.
 */
- (void)rewardedVideoDidFailToShowWithError:(NSError *)error instanceId:(NSString *)instanceId {
    [self logError:[NSString stringWithFormat:@"IronSource rewardedVideo did fail to show with error: %@", error.description]];
    id<MPRewardedVideoCustomEventDelegate> strongDelegate = self.delegate;
    [strongDelegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
}

/*!
 * @discussion Invoked when the RewardedVideo ad view has opened.
 *
 */
- (void)rewardedVideoDidOpen:(NSString *)instanceId {
    [self logInfo:[NSString stringWithFormat:@"IronSource RewardedVideo did open for instance:%@",instanceId]];
    
    id<MPRewardedVideoCustomEventDelegate> strongDelegate = self.delegate;
    [strongDelegate rewardedVideoWillAppearForCustomEvent:self];
    [strongDelegate rewardedVideoDidAppearForCustomEvent:self];
}

/*!
 * @discussion Invoked when the video ad starts playing.
 */
- (void)rewardedVideoDidStart:(NSString *)instanceId {
    [self logInfo:[NSString stringWithFormat:@"IronSource RewardedVideo did start for instance:%@",instanceId]];
}

/*!
 * @discussion Invoked when the user is about to return to the application after closing the RewardedVideo ad.
 *
 */
- (void)rewardedVideoDidClose:(NSString *)instanceId {
    [self logInfo:[NSString stringWithFormat:@"IronSource RewardedVideo did close for instance:%@",instanceId]];
    
    id<MPRewardedVideoCustomEventDelegate> strongDelegate = self.delegate;
    [strongDelegate rewardedVideoWillDisappearForCustomEvent:self];
    [strongDelegate rewardedVideoDidDisappearForCustomEvent:self];
    
    self.reward = nil;
}

/*!
 * @discussion Invoked when the video ad finishes playing.
 */
- (void)rewardedVideoDidEnd:(NSString *)instanceId {
    [self logInfo:[NSString stringWithFormat:@"IronSource RewardedVideo did end for instance:%@",instanceId]];
}

/*!
 * @discussion Invoked when a video has been clicked.
 */
- (void)didClickRewardedVideo:(ISPlacementInfo *)placementInfo instanceId:(NSString *)instanceId {
    [self logInfo:[NSString stringWithFormat:@"Did click IronSource RewardedVideo for instance:%@",instanceId]];
    
    id<MPRewardedVideoCustomEventDelegate> strongDelegate = self.delegate;
    [strongDelegate rewardedVideoDidReceiveTapEventForCustomEvent:self];
}

@end



