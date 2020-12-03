//
//  AdColonyAdapterConfiguration.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <AdColony/AdColony.h>
#import "AdColonyAdapterConfiguration.h"
#import "AdColonyController.h"
#if __has_include("MoPub.h")
    #import "MPLogging.h"
#endif

// Initialization configuration keys
NSString * const ADC_APPLICATION_ID_KEY = @"appId";
NSString * const ADC_ZONE_ID_KEY        = @"zoneId";
NSString * const ADC_ALL_ZONE_IDS_KEY   = @"allZoneIds";
NSString * const ADC_USER_ID_KEY        = @"userId";

// Errors
static NSString * const kAdapterErrorDomain = @"com.mopub.mopub-ios-sdk.mopub-adcolony-adapters";

typedef NS_ENUM(NSInteger, AdColonyAdapterErrorCode) {
    AdColonyAdapterErrorCodeMissingAppId,
    AdColonyAdapterErrorCodeMissingZoneIds,
};

@implementation AdColonyAdapterConfiguration

#pragma mark - Caching

+ (void)updateInitializationParameters:(NSDictionary *)parameters {
    // These should correspond to the required parameters checked in
    // `initializeNetworkWithConfiguration:complete:`
    NSString * appId      = parameters[ADC_APPLICATION_ID_KEY];
    NSArray  * allZoneIds = parameters[ADC_ALL_ZONE_IDS_KEY];
    
    if (appId != nil && allZoneIds.count > 0) {
        NSDictionary * configuration = @{
            ADC_APPLICATION_ID_KEY: appId,
            ADC_ALL_ZONE_IDS_KEY:allZoneIds
        };
        [AdColonyAdapterConfiguration setCachedInitializationParameters:configuration];
    }
}

#pragma mark - MPAdapterConfiguration

- (NSString *)adapterVersion {
    return @"4.4.1.1.3";
}

- (NSString *)biddingToken {
    return [AdColony collectSignals];;
}

- (NSString *)moPubNetworkName {
    return @"adcolony";
}

- (NSString *)networkSdkVersion {
    return [AdColony getSDKVersion];
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> *)configuration
                                  complete:(void(^)(NSError *))complete {
    // If AdColony SDK already initialized, then complete immediately without error
    if (AdColonyController.sharedInstance.initState == INIT_STATE_INITIALIZED) {
        if (complete != nil) {
            complete(nil);
        }
        return;
    }
    
    NSString * appId = configuration[ADC_APPLICATION_ID_KEY];
    NSError  * appIdError = [AdColonyAdapterConfiguration validateParameter:appId withName:@"appId" forOperation:@"initialization"];
    if (appIdError) {
        MPLogEvent([MPLogEvent error:appIdError message:nil]);
        if (complete != nil) {
            complete(appIdError);
        }
        return;
    }
    
    NSArray * allZoneIds = [[NSMutableArray alloc] init];
    if (configuration != nil) {
        NSArray * extractedAllZoneIds = [self extractAllZoneIds:configuration];
        if (extractedAllZoneIds != nil) {
            allZoneIds = extractedAllZoneIds;
        } else {
            MPLogInfo(@"Failed to parse for AdColony zone IDs due to empty input. Make sure you pass an NSArray of Strings containing your AdColony zone IDs.");
        }
    }

    NSError * allZoneIdsError = [AdColonyAdapterConfiguration validateZoneIds:allZoneIds forOperation:@"initialization"];
    if (allZoneIdsError) {
        MPLogEvent([MPLogEvent error:allZoneIdsError message:nil]);
        if (complete != nil) {
            complete(allZoneIdsError);
        }
        return;
    }
    
    // Parameter userId is specific to Rewarded Videos in iOS, and is a custom user identifier that can be used by the publishers for reward verification. We should pass it to AdColony, if it's present.
    NSString * userId = configuration[ADC_USER_ID_KEY];

    MPLogInfo(@"Attempting to initialize the AdColony SDK with:\n%@", configuration);
    [AdColonyController initializeAdColonyCustomEventWithAppId:appId
                                                    allZoneIds:allZoneIds
                                                        userId:userId
                                                      callback:^(NSError *error) {
        if (complete != nil) {
            complete(error);
        }
    }];
}

- (NSArray *)extractAllZoneIds:(NSDictionary<NSString *, id> *)configuration {
    id allZoneIds = [configuration valueForKeyPath:ADC_ALL_ZONE_IDS_KEY];
    
    if ([allZoneIds isKindOfClass:[NSArray class]]) {
        return allZoneIds;
    } else if ([allZoneIds isKindOfClass:[NSString class]]) {
        NSString * allZoneIdsDescription = [allZoneIds description];
        NSData * allZoneIdsData = [allZoneIdsDescription dataUsingEncoding:NSUTF8StringEncoding];
        NSError * error;
        NSArray * allZoneIdsArray = [[NSMutableArray alloc] init];
        allZoneIdsArray = [NSJSONSerialization JSONObjectWithData:allZoneIdsData options:0 error:&error];
        
        if (error) {
            return nil;
        } else if ([allZoneIdsArray count]) {
            return allZoneIdsArray;
        }
    }
    return nil;
}

+ (NSError *)validateParameter:(NSString *)parameter withName:(NSString *)parameterName forOperation:(NSString *)operation {
    if (parameter != nil && parameter.length > 0) {
        return nil;
    }
    
    NSError * error = [self createErrorForOperation:operation forParameterName:parameterName];
    return error;
}

+ (NSError *)validateZoneIds:(NSArray *)zoneIds forOperation:(NSString *)operation {
    if (zoneIds != nil || zoneIds.count > 0) {
        return nil;
    }
    
    NSError *error = [self createErrorForOperation:operation forParameterName:@"zoneIds"];
    return error;
}

+ (NSError *)createErrorForOperation:(NSString *)operation forParameterName:(NSString *)parameterName {
    if (parameterName == nil) {
        parameterName = @"appId and/or zoneId";
    }
    
    NSString * description = [NSString stringWithFormat:@"AdColony adapter unable to proceed with %@", operation];
    NSString * reason      = [NSString stringWithFormat:@"%@ is nil/empty", parameterName];
    NSString * suggestion  = [NSString stringWithFormat:@"Make sure the AdColony's %@ is configured on the MoPub UI.", parameterName];
    
    return [AdColonyAdapterConfiguration createErrorWith:description
                                               andReason:reason
                                           andSuggestion:suggestion];
}

+ (NSError *)createErrorWith:(NSString *)description andReason:(NSString *)reason andSuggestion:(NSString *)suggestion {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey            : NSLocalizedString(description, nil),
                               NSLocalizedFailureReasonErrorKey     : NSLocalizedString(reason, nil),
                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(suggestion, nil)
                               };

    MPLogDebug(@"%@. %@. %@", description, reason, suggestion);
    
    return [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:userInfo];
}

@end
