//
//  PangleNativeCustomEvent.h
//  BUDemo
//
//  Created by Pangle on 2020/1/8.
//  Copyright © 2020 Pangle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mopub-ios-sdk/MPNativeAdAdapter.h>
#import <mopub-ios-sdk/MPNativeCustomEvent.h>

NS_ASSUME_NONNULL_BEGIN

@interface PangleNativeCustomEvent : MPNativeCustomEvent 

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup;
- (void)requestAdWithCustomEventInfo:(NSDictionary *)info;

@end

NS_ASSUME_NONNULL_END
