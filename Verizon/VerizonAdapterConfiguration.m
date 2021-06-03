#import <VerizonAdsCore/VerizonAdsCore.h>
#import <CoreTelephony/CTCarrier.h>
#import "VerizonAdapterConfiguration.h"
#import <zlib.h>

NSString * const kMoPubVASAdapterVersion = @"1.13.0.0";
NSString * const kMoPubVASAdapterErrorWho = @"MoPubVASAdapter";
NSString * const kMoPubVASAdapterPlacementId = @"placementId";
NSString * const kMoPubVASAdapterSiteId = @"siteId";

NSString * const kMoPubVASConfigDomain = @"com.verizon.ads";
NSString * const kMoPubVASConfigEditionNameKey = @"editionName";
NSString * const kMoPubVASConfigEditionVersionKey = @"editionVersion";

NSErrorDomain const kMoPubVASAdapterErrorDomain = @"com.verizon.ads.mopubvasadapter.ErrorDomain";
NSTimeInterval kMoPubVASAdapterSATimeoutInterval = 600;

NSString * const kMoPubVASNetworkName   = @"verizon";
NSString * const kMoPubServerExtrasAdContent     = @"adMarkup";
NSString * const kMoPubRequestMetadataAdContent  = @"adContent";
NSString * const kMoPubVASAdImpressionEventId    = @"adImpression";

NSString * const kVASBiddingTokenVersion = @"1.2";

size_t kVASCompressionBufferSize = 4096;

static NSString * const kVASBiddingTokenKey     = @"biddingToken";
static NSString * biddingToken = nil;

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
            if ([VASAds initializeWithSiteId:siteId]) {
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
    if (! [VASAds sharedInstance].initialized) {
        MPLogInfo(@"Failed to get biddingToken. Verizon SDK must first be initialized.");
        return nil;
    }
    
    if (! biddingToken) {
        biddingToken = [self compressedBiddingToken:[self buildToken]];
    }
    
    return biddingToken;
}

- (NSString *)moPubNetworkName
{
    return kMoPubVASNetworkName;
}

- (NSString *)networkSdkVersion
{
    NSString *editionName = [[[VASAds sharedInstance] configuration] stringForDomain:kDomainVASAds
                                                                                 key:kMoPubVASConfigEditionNameKey
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

- (NSString *)buildToken
{
    NSString *editionName = [[VASAds sharedInstance].configuration stringForDomain:kMoPubVASConfigDomain key:kMoPubVASConfigEditionNameKey withDefault:nil];
    NSString *editionVersion = [[VASAds sharedInstance].configuration stringForDomain:kMoPubVASConfigDomain key:kMoPubVASConfigEditionVersionKey withDefault:nil];
    
    NSString *editionId;
    if (editionName != nil && editionVersion != nil) {
        editionId = [NSString stringWithFormat:@"%@-%@", editionName, editionVersion];
    }
    
    NSDictionary *tokenDict = @{ @"env" : @{ @"sdkInfo" : @{@"version" : kVASBiddingTokenVersion,
                                                            @"editionId" : NULL_OR_VALUE(editionId)
    }
    }
    };
    
    @try {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tokenDict options:0 error:&error];
        if (jsonData != nil) {
            return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        MPLogInfo(@"Unable to build biddingToken, %@", error.description);
        return nil;
    } @catch (NSException *exception) {
        MPLogInfo(@"Unable to build biddingToken, %@", exception.description);
    }
    
    return nil;
}

- (NSString *)compressedBiddingToken:(NSString *)token
{
    NSData *tokenData = [token dataUsingEncoding:NSUTF8StringEncoding];
    
    size_t buf_size = kVASCompressionBufferSize;
    uLongf dest_len = (uLongf)buf_size;
    
    Byte *compr = (Byte*)malloc(buf_size);
    Byte *uncompr = (Byte*)[tokenData bytes];
    
    int result = compress(compr, &dest_len, uncompr, (uLong)tokenData.length);
    if (result != Z_OK) {
        MPLogInfo(@"Unable to compress biddingToken, %@", @(result));
        free(compr);
        return nil;
    }
    
    // Now base64
    NSData *compressedData = [NSData dataWithBytes:compr length:dest_len];
    NSString *base64String = [compressedData base64EncodedStringWithOptions:kNilOptions];
    free(compr);
    
    return base64String;
}

@end
