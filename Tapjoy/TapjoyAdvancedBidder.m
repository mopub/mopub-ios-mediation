#import "TapjoyAdvancedBidder.h"
#import <Tapjoy/Tapjoy.h>
#if __has_include("MoPub.h")
#import "MoPub.h"
#endif

@implementation TapjoyAdvancedBidder

#pragma mark - Initialization

+ (void)initialize {
    NSLog(@"Initialized Tapjoy advanced bidder");
}

#pragma mark - MPAdvancedBidder

- (NSString *)creativeNetworkName {
    return @"tapjoy";
}

- (NSString *)token {
    NSString *token = [Tapjoy getUserToken];
    return (token.length > 0 ? token : @"1");
}

@end
