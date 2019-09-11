#import <VerizonAdsStandardEdition/VerizonAdsStandardEdition.h>
#import <VerizonAdsCore/VerizonAdsCore.h>
#import "VerizonAdapterConfiguration.h"

NSString * const kMoPubVASAdapterVersion = @"1.1.4.1";
NSString * const kMoPubVASNetworkSdkVersion = @"1.1.4";

NSString * const kMoPubVASAdapterErrorWho = @"MoPubVASAdapter";
NSString * const kMoPubVASAdapterPlacementId = @"placementId";
NSString * const kMoPubVASAdapterSiteId = @"siteId";
NSString * const kMoPubMillennialAdapterPlacementId = @"adUnitID";
NSString * const kMoPubMillennialAdapterSiteId = @"dcn";

NSErrorDomain const kMoPubVASAdapterErrorDomain = @"com.verizon.ads.mopubvasadapter.ErrorDomain";
NSTimeInterval kMoPubVASAdapterSATimeoutInterval = 600;

@implementation VerizonAdapterConfiguration

+ (NSString *)appMediator
{
    return [NSString stringWithFormat:@"MoPubVAS-%@", kMoPubVASAdapterVersion];
}

+ (void)updateInitializationParameters:(NSDictionary *)parameters {}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> * _Nullable)configuration complete:(void(^ _Nullable)(NSError * _Nullable))complete
{
    NSString *siteId = configuration[kMoPubVASAdapterSiteId];
    if (siteId.length > 0 && [VASStandardEdition initializeWithSiteId:siteId])
    {
        MPLogInfo(@"VAS adapter version: %@", kMoPubVASAdapterVersion);
    }
    if (complete)
    {
        complete(nil);
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
    return nil;
}

- (NSString *)moPubNetworkName
{
    return @"Verizon";
}

- (NSString *)networkSdkVersion
{
    return kMoPubVASNetworkSdkVersion;
}

@end

@implementation MillennialAdapterConfiguration

- (NSString *)moPubNetworkName
{
    return @"Millennial";
}

@end
