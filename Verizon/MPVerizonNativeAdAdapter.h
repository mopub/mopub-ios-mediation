#import <Foundation/Foundation.h>
#import <VerizonAdsNativePlacement/VerizonAdsNativePlacement.h>
#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
#import <MoPubSDKFramework/MoPub.h>
#else
#import "MoPub.h"
#endif

// <MPNativeAdRendering> custom asset properties.
extern NSString * const kVASDisclaimerKey;      // NSString *
extern NSString * const kVASVideoViewKey;       // NSString *

@interface MPVerizonNativeAdAdapter : NSObject <MPNativeAdAdapter, VASNativeAdDelegate>

@property (nonatomic, weak) id<MPNativeAdAdapterDelegate> delegate;

- (instancetype)initWithSiteId:(NSString *)siteId;

- (void)setupWithVASNativeAd:(VASNativeAd *)vasNativeAd;

@end
