#import <Foundation/Foundation.h>

#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#else
#import "MPMediationSettingsProtocol.h"
#endif

@interface TapjoyGlobalMediationSettings : NSObject <MPMediationSettingsProtocol>
/*
 * @param sdkKey The application SDK Key. Retrieved from the app dashboard in your Tapjoy account.
 * Used to complete the connect call for a specific publisher, and is passed
 * along to Tapjoy when the rewarded video ad is played.
 */
@property (nonatomic,copy) NSString *sdkKey;

/*
 * @param connectFlags NSDictionary of special flags to enable non-standard settings. Valid key:value options:
 *
 * TJC_OPTION_ENABLE_LOGGING : BOOL to enable logging
 *
 * TJC_OPTION_USER_ID : NSString user id that must be set if your currency is not managed by Tapjoy. If you don’t have a user id on launch you can call setUserID later
 */
@property (nonatomic,copy) NSMutableDictionary *connectFlags;
@end
