#import <Foundation/Foundation.h>
#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
#import <MoPubSDKFramework/MoPub.h>
#else
#import "MoPub.h"
#endif

@class VASCreativeInfo;

@interface MPVerizonRewardedVideoCustomEvent : MPRewardedVideoCustomEvent

@property (nonatomic, readonly, nullable) VASCreativeInfo* creativeInfo;

@end
