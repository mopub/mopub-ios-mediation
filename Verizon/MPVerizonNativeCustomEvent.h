#import <Foundation/Foundation.h>
#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
#import <MoPubSDKFramework/MoPub.h>
#else
#import "MoPub.h"
#endif

@class VASNativeAd;
@class VASCreativeInfo;

@interface MPVerizonNativeCustomEvent : MPNativeCustomEvent

@property (nonatomic, readonly) NSString *version;

@end

@interface MillennialNativeCustomEvent : MPVerizonNativeCustomEvent
@end
