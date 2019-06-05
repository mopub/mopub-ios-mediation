//
//  IronSourceUtils.h
//
#import <Foundation/Foundation.h>
#if __has_include(<MoPubSDK/MoPub.h>)
#import <MoPubSDK/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
#import <MoPubSDKFramework/MoPub.h>
#else
#import "MPInterstitialCustomEvent.h"
#endif

@interface IronSourceUtils : NSObject

// IronSource Util methods.
+ (BOOL)isEmpty:(id)value;
+ (NSError *)createErrorWith:(NSString *)description
                   andReason:(NSString *)reason
               andSuggestion:(NSString *)suggestion;
+ (NSString *)getMoPubSDKVersion;

@end

