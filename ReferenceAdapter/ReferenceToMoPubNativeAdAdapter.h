//
//  ReferenceToMoPubNativeAdAdapter.h
//  MoPub-Reference-Adapters
//
//  Created by Kelly Dun on 3/3/21.
//

#import <Foundation/Foundation.h>
#if __has_include(<MoPubSDK/MoPub.h>)
    #import <MoPubSDK/MoPub.h>
#else
    #import "MPNativeAdAdapter.h"
#endif

#import "ReferenceNetworkNativeAssets.h"

NS_ASSUME_NONNULL_BEGIN

@interface ReferenceToMoPubNativeAdAdapter : NSObject <MPNativeAdAdapter>

/// Initializes the translator with the Reference assets.
- (instancetype)initWithAssets:(ReferenceNetworkNativeAssets *)assets;

@end

NS_ASSUME_NONNULL_END
