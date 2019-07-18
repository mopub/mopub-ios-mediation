//
//  IronSourceUtils.m
//  

#import "IronSourceUtils.h"
#if __has_include("MoPub.h")
#import "MPLogging.h"
#import "MoPub.h"
#endif

@implementation IronSourceUtils

#pragma mark Utils Methods

+ (BOOL)isEmpty:(id)value {
    return value == nil || [value isKindOfClass:[NSNull class]] ||
    ([value respondsToSelector:@selector(length)] && [(NSString *)value length] == 0) ||
    ([value respondsToSelector:@selector(length)] && [(NSData *)value length] == 0) ||
    ([value respondsToSelector:@selector(count)] && [(NSArray *)value count] == 0);
}

+ (NSError *)createErrorWith:(NSString *)description
                   andReason:(NSString *)reason
               andSuggestion:(NSString *)suggestion {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey : NSLocalizedString(description, nil),
                               NSLocalizedFailureReasonErrorKey : NSLocalizedString(reason, nil),
                               NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(suggestion, nil)
                               };
    
    return [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:userInfo];
}

+ (NSString *)getMoPubSdkVersion {
    NSString * version = @"";
    NSString *sdkVersion = [[MoPub sharedInstance] version];
    @try{
        version = [sdkVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    }
    @catch (NSException *exception){
        NSLog(@"Unable to parse MoPub SDK version");
        version = @"";
    }
    return version;
}

@end
