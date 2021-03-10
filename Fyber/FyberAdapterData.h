//
//  FyberAdapterData.h
//  FyberMarketplaceTestApp
//
//  Created by Fyber on 10/03/2021.
//  Copyright © 2021 Fyber. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@class CLLocation;

/**
 *  @brief IASDK Mopub Adapter Data
 *
 *  @discussion Use to pass location and keywords to Mopub Rewarded Video Custom Event Class.
 */
@interface FyberAdapterData : NSObject

@property (nonatomic, strong, nullable) CLLocation *location;

/**
 *  @brief Key-words separated by comma.
 */
@property (nonatomic, strong, nullable) NSString *keywords;

@end
NS_ASSUME_NONNULL_END
