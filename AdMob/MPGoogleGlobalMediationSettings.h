#import <Foundation/Foundation.h>

#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
#import <MoPubSDK/MoPub.h>
#else
#import "MPMediationSettingsProtocol.h"
#import "MoPub.h"
#endif

@interface MPGoogleGlobalMediationSettings : NSObject <MPMediationSettingsProtocol>

@property(nonatomic, copy) NSString *npa;

@end
