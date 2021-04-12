//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OguryAds/OguryAds.h>

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
    #import <MoPubSDK/MoPub.h>
#else
    #import "MPBaseAdapterConfiguration.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface NSError (Ogury)

+ (NSError *)ogy_MoPubErrorFromOguryError:(OguryAdsErrorType)oguryError;

@end

NS_ASSUME_NONNULL_END
