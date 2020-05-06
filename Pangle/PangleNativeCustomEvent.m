//
//  PangleNativeCustomEvent.m
//  BUDemo
//
//  Created by Pangle on 2020/1/8.
//  Copyright © 2020 Pangle. All rights reserved.
//

#import "PangleNativeCustomEvent.h"
#import "PangleNativeAdAdapter.h"
#import <BUAdSDK/BUAdSDKManager.h>
#import <BUAdSDK/BUNativeAd.h>

#if __has_include("MoPub.h")
    #import "MoPub.h"
    #import "MPNativeAd.h"
    #import "MPLogging.h"
    #import "MPNativeAdError.h"
#endif

@interface PangleNativeCustomEvent () <BUNativeAdDelegate>
@property (nonatomic, strong) BUNativeAd *nativeAd;
@end
 
@implementation PangleNativeCustomEvent

- (BUNativeAd *)nativeAd {
    if (_nativeAd == nil) {
        BUAdSlot *slot = [[BUAdSlot alloc] init];
        slot.AdType = BUAdSlotAdTypeFeed;
        slot.position = BUAdSlotPositionTop;
        slot.imgSize = [BUSize sizeBy:BUProposalSize_Feed690_388];
        slot.isSupportDeepLink = YES;
        
        _nativeAd = [[BUNativeAd alloc] initWithSlot:slot];
        _nativeAd.delegate = self;
    }
    return _nativeAd;
}

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    BOOL hasAdMarkup = adMarkup.length > 0;
    NSString *ritStr;
    ritStr = [info objectForKey:@"ad_placement_id”"];
    if (ritStr == nil) {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:@{NSLocalizedDescriptionKey: @"Invalid Pangle placement ID"}];
        [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:error];
        return;
    }
    
    self.nativeAd.adslot.ID = ritStr;
    if (hasAdMarkup) {
        [self.nativeAd setMopubAdMarkUp:adMarkup];
    }else{
        [self.nativeAd loadAdData];
    }
}

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info {
    [self.nativeAd loadAdData];
}

#pragma mark - BUNativeAdDelegate

- (void)nativeAd:(BUNativeAd *)nativeAd didFailWithError:(NSError *)error {
    [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)nativeAdDidLoad:(BUNativeAd *)nativeAd {
    PangleNativeAdAdapter *adapter = [[PangleNativeAdAdapter alloc] initWithBUNativeAd:nativeAd];
    MPNativeAd *mp_nativeAd = [[MPNativeAd alloc] initWithAdAdapter:adapter];
    [self.delegate nativeCustomEvent:self didLoadAd:mp_nativeAd];
}

@end
