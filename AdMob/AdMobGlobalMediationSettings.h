#import <Foundation/Foundation.h>

#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
#import <MoPubSDKFramework/MoPub.h>
#else
#import "MPMediationSettingsProtocol.h"
#endif

@interface AdMobGlobalMediationSettings : NSObject <MPMediationSettingsProtocol>

/* The "npa" field set by the publisher.
 * "-1" if the user would like to opt out of ad personalization from AdMob
 */
@property (nonatomic,copy) NSString *adPersonalizationPref;
@end
