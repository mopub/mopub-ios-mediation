//
//  GoogleAdMobAdapterConfiguration.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "GoogleAdMobAdapterConfiguration.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "GADQueryInfo_Preview.h"
#import "GADAdInfo_Preview.h"
#import "GADRequest+AdInfo_Preview.h"

#if __has_include("MoPub.h")
    #import "MPLogging.h"
#endif

#define FIFTEEN_MINUTES_S 900

@interface GoogleAdMobAdapterConfiguration()
@property (class, nonatomic, copy, readwrite) NSMutableDictionary * dv3Tokens;

@end

// Initialization configuration keys
static NSString * const kAdMobApplicationIdKey = @"appid";

// Errors
static NSString * const kAdapterErrorDomain = @"com.mopub.mopub-ios-sdk.mopub-admob-adapters";

static NSString * tokenReference;
static NSMutableDictionary *gDv3Tokens = nil;

typedef NS_ENUM(NSInteger, AdMobAdapterErrorCode) {
    AdMobAdapterErrorCodeMissingAppId,
};

@implementation GoogleAdMobAdapterConfiguration

#pragma mark - Caching

+ (void)updateInitializationParameters:(NSDictionary *)parameters {
    // These should correspond to the required parameters checked in
    // `initializeNetworkWithConfiguration:complete:`
    NSString * appId = parameters[kAdMobApplicationIdKey];
    
    if (appId != nil) {
        NSDictionary * configuration = @{ kAdMobApplicationIdKey: appId };
        [GoogleAdMobAdapterConfiguration setCachedInitializationParameters:configuration];
    }
}

#pragma mark - MPAdapterConfiguration

- (NSString *)adapterVersion {
    return @"7.69.0.3";
}

- (NSString *)biddingToken {
    [self refreshBidderToken];
    
    return tokenReference;
}

- (NSString *)moPubNetworkName {
    return @"google_dv360";
}

- (NSString *)networkSdkVersion {
    return GADMobileAds.sharedInstance.sdkVersion;
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> *)configuration
                                  complete:(void(^)(NSError *))complete {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
          [[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *status){
            MPLogInfo(@"Google Mobile Ads SDK initialized succesfully.");
            if (complete != nil) {
              complete(nil);
            }

            gDv3Tokens = [[NSMutableDictionary alloc] init];

            [self refreshBidderToken];
          }];
        });
    });
}

- (void)refreshBidderToken {
    // On initialization and on each ad request, remove tokens older than 15 minutes
    // before adding new ones
    [self expireTokens];

    GADRequest *request = [GADRequest request];
    
    [GADQueryInfo createQueryInfoWithRequest:request
                                    adFormat:GADAdFormatBanner
                           completionHandler:^(GADQueryInfo *_Nullable queryInfo, NSError *_Nullable error) {
        
        if (error != nil) {
            MPLogInfo(@"Error getting ad info: %@", error.localizedDescription);
        }
        
        if (queryInfo) {
            tokenReference = queryInfo.query;
                            
            NSMutableDictionary *queryInfoParams = [[NSMutableDictionary alloc] init];

            NSDate *now = [NSDate date];
            NSTimeInterval epochTime = [now timeIntervalSince1970];
            
            [queryInfoParams setObject:@(epochTime) forKey:@"timeStamp"];
            [queryInfoParams setObject:queryInfo forKey:@"queryInfo"];

            [gDv3Tokens setObject:queryInfoParams forKey:queryInfo.requestIdentifier];
        }
    }];
}

- (void)expireTokens {
    if (gDv3Tokens && [gDv3Tokens count] > 0) {
        for (id key in gDv3Tokens) {
            NSDate *now = [NSDate date];
            NSTimeInterval epochTime = [now timeIntervalSince1970];

            NSMutableDictionary *queryInfoParams = [gDv3Tokens objectForKey:key];
            NSTimeInterval oldEpochTime = [[queryInfoParams objectForKey:@"timeStamp"] doubleValue];
            
            if (epochTime - oldEpochTime >= FIFTEEN_MINUTES_S) {
                [gDv3Tokens removeObjectForKey:key];
            }
        }
    }
}

// MoPub collects GDPR consent on behalf of Google
+ (NSString *)npaString
{
    return !MoPub.sharedInstance.canCollectPersonalInfo ? @"1" : @"";
}

+ (NSMutableDictionary *)dv3Tokens
{
    return gDv3Tokens;
}

+ (void)setDv3Tokens:(NSMutableDictionary *)dictionary
{
    gDv3Tokens = dictionary;
}

@end

