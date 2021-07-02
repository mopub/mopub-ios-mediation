//
//  ReferenceFullscreenAdapter.h
//  MoPub-Reference-Adapters
//
//  Created by Kelly Dun on 3/2/21.
//

#import <Foundation/Foundation.h>
#if __has_include(<MoPubSDK/MoPub.h>)
    #import <MoPubSDK/MoPub.h>
#else
    #import "MPFullscreenAdAdapter.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface ReferenceFullscreenAdapter : MPFullscreenAdAdapter <MPThirdPartyFullscreenAdAdapter>

@end

NS_ASSUME_NONNULL_END
