

#import "AdColonyAdapterUtility.h"
#import <AdColony/AdColony.h>

#if __has_include("MoPub.h")
#import "MPLogging.h"
#endif

NSString *const ADC_APPLICATION_ID_KEY = @"appId";
NSString *const ADC_ALL_ZONE_IDS_KEY = @"allZoneIds";
NSString *const ADC_ZONE_ID_KEY = @"zoneId";

@implementation AdColonyAdapterUtility

+ (NSError *)validateAppId:(NSString *)appId zonesList:(NSArray *)allZoneIds andZone:(NSString *)zone {
    // Validate App ID required for SDK configuration
    if (appId.length == 0) {
        NSError *error = [self createErrorWith:@"AdColony adapter unable to proceed request"
                                     andReason:@"App Id is nil/empty"
                                 andSuggestion:@"The 'appId' field is empty. Ensure it is properly configured on the MoPub dashboard."];
        
        MPLogDebug(@"%@. %@. %@", error.localizedDescription, error.localizedFailureReason, error.localizedRecoverySuggestion);
        return error;
    }
    
    // Validate zone Ids required for SDK configuration
    if (allZoneIds.count == 0) {
        NSError *error = [self createErrorWith:@"AdColony adapter unable to proceed request"
                                     andReason:@"Zone Id list is nil/empty"
                                 andSuggestion:@"The 'allZoneIds' field is empty. Ensure it is properly configured on the MoPub dashboard."];
        
        MPLogDebug(@"%@. %@. %@", error.localizedDescription, error.localizedFailureReason, error.localizedRecoverySuggestion);
        return error;
    }
    
    // Validate zone Id required to send ad requests
    if (zone.length == 0) {
        NSError *error = [self createErrorWith:@"AdColony adapter unable to proceed request"
                                     andReason:@"Zone Id is nil/empty"
                                 andSuggestion:@"The 'zoneId' field is empty. Ensure it is properly configured on the MoPub dashboard."];
        
        MPLogDebug(@"%@. %@. %@", error.localizedDescription, error.localizedFailureReason, error.localizedRecoverySuggestion);
        return error;
    }
    
    return nil;
}

+ (NSError *)createErrorWith:(NSString *)description andReason:(NSString *)reason andSuggestion:(NSString *)suggestion {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(description, nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(reason, nil),
                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(suggestion, nil)
                               };
    
    return [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:userInfo];
}

@end
