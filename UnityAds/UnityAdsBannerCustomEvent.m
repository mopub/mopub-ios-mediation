//
// Created by Ross Rothenstine on 11/5/18.
// Copyright (c) 2018 MoPub. All rights reserved.
//

#import "UnityAdsBannerCustomEvent.h"
#import "UnityRouter.h"
#if __has_include("MoPub.h")
    #import "MPLogging.h"
#endif
#import "UnityAdsAdapterConfiguration.h"

static NSString *const kMPUnityBannerGameId = @"gameId";
static NSString *const kUnityAdsOptionPlacementIdKey = @"placementId";
static NSString *const kUnityAdsOptionZoneIdKey = @"zoneId";

@interface UnityAdsBannerCustomEvent ()
@property (nonatomic, strong) NSString *placementId;
@property (nonatomic, strong) UADSBannerView *bannerAdView;
@end

@implementation UnityAdsBannerCustomEvent
@dynamic delegate;
@dynamic localExtras;

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

-(id)init {
    if (self = [super init]) {

    }
    return self;
}

-(void)dealloc {
    if (self.bannerAdView) {
        self.bannerAdView.delegate = nil;
    }
    
    self.bannerAdView = nil;
}

-(void)requestAdWithSize:(CGSize)size adapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    NSString *gameId = info[kMPUnityBannerGameId];
    self.placementId = info[kUnityAdsOptionPlacementIdKey];
    
    if (self.placementId == nil) {
        self.placementId = info[kUnityAdsOptionZoneIdKey];
    }
    
    NSString *format = [info objectForKey:@"adunit_format"];
    BOOL isMediumRectangleFormat = (format != nil ? [[format lowercaseString] containsString:@"medium_rectangle"] : NO);
    
    if (isMediumRectangleFormat) {
        NSError *error = [self createErrorWith:@"Invalid ad format request received"
                                     andReason:@"UnityAds only supports banner ads"
                                 andSuggestion:@"Ensure the format type of your MoPub adunit is banner and not Medium Rectangle."];
        
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:nil];
        
        return;
    }
    
    if (gameId == nil || self.placementId == nil) {
        NSError *error = [self createErrorWith:@"Unity Ads adapter failed to request banner ad"
                                     andReason:@"Custom event class data did not contain gameId/placementId"
                                 andSuggestion:@"Update your MoPub custom event class data to contain a valid Unity Ads gameId/placementId."];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
        
        return;
    }

    // Only need to cache game ID for SDK initialization
    [UnityAdsAdapterConfiguration updateInitializationParameters:info];
    
    if (![UnityAds isInitialized]) {
        [[UnityRouter sharedRouter] initializeWithGameId:gameId withCompletionHandler:nil];
        
        NSError *error = [self createErrorWith:@"Unity Ads adapter failed to request banner ad, Unity Ads is not initialized yet. Failing this ad request and calling Unity Ads initialization so it would be available for an upcoming ad request"
                                     andReason:@"Unity Ads is not initialized."
                                 andSuggestion:@""];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
        
        return;
    }
    
    CGSize adSize = [self unityAdsAdSizeFromRequestedSize:size];
    
    self.bannerAdView = [[UADSBannerView alloc] initWithPlacementId:self.placementId size:adSize];
    self.bannerAdView.delegate = self;
    [self.bannerAdView load];

    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getAdNetworkId]);
}

- (CGSize)unityAdsAdSizeFromRequestedSize:(CGSize)size
{
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    if (width >= 728 && height >=90) {
       return CGSizeMake(728, 90);
    } else if (width >= 468 && height >=60) {
        return CGSizeMake(468, 60);
    } else {
        return CGSizeMake(320, 50);
    }
}

#pragma mark - UnityAdsBannerDelegate

- (NSError *)createErrorWith:(NSString *)description andReason:(NSString *)reason andSuggestion:(NSString *)suggestion {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(description, nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(reason, nil),
                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(suggestion, nil)
                               };
    
    return [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:userInfo];
}

#pragma mark - UADSBannerViewDelegate

- (void)bannerViewDidLoad:(UADSBannerView *)bannerView {
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    
    [self.delegate inlineAdAdapter:self didLoadAdWithAdView:bannerView];
    [self.delegate inlineAdAdapterDidTrackImpression:self];
}

- (void)bannerViewDidClick:(UADSBannerView *)bannerView {
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate inlineAdAdapterWillBeginUserAction:self];
    [self.delegate inlineAdAdapterDidTrackClick:self];
}

- (void)bannerViewDidLeaveApplication:(UADSBannerView *)bannerView {
    [self.delegate inlineAdAdapterWillLeaveApplication:self];
}

- (void)bannerViewDidError:(UADSBannerView *)bannerView error:(UADSBannerError *)error{
    
    NSError *mopubAdaptorErrorMessage;
    switch ([error code]) {
        case UADSBannerErrorCodeUnknown:
        mopubAdaptorErrorMessage = [self createErrorWith:@"Unity Ads Banner returned unknown error" andReason:@"" andSuggestion:@""];
        break;
            
        case UADSBannerErrorCodeNativeError:
        mopubAdaptorErrorMessage = [self createErrorWith:@"Unity Ads Banner returned native error" andReason:@"" andSuggestion:@""];
        break;
            
        case UADSBannerErrorCodeWebViewError:
        mopubAdaptorErrorMessage = [self createErrorWith:@"Unity Ads Banner returned WebView error" andReason:@"" andSuggestion:@""];
        break;
            
        case UADSBannerErrorCodeNoFillError:
        mopubAdaptorErrorMessage = [self createErrorWith:@"Unity Ads Banner returned no fill" andReason:@"" andSuggestion:@""];
        break;
    }
    
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:mopubAdaptorErrorMessage], [self getAdNetworkId]);

    [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:nil];
}

- (NSString *) getAdNetworkId {
    return (self.placementId != nil) ? self.placementId : @"";
}

@end
