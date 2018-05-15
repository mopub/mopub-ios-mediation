//
//  MOPUBISAdapterIronSource.m
//

#import "IronSourceInterstitialCustomEvent.h"
#import "MPLogging.h"
#import "IronSourceConstants.h"
#import "MoPub.h"

@interface IronSourceInterstitialCustomEvent()
@property (nonatomic, strong) NSString *placementName;
@property (nonatomic, strong) NSString *instanceId;
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
    _instanceId = @"0";
    
    if ([info objectForKey:kIronSourceAppKey] != nil){
        applicationKey = [info objectForKey:kIronSourceAppKey];
    }
    
    if ([info objectForKey:kIronSourceIsTestEnabled] != nil){
        _isTestEnabled = [[info objectForKey:kIronSourceIsTestEnabled] boolValue];
    }
    
    if (![[info objectForKey:kIronSourceInstanceId] isEqualToString:@""] &&
        [info objectForKey:kIronSourceInstanceId] != nil ){
        _instanceId = [info objectForKey:kIronSourceInstanceId];
    }
    
    if ([info objectForKey:kIronSourcePlacementName] != nil){
        _placementName = [info objectForKey:kIronSourcePlacementName];
    } else {
        _placementName = nil;
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
        
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
        [self logError:@"IronSource adapter failed to requestInterstitial, 'applicationKey' parameter is missing. make sure that 'applicationKey' server parameter is added"];
    }
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController {
    [self logInfo:[NSString stringWithFormat:@"Show IronSource interstitial ad for instance %@",_instanceId]];
    
    if (_placementName) {
        [IronSource showISDemandOnlyInterstitial:rootViewController placement:_placementName instanceId:_instanceId];
    } else {
        [IronSource showISDemandOnlyInterstitial:rootViewController instanceId:_instanceId];
    }
}

#pragma mark IronSource IS Methods

- (void)initInterstitialIronSourceSDKWithAppKey:(NSString *)appKey {
    
    if (!initInterstitialSuccessfully) {
        [self logInfo:@"IronSource SDK initialization complete"];
        
        [IronSource setMediationType:kIronSourceMediationName];
        [IronSource initISDemandOnly:appKey adUnits:@[IS_INTERSTITIAL]];
        
        initInterstitialSuccessfully = YES;
    }
}

- (void)loadInterstitial {
    [self logInfo:[NSString stringWithFormat:@"Load IronSource interstitial ad for instance %@",_instanceId]];
    
    if([IronSource hasISDemandOnlyInterstitial:_instanceId]) {
        [self.delegate interstitialCustomEvent:self didLoadAd:self];
    } else {
        [IronSource loadISDemandOnlyInterstitial:_instanceId];
    }
}

#pragma mark Utiles Methods

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
    [self logInfo:[NSString stringWithFormat:@"IronSource interstitial ad did load for instance %@",instanceId]];
    
    if(![_instanceId isEqualToString:instanceId])
        return;
    
    [self.delegate interstitialCustomEvent:self didLoadAd:nil];
}

/*!
 * @discussion Called each time an ad is not available
 */
- (void)interstitialDidFailToLoadWithError:(NSError *)error instanceId:(NSString *)instanceId {
    [self logError:[NSString stringWithFormat:@"IronSource interstitial ad did fail to load with error: %@, instanceId: %@", error.localizedDescription, instanceId]];
    
    // Ignore callback
    if(![_instanceId isEqualToString:instanceId])
        return;
    
    if (!error) {
        error = [self createErrorWith:@"Netowrk load error"
                            andReason:@"IronSource network failed to load"
                        andSuggestion:@"Check that your network configuration are according to the documentation."];
    }
    
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

/*!
 * @discussion Called each time the Interstitial window is about to open
 */
- (void)interstitialDidOpen:(NSString *)instanceId {
    [self logInfo:[NSString stringWithFormat:@"IronSource interstitial ad did open for instance %@",instanceId]];
    
    // Ignore callback
    if(![_instanceId isEqualToString:instanceId])
        return;
    
    [self.delegate interstitialCustomEventWillAppear:self];
}

/*!
 * @discussion Called each time the Interstitial window is about to close
 */
- (void)interstitialDidClose:(NSString *)instanceId {
    [self logInfo:[NSString stringWithFormat:@"IronSource interstitial ad did close for instance %@",instanceId]];
    
    id<MPInterstitialCustomEventDelegate> strongDelegate = self.delegate;
    [strongDelegate interstitialCustomEventWillDisappear:self];
    [strongDelegate interstitialCustomEventDidDisappear:self];
}

/*!
 * @discussion Called each time the Interstitial window has opened successfully.
 */
- (void)interstitialDidShow:(NSString *)instanceId {
    [self logInfo:[NSString stringWithFormat:@"IronSource interstitial ad did show for instance %@",instanceId]];
    
    [self.delegate interstitialCustomEventDidAppear:self];
}

/*!
 * @discussion Called if showing the Interstitial for the user has failed.
 *
 *              You can learn about the reason by examining the ‘error’ value
 */
- (void)interstitialDidFailToShowWithError:(NSError *)error instanceId:(NSString *)instanceId {
    [self logError:[NSString stringWithFormat:@"IronSource interstitial ad did fail to show with error for instance %@",instanceId]];
}

/*!
 * @discussion Called each time the end user has clicked on the Interstitial ad.
 */
- (void)didClickInterstitial:(NSString *)instanceId {
    [self logInfo:[NSString stringWithFormat:@"Did click IronSource interstitial ad for instance %@",instanceId]];
    
    id<MPInterstitialCustomEventDelegate> strongDelegate = self.delegate;
    [strongDelegate interstitialCustomEventDidReceiveTapEvent:self];
    [strongDelegate interstitialCustomEventWillLeaveApplication:self];
}

@end

