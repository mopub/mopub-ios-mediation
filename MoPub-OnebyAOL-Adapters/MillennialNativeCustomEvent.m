//
//  MillennialNativeCustomEvent.m
//
//  Copyright (c) 2015 Millennial Media, Inc. All rights reserved.
//

#import "MillennialNativeCustomEvent.h"
#import "MillennialNativeAdAdapter.h"
#import "MPNativeAdError.h"
#import "MPLogging.h"
#import "MMAdapterVersion.h"

#import <MMAdSDK/MMAdSDK.h>

static NSString *const kMoPubMMAdapterAdUnit = @"adUnitID";
static NSString *const kMoPubMMAdapterDCN = @"dcn";

@interface MillennialNativeCustomEvent() <MMNativeAdDelegate>

@property (nonatomic, strong) MMNativeAd *nativeAd;

@end

@implementation MillennialNativeCustomEvent

- (id)init {
    if (self = [super init]) {
        if([[UIDevice currentDevice] systemVersion].floatValue >= 8.0) {
            MMSDK *mmSDK = [MMSDK sharedInstance];
            if(![mmSDK isInitialized]) {
                MMAppSettings *appSettings = [[MMAppSettings alloc] init];
                [mmSDK initializeWithSettings:appSettings withUserSettings:nil];
                MPLogDebug(@"Millennial adapter version: %@", self.version);
            }
        }
    }
    return self;
}

-(void) dealloc {
    self.nativeAd.delegate = nil;
}

-(void)requestAdWithCustomEventInfo:(NSDictionary *)info {
    __strong __typeof__(self.delegate) delegate = self.delegate;
    MMSDK *mmSDK = [MMSDK sharedInstance];

    if (![mmSDK isInitialized]) {
        NSError *error = [NSError errorWithDomain:MMSDKErrorDomain
                                             code:MMSDKErrorNotInitialized
                                         userInfo:@{
                                                    NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Millennial adapter not properly intialized yet."]
                                                    }];
        MPLogError(@"%@", [error localizedDescription]);
        [delegate nativeCustomEvent:self didFailToLoadAdWithError:error];
        return;
    }

    MPLogDebug(@"Requesting Millennial native ad with event info %@.", info);

    NSString *placementId = info[kMoPubMMAdapterAdUnit];
    if (!placementId) {
        NSError *error = [NSError errorWithDomain:MMSDKErrorDomain
                                             code:MMSDKErrorServerResponseNoContent
                                         userInfo:@{
                                                    NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Millennial received no placement ID. Request failed."]
                                                    }];
        MPLogError(@"%@", [error localizedDescription]);
        [delegate nativeCustomEvent:self didFailToLoadAdWithError:error];
        return;
    }

    [mmSDK appSettings].mediator = @"MillennialNativeCustomEvent";
    if (info[kMoPubMMAdapterDCN]) {
        mmSDK.appSettings.siteId = info[kMoPubMMAdapterDCN];
    } else {
        mmSDK.appSettings.siteId = nil;
    }

    self.nativeAd = [[MMNativeAd alloc] initWithPlacementId:placementId supportedTypes:@[MMNativeAdTypeInline]];
    self.nativeAd.delegate = self;
    [self.nativeAd load:nil];
}

-(MMCreativeInfo*)creativeInfo
{
    return self.nativeAd.creativeInfo;
}

-(NSString*)version
{
    return kMMAdapterVersion;
}

#pragma mark - MMNativeAdDelegate

- (UIViewController *)viewControllerForPresentingModalView {
    return [UIApplication sharedApplication].delegate.window.rootViewController;
}

- (void)nativeAdRequestDidSucceed:(MMNativeAd *)ad {
    MPLogDebug(@"Millennial native ad loaded, creative ID %@", self.creativeInfo.creativeId);
    MillennialNativeAdAdapter *adapter = [[MillennialNativeAdAdapter alloc] initWithMMNativeAd:self.nativeAd];
    MPNativeAd *mpNativeAd = [[MPNativeAd alloc] initWithAdAdapter:adapter];
    [self.delegate nativeCustomEvent:self didLoadAd:mpNativeAd];
}

- (void)nativeAd:(MMNativeAd *)ad requestDidFailWithError:(NSError *)error {
    MPLogWarn(@"Millennial native ad did fail loading with error: %@.", error);
    [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:MPNativeAdNSErrorForNoInventory()];
}

@end
