//
//  ReferenceInlineAdapter.h
//  MoPub-Reference-Adapters
//
//  Created by Kelly Dun on 3/1/21.
//

#import <Foundation/Foundation.h>
#if __has_include(<MoPubSDK/MoPub.h>)
    #import <MoPubSDK/MoPub.h>
#else
    #import "MPInlineAdAdapter.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface ReferenceInlineAdapter : MPInlineAdAdapter <MPThirdPartyInlineAdAdapter>

@end

NS_ASSUME_NONNULL_END
