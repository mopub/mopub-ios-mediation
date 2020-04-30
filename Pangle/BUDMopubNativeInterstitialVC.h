//
//  BUDMopubNativeInterstitialVC.h
//  BUDemo
//
//  Created by bytedance on 2020/4/24.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BUAdSDK/BUNativeAd.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BUDMopubNativeInterstitialVCDelegate <NSObject>

- (void)nativeInterstitialAdWillClose:(BUNativeAd *)nativeAd;
- (void)nativeInterstitialAdDidClose:(BUNativeAd *)nativeAd;

@end

@interface BUDMopubNativeInterstitialVC : UIViewController

- (void)refreshUIWithAd:(BUNativeAd *_Nonnull)nativeAd;
- (BOOL)showAdFromRootViewController:(UIViewController *)rootViewController delegate:(id <BUDMopubNativeInterstitialVCDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
