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
    return [Tapjoy getUserToken];
}

@end
