#import <Foundation/Foundation.h>
#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
#import <MoPubSDK/MoPub.h>
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
extern NSString * const kMoPubVASAdapterVersion;
extern NSString * const kMoPubServerExtrasAdContent;
extern NSString * const kMoPubRequestMetadataAdContent;

extern NSTimeInterval kMoPubVASAdapterSATimeoutInterval;
extern NSString * const kMoPubVASAdImpressionEventId;

@interface VerizonAdapterConfiguration : MPBaseAdapterConfiguration
+ (NSString *)mediator;
@end
