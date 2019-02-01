//
//  IronSourceAdapterConfiguration.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <IronSource/IronSource.h>
#import "IronSourceAdapterConfiguration.h"

@implementation IronSourceAdapterConfiguration

#pragma mark - MPAdapterConfiguration

- (NSString *)adapterVersion {
    return @"6.8.0.0.4";
}

- (NSString *)biddingToken {
    return nil;
}

- (NSString *)moPubNetworkName {
    // ⚠️ Do not change this value! ⚠️
    return @"Ironsource";
}

- (NSString *)networkSdkVersion {
    return [IronSource sdkVersion];
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> *)configuration
                                  complete:(void(^)(NSError *))complete {
    // Nothing to initialize; complete immediately
    if (complete != nil) {
        complete(nil);
    }
}

@end
