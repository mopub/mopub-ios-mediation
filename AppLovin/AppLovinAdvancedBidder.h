//
//  AppLovinAdvancedBidder.h
//
//
//  Created by Thomas So on 5/22/18.
//
//

#import <Foundation/Foundation.h>

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
    #import <MoPubSDKFramework/MoPub.h>
#else
    #import "MPAdvancedBidder.h"
#endif

/**
 * Include this class to use advanced bidding from AppLovin.
 */
@interface AppLovinAdvancedBidder : NSObject<MPAdvancedBidder>

@end
