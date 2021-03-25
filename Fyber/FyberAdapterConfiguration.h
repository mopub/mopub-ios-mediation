#import <Foundation/Foundation.h>
#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
#import <MoPubSDK/MoPub.h>
#else
#import <MoPub.h>
#import "MPBaseAdapterConfiguration.h"
#import "MPLogging.h"
#endif

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, IASDKMopubAdapterError) {
    IASDKMopubAdapterErrorUnknown = 1,
    IASDKMopubAdapterErrorMissingAppID,
    IASDKMopubAdapterErrorSDKInit,
    IASDKMopubAdapterErrorInternal,
};

extern NSString * const kIASDKMopubAdapterAppIDKey;
extern NSString * const kIASDKMoPubAdapterErrorDomain;

extern NSNotificationName _Nonnull kIASDKInitCompleteNotification;

@interface FyberAdapterConfiguration : MPBaseAdapterConfiguration

+ (void)configureIASDKWithInfo:(NSDictionary *)info;

+ (void)collectConsentStatusFromMoPub;

@end

NS_ASSUME_NONNULL_END
