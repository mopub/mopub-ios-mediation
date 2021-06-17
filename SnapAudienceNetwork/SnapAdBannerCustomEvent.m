#import "SnapAdBannerCustomEvent.h"
#import "SnapAdAdapterConfiguration.h"
#import "SnapAdErrorHelpers.h"

#import <SAKSDK/SAKSDK.h>
#if __has_include("MoPub.h")
    #import "MPError.h"
    #import "MPLogging.h"
    #import "MoPub.h"
#endif

static NSString *const kSAKSlotId = @"slotId";
static NSString *const kSAKAdUnitFormat = @"adunit_format";
static NSString *const kSAKFormatBanner = @"banner";
static NSString *const kSAKFormatMediumRectangle = @"medium_rectangle";

@interface SnapAdBannerCustomEvent () <SAKAdViewDelegate>

@property (nonatomic, copy) NSString *slotId;
@property (nonatomic) SAKAdView *sakAdView;
@property (nonatomic) SAKAdViewFormat sakAdViewFormat;

@end

@implementation SnapAdBannerCustomEvent

@dynamic delegate;
@dynamic localExtras;
@dynamic rootViewController;

#pragma mark - MPInlineAdAdapter Override

- (void)requestAdWithSize:(CGSize)size adapterInfo:(NSDictionary *)info adMarkup:(NSString * _Nullable)adMarkup
{
    _slotId = [info objectForKey:kSAKSlotId];
    
    if (self.slotId) {
        MPLogInfo(@"Server info fetched from MoPub for Snap Ad Kit. slotId : %@", self.slotId);
    } else {
        [self _handleAdLoadFailure:@"Snap's Slot ID received is nil. Ensure this field is populated on your MoPub dashboard."];
        return;
    }
    
    NSString *format = [[info objectForKey:kSAKAdUnitFormat] lowercaseString];
    
    if ([format containsString:kSAKFormatBanner]) {
        _sakAdViewFormat = SAKAdViewFormatBanner;
    } else if ([format containsString:kSAKFormatMediumRectangle]) {
        _sakAdViewFormat = SAKAdViewFormatMediumRectangle;
    } else {
        [self _handleAdLoadFailure:@"Invalid size received. Snap Audience Network only support Banner and Medium Rectangle."];
        return;
    }
    
    _sakAdView = [[SAKAdView alloc] initWithFormat:_sakAdViewFormat];
    _sakAdView.frame = CGRectMake(0, 0, size.width, size.height);
    _sakAdView.delegate = self;
    _sakAdView.translatesAutoresizingMaskIntoConstraints = NO;
    
    SAKAdRequestConfigurationBuilder *configurationBuilder = [SAKAdRequestConfigurationBuilder new];
    [configurationBuilder withPublisherSlotId:self.slotId];
    
    [SnapAdAdapterConfiguration updateInitializationParameters:info];
    
    if ([[SAKMobileAd shared] initialized]) {
        [_sakAdView loadRequest:[configurationBuilder build]];
        
        MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil],
                     self.slotId);
    } else {
        typeof(self) __weak weakSelf = self;
        
        [SnapAdAdapterConfiguration initSnapAdKit:info
                                         complete:^(NSError *error) {
            if (!error) {
                MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil],
                             self.slotId);
                
                [weakSelf.sakAdView loadRequest:[configurationBuilder build]];
            }
        }];
    }
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (void)_handleAdLoadFailure:(NSString *)errorDescription
{
    NSError *error = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd localizedDescription:errorDescription];
    
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.slotId);
    [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
}

#pragma mark - SAKAdViewDelegate methods

- (void)adViewDidLoad:(SAKAdView *)adView
{
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], self.slotId);
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.slotId);
    
    [self.delegate inlineAdAdapter:self didLoadAdWithAdView:adView];
}

- (void)adView:(SAKAdView *)adView didFailWithError:(NSError *)error
{
    [self _handleAdLoadFailure:SnapAdErrorDescription(error)];
}

- (void)adViewDidTrackImpression:(SAKAdView *)adView
{
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], self.slotId);
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], self.slotId);
    
    [self.delegate inlineAdAdapterDidTrackImpression:self];
}

- (void)adViewDidClick:(SAKAdView *)adView
{
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], self.slotId);
    [self.delegate inlineAdAdapterDidTrackClick:self];
}

- (UIViewController *)rootViewController
{
    return [self.delegate inlineAdAdapterViewControllerForPresentingModalView:self];
}

@end
