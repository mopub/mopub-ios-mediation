#import <Foundation/Foundation.h>
#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
#import <MoPubSDKFramework/MoPub.h>
#else
#import "MoPub.h"
#endif

// Error keys
extern NSErrorDomain const kMoPubVASAdapterErrorDomain;
extern NSString * const kMoPubVASAdapterErrorWho;

/// Error codes that are used by VASErrorInfo in the core error domain.
typedef NS_ENUM(NSInteger, MoPubVASAdapterError) {
    /// The adapter is not properly configured.
    MoPubVASAdapterErrorInvalidConfig = 1,
    /// The Verizon SDK was not properly initialized.
    MoPubVASAdapterErrorNotInitialized
};

// Configuration keys
extern NSString * const kMoPubVASAdapterPlacementId;
extern NSString * const kMoPubVASAdapterSiteId;
extern NSString * const kMoPubMillennialAdapterPlacementId;
extern NSString * const kMoPubMillennialAdapterSiteId;
extern NSString * const kMoPubVASAdapterVersion;
extern NSTimeInterval kMoPubVASAdapterSATimeoutInterval;

@interface VerizonAdapterConfiguration : MPBaseAdapterConfiguration
+ (NSString *)appMediator;
@end

@interface MillennialAdapterConfiguration : VerizonAdapterConfiguration
@end
