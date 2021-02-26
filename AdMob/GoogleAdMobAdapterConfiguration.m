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
    #import "MPRealTimeTimer.h"
#endif

#define FIFTEEN_MINUTES_S 900

@interface GoogleAdMobAdapterConfiguration()
@property (class, nonatomic, copy, readwrite) NSCache * dv3Tokens;
@property (nonatomic, strong) MPRealTimeTimer *timer;

@end

// Initialization configuration keys
static NSString * const kAdMobApplicationIdKey = @"appid";

// Errors
static NSString * const kAdapterErrorDomain = @"com.mopub.mopub-ios-sdk.mopub-admob-adapters";

static NSString * tokenReference;
static NSCache *gDv3Tokens = nil;

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
    if ([tokenReference length] == 0) {
      [self refreshBidderToken];
    }
    
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

            gDv3Tokens = [[NSCache alloc] init];

            [self refreshBidderToken];
          }];
        });
    });
}

- (void)refreshBidderToken {
    GADRequest *request = [GADRequest request];
    
    [GADQueryInfo createQueryInfoWithRequest:request
                                    adFormat:GADAdFormatBanner
                           completionHandler:^(GADQueryInfo *_Nullable queryInfo, NSError *_Nullable error) {
        
        if (error != nil) {
            MPLogInfo(@"Error getting ad info: %@", error.localizedDescription);
        }
        
        if (queryInfo) {
            tokenReference = queryInfo.query;

            [gDv3Tokens setObject:queryInfo forKey:queryInfo.requestIdentifier];
                        
            self.timer = [[MPRealTimeTimer alloc] initWithInterval:FIFTEEN_MINUTES_S block:^(MPRealTimeTimer *timer) {
              [gDv3Tokens removeAllObjects];
              tokenReference = nil;
              
              [self cancelExpirationTimer];
            }];

            [self.timer scheduleNow];
        }
    }];
}

- (void)cancelExpirationTimer
{
    if (self.timer != nil) {
      [self.timer invalidate];
      self.timer = nil;
    }
}

// MoPub collects GDPR consent on behalf of Google
+ (NSString *)npaString
{
    return !MoPub.sharedInstance.canCollectPersonalInfo ? @"1" : @"";
}

+ (NSCache *)dv3Tokens
{
    return gDv3Tokens;
}

+ (void)setDv3Tokens:(NSCache *)cache
{
    gDv3Tokens = cache;
}

@end

