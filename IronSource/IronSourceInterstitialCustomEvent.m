//
//  IronSourceInterstitialCustomEvent.m
//

#import "IronSourceInterstitialCustomEvent.h"
#if __has_include("MoPub.h")
    #import "MPLogging.h"
    #import "MoPub.h"
#endif
#import "IronSourceConstants.h"

@interface IronSourceInterstitialCustomEvent()
@property (nonatomic, copy) NSString *placementName;
@property (nonatomic, copy) NSString *instanceId;
@property (nonatomic, assign) BOOL isTestEnabled;

@end

@implementation IronSourceInterstitialCustomEvent

static BOOL initInterstitialSuccessfully;

#pragma mark Mopub API

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info {
    
    // Collect and pass the user's consent from MoPub onto the ironSource SDK
    if ([[MoPub sharedInstance] isGDPRApplicable] == MPBoolYes) {
        BOOL canCollectPersonalInfo = [[MoPub sharedInstance] canCollectPersonalInfo];
        [IronSource setConsent:canCollectPersonalInfo];
    }

    NSString *applicationKey = @"";
    self.instanceId = @"0";
    
    if ([info objectForKey:kIronSourceAppKey] != nil){
        applicationKey = [info objectForKey:kIronSourceAppKey];
    }
    
    if ([info objectForKey:kIronSourceIsTestEnabled] != nil){
        self.isTestEnabled = [[info objectForKey:kIronSourceIsTestEnabled] boolValue];
    }
    
    if (![[info objectForKey:kIronSourceInstanceId] isEqualToString:@""] &&
        [info objectForKey:kIronSourceInstanceId] != nil ){
        self.instanceId = [info objectForKey:kIronSourceInstanceId];
    }
    
    if ([info objectForKey:kIronSourcePlacementName] != nil){
        self.placementName = [info objectForKey:kIronSourcePlacementName];
    } else {
        self.placementName = nil;
    }
    
    if (![self isEmpty:applicationKey]) {
        [IronSource setISDemandOnlyInterstitialDelegate:self];
        [self initInterstitialIronSourceSDKWithAppKey:applicationKey];
        if (initInterstitialSuccessfully) {
            [self loadInterstitial];
        }
    } else {
        NSError *error = [self createErrorWith:@"IronSource adapter failed to requestInterstitial"
                                     andReason:@"ApplicationKey parameter is missing"
                                 andSuggestion:@"Make sure that 'applicationKey' server parameter is added"];
        
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.instanceId);
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    }
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController {
    
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.instanceId);
    if (self.placementName != nil) {
        [IronSource showISDemandOnlyInterstitial:rootViewController placement:self.placementName instanceId:self.instanceId];
    } else {
        [IronSource showISDemandOnlyInterstitial:rootViewController instanceId:self.instanceId];
    }
}

#pragma mark IronSource IS Methods

- (void)initInterstitialIronSourceSDKWithAppKey:(NSString *)appKey {
    
    if (!initInterstitialSuccessfully) {
        MPLogInfo(@"IronSource SDK initialization complete");
        
        [IronSource setMediationType:[NSString stringWithFormat:@"%@%@",kIronSourceMediationName,kIronSourceMediationVersion]];
        [IronSource initISDemandOnly:appKey adUnits:@[IS_INTERSTITIAL]];
        
        initInterstitialSuccessfully = YES;
    }
}

- (void)loadInterstitial {
    MPLogInfo(@"Load IronSource interstitial ad for instance %@",self.instanceId);
    [IronSource loadISDemandOnlyInterstitial:self.instanceId];
}


- (NSError *)createErrorWith:(NSString *)description andReason:(NSString *)reaason andSuggestion:(NSString *)suggestion {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(description, nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(reaason, nil),
                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(suggestion, nil)
                               };
    
    return [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:userInfo];
}

- (BOOL)isEmpty:(id)value {
    return value == nil
    || [value isKindOfClass:[NSNull class]]
    || ([value respondsToSelector:@selector(length)] && [(NSString *)value length] == 0)
    || ([value respondsToSelector:@selector(length)] && [(NSData *)value length] == 0)
    || ([value respondsToSelector:@selector(count)] && [(NSArray *)value count] == 0);
}

#pragma mark IronSource DemandOnly Delegates implementation

/*!
 * @discussion Called each time an ad is available
 */
- (void)interstitialDidLoad:(NSString *)instanceId {
    
    if(![self.instanceId isEqualToString:instanceId])
        return;
    
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], self.instanceId);
    [self.delegate interstitialCustomEvent:self didLoadAd:nil];
}

/*!
 * @discussion Called each time an ad is not available
 */
- (void)interstitialDidFailToLoadWithError:(NSError *)error instanceId:(NSString *)instanceId {
    MPLogInfo(@"IronSource interstitial ad did fail to load with error: %@, instanceId: %@", error.localizedDescription, instanceId);
    
    // Ignore callback
    if(![self.instanceId isEqualToString:instanceId])
        return;
    
    if (!error) {
        error = [self createErrorWith:@"Netowrk load error"
                            andReason:@"IronSource network failed to load"
                        andSuggestion:@"Check that your network configuration are according to the documentation."];
    }

    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.instanceId);
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

/*!
 * @discussion Called each time the Interstitial window is about to open
 */
- (void)interstitialDidOpen:(NSString *)instanceId {
    
    // Ignore callback
    if(![self.instanceId isEqualToString:instanceId])
        return;
    
    [self.delegate interstitialCustomEventWillAppear:self];
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], self.instanceId);
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], self.instanceId);
}

/*!
 * @discussion Called each time the Interstitial window is about to close
 */
- (void)interstitialDidClose:(NSString *)instanceId {
    MPLogInfo(@"IronSource interstitial ad did close for instance %@", instanceId);
    
    id<MPInterstitialCustomEventDelegate> strongDelegate = self.delegate;
    [strongDelegate interstitialCustomEventWillDisappear:self];
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], self.instanceId);
    [strongDelegate interstitialCustomEventDidDisappear:self];
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], self.instanceId);
}

/*!
 * @discussion Called each time the Interstitial window has opened successfully.
 */
- (void)interstitialDidShow:(NSString *)instanceId {
    MPLogInfo(@"IronSource interstitial ad did show for instance %@", instanceId);
    
    [self.delegate interstitialCustomEventDidAppear:self];
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], self.instanceId);
}

/*!
 * @discussion Called if showing the Interstitial for the user has failed.
 *
 *              You can learn about the reason by examining the ‘error’ value
 */
- (void)interstitialDidFailToShowWithError:(NSError *)error instanceId:(NSString *)instanceId {
    MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], self.instanceId);
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];

}

/*!
 * @discussion Called each time the end user has clicked on the Interstitial ad.
 */
- (void)didClickInterstitial:(NSString *)instanceId {
    
    id<MPInterstitialCustomEventDelegate> strongDelegate = self.delegate;
    [strongDelegate interstitialCustomEventDidReceiveTapEvent:self];
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], self.instanceId);
    [strongDelegate interstitialCustomEventWillLeaveApplication:self];
}

@end

