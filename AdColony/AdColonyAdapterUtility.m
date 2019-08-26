

#import "AdColonyAdapterUtility.h"
#import <AdColony/AdColony.h>

#if __has_include("MoPub.h")
#import "MPLogging.h"
#endif

@implementation AdColonyAdapterUtility

+ (NSError *)validateAppId:(NSString *)appId andZoneIds:(NSArray *)zoneIds {
    if (appId.length == 0) {
        NSError *error = [self createErrorWith:@"AdColony adapter unable to proceed request"
                                     andReason:@"App Id is nil/empty"
                                 andSuggestion:@"Make sure the App Id is configured on the MoPub UI."];
        
        MPLogDebug(@"%@. %@. %@", error.localizedDescription, error.localizedFailureReason, error.localizedRecoverySuggestion);
        return error;
    }
    
    if (zoneIds != nil && zoneIds.count > 0) {
        NSString *firstZoneId = zoneIds[0];
        if (firstZoneId.length != 0) {
            return nil;
        }
    }
    
    NSError *error = [self createErrorWith:@"AdColony adapter unable to proceed request"
                                 andReason:@"Zone Id is nil/empty"
                             andSuggestion:@"Make sure the Zone Id is configured on the MoPub UI."];
    
    MPLogDebug(@"%@. %@. %@", error.localizedDescription, error.localizedFailureReason, error.localizedRecoverySuggestion);
    return error;
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
