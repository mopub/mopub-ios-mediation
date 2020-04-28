//
//  PangleAdapterConfiguration.h
//  BUADDemo
//
//  Created by Pangle on 2019/8/9.
//  Copyright © 2019 Pangle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPBaseAdapterConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PangleRenderMethod) {
    PangleRenderMethodOrigin    = 1,    // native express
    PangleRenderMethodDynamic   = 2,    // general
};

@interface PangleAdapterConfiguration :MPBaseAdapterConfiguration

@property (nonatomic, copy, readonly) NSString * adapterVersion;
@property (nonatomic, copy, readonly) NSString * biddingToken;
@property (nonatomic, copy, readonly) NSString * moPubNetworkName;
@property (nonatomic, copy, readonly) NSString * networkSdkVersion;
/// @required   render Method
@property (nonatomic, assign) PangleRenderMethod renderMethod;

+ (void)updateInitializationParameters:(NSDictionary *)parameters;

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> * _Nullable)configuration complete:(void(^ _Nullable)(NSError * _Nullable))complete;
@end

NS_ASSUME_NONNULL_END
