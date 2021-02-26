//
//  GADAdInfo.h
//  Google Mobile Ads SDK
//
//  Copyright 2018 Google LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAdsDefines.h>
#import "GADQueryInfo_Preview.h"

/// Returns an identifier for the string representation of the ad returned from Google ads server.
/// This identifier is used to match with the query info used to make an ad request.
GAD_EXTERN NSString *_Nullable GADIdentifierFromAdString(NSString *_Nonnull adString);

/// Ad info that can be rendered by SDK.
@interface GADAdInfo : NSObject

/// Initializes with the query info used to make an ad request to a Google ad server and a string
/// representation of an ad returned from that Google ad server. Always call
/// GADIdentifierFromAdString to verify that the identifier in the adString matches with the
/// one in the query info provided in this initializer.
- (nullable instancetype)initWithQueryInfo:(nonnull GADQueryInfo *)queryInfo
                                  adString:(nonnull NSString *)adString;

@end
