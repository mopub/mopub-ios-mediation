

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const ADC_APPLICATION_ID_KEY;
extern NSString *const ADC_ALL_ZONE_IDS_KEY;
extern NSString *const ADC_ZONE_ID_KEY;

@interface AdColonyAdapterUtility : NSObject
+ (NSError *)validateAppId:(NSString *)appId zonesList:(NSArray *)allZoneIds andZone:(NSString *)zone;
+ (NSError *)createErrorWith:(NSString *)description andReason:(NSString *)reason andSuggestion:(NSString *)suggestion;
@end

NS_ASSUME_NONNULL_END
