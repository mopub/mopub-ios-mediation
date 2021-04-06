#import <Foundation/Foundation.h>
#import <VerizonAdsNativePlacement/VerizonAdsNativePlacement.h>
#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
#import <MoPubSDK/MoPub.h>
#else
#import "MoPub.h"
#endif

// VASNativeAd and component keys
extern NSString * const kVASNativeAd;       // NSString *
extern NSString * const kTitleCompId;       // NSString *
extern NSString * const kBodyCompId;        // NSString *
extern NSString * const kCTACompId;         // NSString *
extern NSString * const kRatingCompId;      // NSString *
extern NSString * const kDisclaimerCompId;  // NSString *
extern NSString * const kMainImageCompId;   // NSString *
extern NSString * const kIconImageCompId;   // NSString *
extern NSString * const kVideoCompId;       // NSString *

@interface MPVerizonNativeAdAdapter : NSObject <MPNativeAdAdapter, VASNativeAdDelegate>

@property (nonatomic, weak) id<MPNativeAdAdapterDelegate> delegate;

- (instancetype)initWithSiteId:(NSString *)siteId;

- (void)setupWithVASNativeAd:(VASNativeAd *)vasNativeAd;

@end
