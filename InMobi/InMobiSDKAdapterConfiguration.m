//
//  InMobiAdvancedBiddingAdapterConfiguration.h
//  InMobiMopubAdvancedBiddingPlugin
//  InMobi
//
//  Created by Akshit Garg on 24/11/20.
//  Copyright © 2020 InMobi. All rights reserved.
//

#import "InMobiSDKAdapterConfiguration.h"

#if __has_include("MoPub.h")
    #import "MPLogging.h"
    #import "MPConstants.h"
#endif

#import <InMobiSDK/IMSdk.h>
#import "IMMPABConstants.h"

#define InMobiMopubAdvancedBiddingPluginVersion @"9.1.0.0"
#define MopubNetworkName @"inmobi"

@implementation InMobiSDKAdapterConfiguration

#pragma mark - MPAdapterConfiguration

- (NSString *)adapterVersion {
    return InMobiMopubAdvancedBiddingPluginVersion;
}

- (NSString *)biddingToken {
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    [paramsDict setObject:@"c_mopub" forKey:@"tp"];
    [paramsDict setObject:MP_SDK_VERSION forKey:@"tp-ver"];
    return [IMSdk getTokenWithExtras:paramsDict andKeywords:nil];
}

- (NSString *)moPubNetworkName {
    return MopubNetworkName;
}

- (NSString *)networkSdkVersion {
    return [IMSdk getVersion];
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> *)configuration complete:(void(^)(NSError *))complete {
    complete(nil);
}

@end
