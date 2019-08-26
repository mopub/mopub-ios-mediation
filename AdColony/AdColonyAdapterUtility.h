

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdColonyAdapterUtility : NSObject
+ (NSError *)validateAppId:(NSString *)appId andZoneIds:(NSArray *)zoneIds;
+ (NSError *)createErrorWith:(NSString *)description andReason:(NSString *)reason andSuggestion:(NSString *)suggestion;
@end

NS_ASSUME_NONNULL_END
