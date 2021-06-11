//
//  ReferenceNetworkSDK.h
//  MoPub-Reference-Adapters
//
//  Created by Kelly Dun on 3/1/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReferenceNetworkSDK : NSObject

/// Inidcates whether the reference network SDK has been initialized.
@property (class, readonly) BOOL isInitialized;

/// Advanced Bidding token.
@property (class, readonly, copy) NSString *token;

/// Reference Network SDK version.
@property (class, readonly, copy) NSString *version;

/// Initializes the reference SDK.
+ (void)initializeNetworkWithPlacementIds:(NSArray<NSString *> * _Nullable)placements
                               completion:(void(^)(void))complete;

@end

NS_ASSUME_NONNULL_END
