//
//  MintegralAdapterConfiguration.m
//  MoPubSampleApp
//
//  Created by Damon on 2019/11/12.
//  Copyright © 2019 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MintegralAdapterConfiguration.h"
#import <MTGSDK/MTGSDK.h>
#import <MTGSDKBidding/MTGBiddingSDK.h>
#import <MoPub.h>
#import "MintegralAdapterHelper.h"
@interface MintegralAdapterConfiguration()

@end

@implementation MintegralAdapterConfiguration

#pragma mark - MPAdapterConfiguration

- (NSString *)adapterVersion {
    return MintegralAdapterVersion;
}

- (NSString *)biddingToken {
//    return @"";
    return [MTGBiddingSDK buyerUID];
}

- (NSString *)moPubNetworkName {
    return @"Mintegral";
}

- (NSString *)networkSdkVersion {
    return MTGSDKVersion;
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *,id> *)configuration complete:(void (^)(NSError * _Nullable))complete{
    NSLog(@"initializeNetworkWithConfiguration");
//    NSLog(@"buyeruid: %@", self.biddingToken);
    
    NSString* appId = [configuration objectForKey:@"appId"];
    NSString* appKey = [configuration objectForKey:@"appKey"];
    
    NSString *errorMsg = nil;
    if (!appId) errorMsg = @"Invalid Mintegral appId";
    if (!appKey) errorMsg = @"Invalid Mintegral appKey";
    
    if (errorMsg) {
        
        NSError *error = [NSError errorWithDomain:kMintegralErrorDomain code:MPErrorNetworkConnectionFailed userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
        if (complete != nil) {
            complete(error);
        }
        
        return;
        
    }

    if (![MintegralAdapterHelper isSDKInitialized]) {

        [MintegralAdapterHelper setGDPRInfo:configuration];
        [[MTGSDK sharedInstance] setAppID:appId ApiKey:appKey];
        [MintegralAdapterHelper sdkInitialized];
    }
    if (complete != nil) {
        complete(nil);
    }
    
}


@end
