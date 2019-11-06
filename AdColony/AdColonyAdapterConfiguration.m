//
//  AdColonyAdapterConfiguration.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <AdColony/AdColony.h>
#import "AdColonyAdapterConfiguration.h"
#import "AdColonyController.h"
#import "AdColonyAdapterUtility.h"
#if __has_include("MoPub.h")
    #import "MPLogging.h"
#endif

typedef NS_ENUM(NSInteger, AdColonyAdapterErrorCode) {
    AdColonyAdapterErrorCodeMissingAppId,
    AdColonyAdapterErrorCodeMissingZoneIds,
};

@implementation AdColonyAdapterConfiguration

#pragma mark - Caching

+ (void)updateInitializationParameters:(NSDictionary *)parameters {
    // These should correspond to the required parameters checked in
    // `initializeNetworkWithConfiguration:complete:`
    NSString * appId = parameters[ADC_APPLICATION_ID_KEY];
    NSArray * allZoneIds = parameters[ADC_ALL_ZONE_IDS_KEY];
    
    if (appId != nil && allZoneIds.count > 0) {
        NSDictionary * configuration = @{ ADC_APPLICATION_ID_KEY: appId, ADC_ALL_ZONE_IDS_KEY:allZoneIds };
        [AdColonyAdapterConfiguration setCachedInitializationParameters:configuration];
    }
}

#pragma mark - MPAdapterConfiguration

- (NSString *)adapterVersion {
    return @"4.1.2.0";
}

- (NSString *)biddingToken {
    return @"1";
}

- (NSString *)moPubNetworkName {
    return @"adcolony";
}

- (NSString *)networkSdkVersion {
    return [AdColony getSDKVersion];
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> *)configuration
                                  complete:(void(^)(NSError *))complete {
    // AdColony SDK already initialized; complete immediately without error
    if (AdColonyController.sharedInstance.initState == INIT_STATE_INITIALIZED) {
        if (complete != nil) {
            complete(nil);
        }
        return;
    }
    
    NSString * appId = configuration[ADC_APPLICATION_ID_KEY];
    if (appId == nil) {
        NSError * error = [NSError errorWithDomain:ADC_ADAPTER_ERROR_DOMAIN code:AdColonyAdapterErrorCodeMissingAppId userInfo:@{ NSLocalizedDescriptionKey: @"AdColony's initialization skipped. The appId field is empty. Ensure it is properly configured on the MoPub dashboard." }];
        MPLogEvent([MPLogEvent error:error message:nil]);
        
        if (complete != nil) {
            complete(error);
        }
        return;
    }
    
   NSArray * allZoneIds = [self extractAllZoneIds:configuration];
    if (allZoneIds.count == 0) {
        NSError * error = [NSError errorWithDomain:ADC_ADAPTER_ERROR_DOMAIN code:AdColonyAdapterErrorCodeMissingZoneIds userInfo:@{ NSLocalizedDescriptionKey: @"AdColony's initialization skipped. The allZoneIds field is empty. Ensure it is properly configured on the MoPub dashboard." }];
        MPLogEvent([MPLogEvent error:error message:nil]);
        
        if (complete != nil) {
            complete(error);
        }
        return;
    }
    
    // Attempt to retrieve a userId
    NSString * userId = configuration[ADC_USER_ID_KEY];

    MPLogInfo(@"Attempting to initialize the AdColony SDK with:\n%@", configuration);
    [AdColonyController initializeAdColonyCustomEventWithAppId:appId allZoneIds:allZoneIds userId:userId callback:^(NSError *error){
        if (complete != nil) {
            complete(error);
        }
    }];
}

- (NSArray *)extractAllZoneIds:(NSDictionary<NSString *, id> *)configuration
{
    NSArray *allZoneIds = [configuration valueForKeyPath:ADC_ALL_ZONE_IDS_KEY];
    NSString *zoneIdsToString = [allZoneIds description];
    NSData * dataToCheck = [zoneIdsToString dataUsingEncoding:NSUTF8StringEncoding];
    NSError * error = nil;
    // fetch zone ID array, encode to Json Onject to handle Unity prefab values and decode before passing it to AdColony.
    id jsonObject = [NSJSONSerialization JSONObjectWithData:dataToCheck options:0 error:&error];
    
    if (jsonObject != nil) {
        NSData* data = [zoneIdsToString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e1;
        NSMutableArray *jsonZoneIds = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e1];
        return jsonZoneIds;
    } else {
        return allZoneIds;
    }
}

@end
