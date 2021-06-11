//
//  ReferenceNativeAdRenderer.h
//  MoPub-Reference-Adapters
//
//  Created by Kelly Dun on 3/3/21.
//

#import <Foundation/Foundation.h>
#if __has_include(<MoPubSDK/MoPub.h>)
    #import <MoPubSDK/MoPub.h>
#else
    #import "MPNativeAdRenderer.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface ReferenceNativeAdRenderer : NSObject <MPNativeAdRenderer>

@end

NS_ASSUME_NONNULL_END
