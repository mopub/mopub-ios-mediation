//
//  AppLovinNativeCustomEvent.m
//
//
//  Created by Thomas So on 5/21/17.
//
//

#import "AppLovinNativeCustomEvent.h"
#import "MPNativeAdError.h"
#import "MPNativeAd.h"
#import "MPNativeAdAdapter.h"
#import "MPNativeAdConstants.h"
#import "MPError.h"
#import "MPLogging.h"

#if __has_include(<AppLovinSDK/AppLovinSDK.h>)
    #import <AppLovinSDK/AppLovinSDK.h>
#else
    #import "ALSdk.h"
#endif

@interface AppLovinNativeAdapter : NSObject <MPNativeAdAdapter, ALPostbackDelegate>

/**
 * The underlying MP dictionary representing the contents of the native ad.
 */
@property (nonatomic, readwrite) NSDictionary *properties;
@property (nonatomic, strong) ALNativeAd *nativeAd;

- (instancetype)initWithNativeAd:(ALNativeAd *)ad;

@end

@interface AppLovinNativeCustomEvent() <ALNativeAdLoadDelegate>
@property (nonatomic, strong) ALSdk *sdk;
@end

@implementation AppLovinNativeCustomEvent
static NSString *const kALMoPubMediationErrorDomain = @"com.applovin.sdk.mediation.mopub.errorDomain";

#pragma mark - MPNativeCustomEvent Overridden Methods

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info
{
    [[self class] log: @"Requesting AppLovin native ad with info: %@", info];
    
    self.sdk = [self SDKFromCustomEventInfo: info];
    [self.sdk setPluginVersion: @"MoPub-Certified-2.1.0"];
    
    [self.sdk.nativeAdService loadNativeAdGroupOfCount: 1 andNotify: self];
}

#pragma mark - Ad Load Delegate

- (void)nativeAdService:(ALNativeAdService *)service didLoadAds:(NSArray<ALNativeAd *> *)ads
{
    ALNativeAd *nativeAd = [ads firstObject];
    
    [[self class] log: @"Native ad did load ad: %@", nativeAd.adIdNumber];
    
    NSMutableArray<NSURL *> *imageURLs = [NSMutableArray arrayWithCapacity: 2];
    
    if ( nativeAd.iconURL ) [imageURLs addObject: nativeAd.iconURL];
    if ( nativeAd.imageURL ) [imageURLs addObject: nativeAd.imageURL];
    
    // Please note: If/when we add support for videos, we must use AppLovin SDK's built-in precaching mechanism
    
    [self precacheImagesWithURLs: imageURLs completionBlock:^(NSArray<NSError *> *errors)
     {
         [[self class] log: @"Native ad done precaching"];
         
         AppLovinNativeAdapter *adapter = [[AppLovinNativeAdapter alloc] initWithNativeAd: nativeAd];
         MPNativeAd *nativeAd = [[MPNativeAd alloc] initWithAdAdapter: adapter];
         
         [self.delegate nativeCustomEvent: self didLoadAd: nativeAd];
         
         [adapter willAttachToView: nil];
     }];
}

- (void)nativeAdService:(ALNativeAdService *)service didFailToLoadAdsWithError:(NSInteger)code
{
    [[self class] log: @"Native ad video failed to load with error: %d", code];
    
    NSError *error = [NSError errorWithDomain: kALMoPubMediationErrorDomain
                                         code: MPNativeAdErrorNoInventory
                                     userInfo: nil];
    [self.delegate nativeCustomEvent: self didFailToLoadAdWithError: error];
}

#pragma mark - Utility Methods

+ (void)log:(NSString *)format, ...
{
    va_list valist;
    va_start(valist, format);
    NSString *message = [[NSString alloc] initWithFormat: format arguments: valist];
    va_end(valist);
    
    MPLogDebug(@"AppLovinNativeCustomEvent : %@", message);
}

- (ALSdk *)SDKFromCustomEventInfo:(NSDictionary *)info
{
    NSString *SDKKey = info[@"sdk_key"];
    if ( SDKKey.length > 0 )
    {
        return [ALSdk sharedWithKey: SDKKey];
    }
    else
    {
        return [ALSdk shared];
    }
}

@end

@implementation AppLovinNativeAdapter
@synthesize defaultActionURL;
@synthesize delegate;

#pragma mark - Initialization

- (instancetype)initWithNativeAd:(ALNativeAd *)ad
{
    self = [super init];
    if ( self )
    {
        self.nativeAd = ad;
        
        NSMutableDictionary<NSString *, NSString *> *properties = [NSMutableDictionary dictionary];
        properties[kAdTitleKey] = ad.title;
        properties[kAdTextKey] = ad.descriptionText;
        properties[kAdIconImageKey] = ad.iconURL.absoluteString;
        properties[kAdMainImageKey] = ad.imageURL.absoluteString;
        properties[kAdStarRatingKey] = ad.starRating.stringValue;
        properties[kAdCTATextKey] = ad.ctaText;
        
        self.properties = properties;
    }
    return self;
}

#pragma mark - MPNativeAdAdapter Protocol

- (void)displayContentForURL:(NSURL *)URL rootViewController:(UIViewController *)controller
{
    [self.nativeAd launchClickTarget];
}

- (void)willAttachToView:(UIView *)view
{
    if ( [self.delegate respondsToSelector: @selector(nativeAdWillLogImpression:)] )
    {
        [self.delegate nativeAdWillLogImpression: self];
    }
    
    // As of >= 4.1.0, we support convenience methods for impression tracking
    if ( [self.nativeAd respondsToSelector: @selector(trackImpressionAndNotify:)] )
    {
        [self.nativeAd performSelector: @selector(trackImpressionAndNotify:) withObject: self];
    }
    else
    {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        ALPostbackService *postbackService = [ALSdk shared].postbackService;
        [postbackService dispatchPostbackAsync: self.nativeAd.impressionTrackingURL andNotify: self];
#pragma GCC diagnostic pop
    }
}

#pragma mark - Postback Delegate

- (void)postbackService:(ALPostbackService *)postbackService didExecutePostback:(NSURL *)postbackURL
{
    [AppLovinNativeCustomEvent log: @"Native ad impression successfully executed."];
}

- (void)postbackService:(ALPostbackService *)postbackService didFailToExecutePostback:(NSURL *)postbackURL errorCode:(NSInteger)errorCode
{
    [AppLovinNativeCustomEvent log: @"Native ad impression failed to execute."];
}

// TODO: Implement mainMediaView for our video view

@end
