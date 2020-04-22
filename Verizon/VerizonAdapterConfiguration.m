#import <VerizonAdsStandardEdition/VerizonAdsStandardEdition.h>
#import <VerizonAdsCore/VerizonAdsCore.h>
#import <CoreTelephony/CTCarrier.h>
#import "VerizonAdapterConfiguration.h"

NSString * const kMoPubVASAdapterVersion = @"1.5.0.0";

NSString * const kMoPubVASAdapterErrorWho = @"MoPubVASAdapter";
NSString * const kMoPubVASAdapterPlacementId = @"placementId";
NSString * const kMoPubVASAdapterSiteId = @"siteId";

NSErrorDomain const kMoPubVASAdapterErrorDomain = @"com.verizon.ads.mopubvasadapter.ErrorDomain";
NSTimeInterval kMoPubVASAdapterSATimeoutInterval = 600;

NSString * const kMoPubVASNetworkName   = @"verizon";
NSString * const kMoPubServerExtrasAdContent     = @"adMarkup";
NSString * const kMoPubRequestMetadataAdContent  = @"adContent";

static NSString * const kVASBiddingTokenKey     = @"biddingToken";
static NSString * const kVASDefaultBiddingToken = @"eJyrVkrNK1OyqlYqTsn2zEvLBzFTUzJLMvPzPFOUrJSKSxLzUhKLUnShgrqGeqZ6Bko6SmWpRcVAPlCJIZBfW1sLAK6jGGM=";

@interface VerizonAdapterConfiguration ()

@end

@implementation VerizonAdapterConfiguration

+ (NSString *)mediator
{
    static NSString *_appMediator = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _appMediator = [NSString stringWithFormat:@"MoPubVAS-%@", kMoPubVASAdapterVersion];
    });
    
    return _appMediator;
}

+ (void)updateInitializationParameters:(NSDictionary *)parameters {}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> * _Nullable)configuration complete:(void(^ _Nullable)(NSError * _Nullable))complete
{
    NSString *siteId = configuration[kMoPubVASAdapterSiteId];
    if (siteId.length == 0) {
        siteId = [VerizonAdapterConfiguration cachedInitializationParameters][kMoPubVASAdapterSiteId];
    }
    if (siteId.length > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([VASStandardEdition initializeWithSiteId:siteId]) {
                MPLogInfo(@"VAS adapter version: %@", kMoPubVASAdapterVersion);
            }
            if (complete) {
                complete(nil);
            }
        });
    } else {
        if (complete) {
            complete(nil);
        }
    }
    
    if (MPLogging.consoleLogLevel == MPBLogLevelDebug) {
        [VASAds setLogLevel:VASLogLevelDebug];
    } else if (MPLogging.consoleLogLevel == MPBLogLevelInfo) {
        [VASAds setLogLevel:VASLogLevelInfo];
    }
}

- (NSString *)adapterVersion
{
    return kMoPubVASAdapterVersion;
}

- (NSString *)biddingToken
{
    return [VASAds.sharedInstance.configuration stringForDomain:kDomainVASAds
                                                            key:kVASBiddingTokenKey
                                                    withDefault:kVASDefaultBiddingToken];
}

- (NSString *)moPubNetworkName
{
    return kMoPubVASNetworkName;
}

- (NSString *)networkSdkVersion
{
    NSString *editionName = [[[VASAds sharedInstance] configuration] stringForDomain:kDomainVASAds
                                                                                 key:kVASEditionNameKey
                                                                         withDefault:nil];
    
    NSString *editionVersion = [[[VASAds sharedInstance] configuration] stringForDomain:kDomainVASAds
                                                                                    key:kVASEditionVersionKey
                                                                            withDefault:nil];
    if (editionName.length > 0 && editionVersion.length > 0) {
        return [NSString stringWithFormat:@"%@-%@", editionName, editionVersion];
    }
    
    NSString *adapterVersion = [self adapterVersion];
    NSRange range = [adapterVersion rangeOfString:@"." options:NSBackwardsSearch];
    
    return adapterVersion.length > range.location ? [adapterVersion substringToIndex:range.location] : @"";
}

@end
