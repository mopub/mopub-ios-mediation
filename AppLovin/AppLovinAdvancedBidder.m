//
//  AppLovinAdvancedBidder.m
//
//
//  Created by Thomas So on 5/22/18.
//
//

#import "AppLovinAdvancedBidder.h"

#if __has_include(<AppLovinSDK/AppLovinSDK.h>)
    #import <AppLovinSDK/AppLovinSDK.h>
#else
    #import "ALSdk.h"
#endif

@implementation AppLovinAdvancedBidder

- (NSString *)creativeNetworkName
{
    return @"applovin";
}

- (NSString *)token
{
    return [ALSdk shared].adService.bidToken;
}

@end
