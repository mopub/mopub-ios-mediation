#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSError *SnapAdCreateError(Class domainClass, NSString *description, NSString *reason, NSString *suggestion);

extern NSString *SnapAdErrorDescription(NSError *error);

NS_ASSUME_NONNULL_END
