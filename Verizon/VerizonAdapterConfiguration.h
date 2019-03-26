#import <Foundation/Foundation.h>
#import "MoPub.h"
#import "MPBaseAdapterConfiguration.h"

// Error keys
extern NSErrorDomain const kMoPubVASAdapterErrorDomain;
extern NSString * const kMoPubVASAdapterErrorWho;

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
