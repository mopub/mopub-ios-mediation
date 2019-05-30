#import <VerizonAdsStandardEdition/VerizonAdsStandardEdition.h>
#import <VerizonAdsCore/VerizonAdsCore.h>
#import "VerizonAdapterConfiguration.h"
#if __has_include("MoPub.h")
#import "MoPub.h"
#endif

NSErrorDomain const kMoPubVASAdapterErrorDomain = @"com.verizon.ads.mopubvasadapter.ErrorDomain";
NSString * const kMoPubVASAdapterErrorWho = @"MoPubVASAdapter";
NSString * const kMoPubVASAdapterPlacementId = @"placementId";
NSString * const kMoPubVASAdapterSiteId = @"siteId";
NSString * const kMoPubMillennialAdapterPlacementId = @"adUnitID";
NSString * const kMoPubMillennialAdapterSiteId = @"dcn";
NSString * const kMoPubVASAdapterVersion = @"1.1.2.0";
NSTimeInterval kMoPubVASAdapterSATimeoutInterval = 600;

@implementation VerizonAdapterConfiguration

+ (NSString *)appMediator
{
    return [NSString stringWithFormat:@"MoPubVAS-%@",kMoPubVASAdapterVersion];
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
    
    MPBLogLevel * logLevel = [[MoPub sharedInstance] logLevel];

    if (logLevel == MPBLogLevelDebug) {
        [VASAds setLogLevel:VASLogLevelDebug];
    } else if (logLevel == MPBLogLevelInfo) {
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
    return VASAds.sdkInfo.version;
}

@end

@implementation MillennialAdapterConfiguration

- (NSString *)moPubNetworkName
{
    return @"Millennial";
}

@end
