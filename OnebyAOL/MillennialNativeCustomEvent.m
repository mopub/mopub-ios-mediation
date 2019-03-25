//
//  MillennialNativeCustomEvent.m
//
//  Copyright (c) 2015 Millennial Media, Inc. All rights reserved.
//

#import "MillennialNativeCustomEvent.h"
#import "MillennialNativeAdAdapter.h"
#if __has_include("MoPub.h")
    #import "MPLogging.h"
    #import "MPNativeAdError.h"
#endif
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
                MPLogInfo(@"Millennial adapter version: %@", self.version);
            }
        } else {
            self = nil; // No support below minimum OS.
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
        [delegate nativeCustomEvent:self didFailToLoadAdWithError:error];
        
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        return;
    }

    NSString *placementId = info[kMoPubMMAdapterAdUnit];
    if (placementId == nil) {
        NSError *error = [NSError errorWithDomain:MMSDKErrorDomain
                                             code:MMSDKErrorServerResponseNoContent
                                         userInfo:@{
                                                    NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Millennial received no placement ID. Request failed."]
                                                    }];
        [delegate nativeCustomEvent:self didFailToLoadAdWithError:error];
        
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);

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
    
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getAdNetworkId]);
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
    MillennialNativeAdAdapter *adapter = [[MillennialNativeAdAdapter alloc] initWithMMNativeAd:self.nativeAd];
    MPNativeAd *mpNativeAd = [[MPNativeAd alloc] initWithAdAdapter:adapter];
    [self.delegate nativeCustomEvent:self didLoadAd:mpNativeAd];
    
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

- (void)nativeAd:(MMNativeAd *)ad requestDidFailWithError:(NSError *)error {
    [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:MPNativeAdNSErrorForNoInventory()];
    
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
}

- (NSString *) getAdNetworkId {
    return kMoPubMMAdapterAdUnit;
}


@end
