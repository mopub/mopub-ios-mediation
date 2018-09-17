#import <Foundation/Foundation.h>

#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
#import <MoPubSDKFramework/MoPub.h>
#else
#import "MPAdvancedBidder.h"
#endif

@interface TapjoyAdvancedBidder: NSObject<MPAdvancedBidder>
// MPAdvancedBidder
@property (nonatomic, copy, readonly) NSString * _Nonnull creativeNetworkName;
@property (nonatomic, copy, readonly) NSString * _Nonnull token;
@end
