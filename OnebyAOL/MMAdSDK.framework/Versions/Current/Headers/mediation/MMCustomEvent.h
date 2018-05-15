//
//  MMCustomEvent.h
//  MMAdSDK
//
//  Copyright (c) 2017 Millennial Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMCustomEventRequest.h"

/**
 * The base protocol for all custom event types.
 */
@protocol MMCustomEvent <NSObject>
@required

/**
 * The method should return an object that implements one of the protocol MMCustomEventBanner, MMCustomEventInterstitial or MMCustomEventNative.
 *
 * @param delegate          Custom event delegate, depend on type of custom event, it can be MMCustomEventBannerDelegate, MMCustomEventInterstitialDelegate, MMCustomEventNativeDelegate.
 */
+(id<MMCustomEvent>)customEventWithDelegate:(id<NSObject>)delegate;

/**
 * Load the ad from the client network.
 *
 * This is expected to be a synchronous operation which blocks until
 * content is guaranteed as retrieved. As a result this method is *always* called off of the main thread.
 *
 * @param request           The request information which the Millennial SDK has collected, relevant to the
 *                          ad request.
 * @param mediationExtras   The dictionary contains configuration data for 3rd party ad network.
 */
-(void)getAd:(MMCustomEventRequest *)request mediationExtras:(NSDictionary<NSString *, id> *)mediationExtras;

/**
 *  Used to halt the loading of an ad from the client network.
 *
 * This method is invoked when there is a timeout or other error/constraint on the Millennial SDK side which prevents
 * the client SDK from continuing its loading. This method is required to be implemented and make a best effort to stop
 * the client SDK from loading an ad, to avoid reporting discrepanices.
 */
-(void)stopAdLoading;

@end
