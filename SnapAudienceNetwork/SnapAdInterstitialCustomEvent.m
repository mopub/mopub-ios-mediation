#import "SnapAdInterstitialCustomEvent.h"
#import "SnapAdAdapterConfiguration.h"
#import <SAKSDK/SAKSDK.h>
#import <UIKit/UIKit.h>
#if __has_include("MoPub.h")
    #import "MPError.h"
    #import "MPLogging.h"
    #import "MoPub.h"
#endif

static NSString * const kSAKSlotId = @"slotId";

@interface  SnapAdInterstitialCustomEvent() <SAKInterstitialDelegate>

@property (nonatomic, strong) SAKInterstitial *adInterstitial;
@property (nonatomic, copy) NSString *slotId;
@property (nonatomic) CGRect transitionLocation;

@end

@implementation SnapAdInterstitialCustomEvent

@dynamic delegate;
@dynamic localExtras;

#pragma mark - MPFullscreenAdAdapter Override

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    self.slotId = [info objectForKey:kSAKSlotId];
    
    if (!self.slotId) {
        NSError *error = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd localizedDescription:@"Snap's Slot ID received is nil."];
        
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        
        return;
    } else {
        MPLogInfo(@"[MoPub] Server info fetched from MoPub for Snap Ad Kit. slotId : %@", [self getAdNetworkId]);
    }
    
    [SnapAdAdapterConfiguration updateInitializationParameters:info];
    
    if (!self.adInterstitial) {
        self.adInterstitial = [SAKInterstitial new];
        self.adInterstitial.delegate = self;
    }
    
    SAKAdRequestConfigurationBuilder *configurationBuilder = [SAKAdRequestConfigurationBuilder new];
    [configurationBuilder withPublisherSlotId:self.slotId];
    
    if (![[SAKMobileAd shared] initialized]) {
        [SnapAdAdapterConfiguration initSnapAdKit:info complete:^(NSError * error) {
            if (error == nil) {
                MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getAdNetworkId]);
                
                [self.adInterstitial loadRequest:[configurationBuilder build]];
            }
        }];
    } else {
        MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getAdNetworkId]);
        
        [self.adInterstitial loadRequest:[configurationBuilder build]];
    }
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (void)presentAdFromViewController:(UIViewController *)rootViewController
{
    if (self.adInterstitial) {
        MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
        [self.adInterstitial presentFromRootViewController:rootViewController dismissTransition:self.transitionLocation];
    } else {
        NSError *error = [self createErrorWith:@"[MoPub] Snap Ad Kit interstitial not ready yet."
                                     andReason:@""
                                 andSuggestion:@"You can make a new ad request."];
        
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:error];
    }
}

- (void)handleDidInvalidateAd
{
    // no-op
}

- (void)handleDidPlayAd
{
    // no-op
}

- (BOOL)hasAdAvailable
{
    return self.adInterstitial.isReady;
}

- (BOOL)isRewardExpected
{
    return NO;
}

- (void)dealloc
{
    self.adInterstitial.delegate = nil;
    self.adInterstitial = nil;
}

- (NSError *)createErrorWith:(NSString *)description andReason:(NSString *)reason andSuggestion:(NSString *)suggestion
{
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey: NSLocalizedString(description, nil),
        NSLocalizedFailureReasonErrorKey: NSLocalizedString(reason, nil),
        NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(suggestion, nil)
    };
    
    return [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:userInfo];
}

- (NSString *) getAdNetworkId
{
    return (self.slotId) ? self.slotId : @"";
}

#pragma mark - APInterstitialDelegate delegates

- (void)interstitialDidLoad:(NSString *)instanceId
{
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], instanceId);
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
}

- (void)interstitialDidLoadAd:(SAKInterstitial *)interstitial
{
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
}

#pragma mark - SAKInterstitialDelegate

- (void)interstitial:(nonnull SAKInterstitial *)ad didFailWithError:(nonnull NSError *)error
{
    MPLogInfo(@"[MoPub] Snap Ad Kit error: %@", error);
    NSError * errorcode;
    
    switch([error code]) {
        case SAKErrorNetworkError:
            errorcode = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd localizedDescription:@"[MoPub] SAKErrorNetworkError"];
            break;
        case SAKErrorNotEligible:
            errorcode = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd localizedDescription:@"[MoPub] SAKErrorNotEligible"];
            break;
        case SAKErrorFailedToParse:
            errorcode = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd localizedDescription:@"[MoPub] SAKErrorFailedToParse"];
            break;
        case SAKErrorSDKNotInitialized:
            errorcode = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd localizedDescription:@"[MoPub] SAKErrorSDKNotInitialized"];
            break;
        case SAKErrorNoAdAvailable:
            errorcode = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd localizedDescription:@"[MoPub] SAKErrorNoAdAvailable"];
            break;
        case SAKErrorCodeNoCreativeEndpoint:
            errorcode = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd localizedDescription:@"[MoPub] SAKErrorCodeNoCreativeEndpoint"];
            break;
        default:
            MPLogInfo(@"Encountered an unknown error from Snap");
            break;
    }
    
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:errorcode], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)interstitialDidExpire:(SAKInterstitial *)ad
{
    NSError *error = [self createErrorWith:@"Error in loading Snap interstitial."
                                 andReason:@"Snap interstitial has expired."
                             andSuggestion:@"Make a new ad request."];
    MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterDidExpire:self];
    [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:error];
}

- (void)interstitialWillAppear:(SAKInterstitial *)ad
{
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterAdWillPresent:self];
}

- (void)interstitialDidAppear:(SAKInterstitial *)ad
{
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterAdDidPresent:self];
}

- (void)interstitialWillDisappear:(SAKInterstitial *)ad
{
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterAdWillDismiss:self];
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
}

- (void)interstitialDidDisappear:(SAKInterstitial *)ad
{
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
    [self.delegate fullscreenAdAdapterAdDidDismiss:self];
}

- (void)interstitialDidTrackImpression:(SAKInterstitial *)ad
{
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterDidTrackImpression:self];
}

- (void)interstitialDidShowAttachment:(SAKInterstitial *)ad
{
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adWillLeaveApplicationForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    
    [self.delegate fullscreenAdAdapterDidReceiveTap:self];
    [self.delegate fullscreenAdAdapterDidTrackClick:self];
}

@end
