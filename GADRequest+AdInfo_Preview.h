//
//  GADRequest+AdInfo.h
//  Google Mobile Ads SDK
//
//  Copyright 2018 Google LLC. All rights reserved.
//

#import <GoogleMobileAds/GADRequest.h>
#import "GADAdInfo_Preview.h"

/// Ad info request extension.
@interface GADRequest (AdInfo)

/// Ad info that represents an ad request and response. The SDK will render this ad and ignore all
/// other targeting information set on this request. This feature is only available for whitelisted
/// accounts.
@property(nonatomic, copy, nullable) GADAdInfo *adInfo;

@end
