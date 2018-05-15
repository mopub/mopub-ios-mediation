//
//  MMInterstitialAd.h
//  MMAdSDK
//
//  Copyright (c) 2015 Millennial Media, Inc. All rights reserved.
//

#ifndef MMInterstitialAd_Header_h
#define MMInterstitialAd_Header_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MMAd.h"

@class MMRequestInfo;
@class MMInterstitialAd;

NS_ASSUME_NONNULL_BEGIN

/**
 * The delegate of an MMInterstitial object. This delegate is responsible for notifications involving the ad which are
 * independent of advertiser-supplied interactions with the content that may be of interest to the developer.
 */
@protocol MMInterstitialDelegate <NSObject>
@optional
/**
 * Callback fired when an ad load (request and content processing) succeeds.
 *
 * This method is always invoked on the main thread.
 *
 * @param ad The ad placement which was successfully requested.
 */
-(void)interstitialAdLoadDidSucceed:(MMInterstitialAd*)ad;

/**
 * Callback fired when an ad load fails. The failure can be caused by failure to either retrieve or parse
 * ad content.
 *
 * This method is always invoked on the main thread.
 *
 * @param ad The ad placement for which the request failed.
 * @param error The error indicating the failure.
 */
-(void)interstitialAd:(MMInterstitialAd*)ad loadDidFailWithError:(NSError*)error;

/**
 *  Callback fired when an interstitial will be displayed, but before the display action begins.
 *  Note that the ad could still fail to display at this point.
 *
 * This method is always called on the main thread.
 *
 *  @param ad The interstitial which will display.
 */
-(void)interstitialAdWillDisplay:(MMInterstitialAd*)ad;

/**
 * Callback fired when the interstitial is displayed.
 * 
 * This method is always called on the main thread.
 *
 * @param ad The interstitial which is displayed.
 */
-(void)interstitialAdDidDisplay:(MMInterstitialAd*)ad;

/**
 * Callback fired when an attempt to show the interstitial fails.
 *
 * This method is always called on the main thread.
 *
 * @param ad The interstitial which failed to show.
 * @param error The error indicating the failure.
 */
-(void)interstitialAd:(MMInterstitialAd*)ad showDidFailWithError:(NSError*)error;

/**
 * Callback fired when an interstitial will be dismissed, but before the dismiss action begins.
 *
 * This method is always called on the main thread.
 *
 *  @param ad The interstitial which will be dismissed.
 */
-(void)interstitialAdWillDismiss:(MMInterstitialAd*)ad;

/**
 * Callback fired when the interstitial is dismissed.
 *
 * This method is always called on the main thread.
 *
 * @param ad The interstitial which was dismissed.
 */
-(void)interstitialAdDidDismiss:(MMInterstitialAd*)ad;

/**
 * Callback fired when the ad expires.
 *
 * After receiving this message, your app should call -load before attempting to display the interstitial.
 *
 * This method is always called on the main thread.
 *
 * @param ad The ad placement which expired.
 */
-(void)interstitialAdDidExpire:(MMInterstitialAd*)ad;

/**
 * Callback fired when the ad is tapped.
 *
 * This method is always called on the main thread.
 *
 * @param ad The ad placement which was tapped.
 */
-(void)interstitialAdTapped:(MMInterstitialAd*)ad;

/**
 * Callback invoked prior to the application going into the background due to a user interaction with an ad.
 *
 * This method is always called on the main thread.
 *
 * @param ad The ad placement.
 */
-(void)interstitialAdWillLeaveApplication:(MMInterstitialAd*)ad;

/**
 * Callback fired when a bid request succeeds.
 *
 * This method is always invoked on the main thread.
 *
 * @param ad The ad placement which was successfully requested.
 * @param bid The bid price returned by the bid request
 */
-(void)interstitialAdLoadDidSucceed:(MMInterstitialAd*)ad withBid:(NSString *)bid;

/**
 * Callback indicating that the bid request failed.
 *
 * This method is always called on the main thread.
 *
 * @param ad The ad placement for which the request failed.
 * @param error The error indicating the failure.
 */
-(void)interstitialAd:(MMInterstitialAd*)ad bidRequestDidFailWithError:(NSError*)error;

@end


/**
 * The MMInterstitialAd class represents an "interstitial" advertisment. Interstitial ads are displayed on their
 * own, as full-screen content presented modally.
 */
@interface MMInterstitialAd : MMAd

/**
 * The interstitial's delegate.
 */
@property (nonatomic, weak, nullable) id<MMInterstitialDelegate> delegate;

/**
 * Returns YES if the placement has loaded enough data to display the interstitial and NO
 * otherwise.
 */
@property (readonly, nonatomic) BOOL ready;

/**
 * Returns YES if the current creative is too old to be displayed and NO otherwise.
 *
 * If the interstitial indicates that it has expired, you should load the interstitial again before attempting to show it.
 */
@property (readonly, nonatomic) BOOL expired;

/**
 * The transition style for modal presentation of the interstitial.
 *
 * The default value is `UIModalTransitionStyleCoverVertical`. `UIModalTransitionStylePartialCurl` is not supported 
 * and will instead set the default value.
 */
@property (assign, nonatomic) UIModalTransitionStyle modalTransitionStyle;

/**
 * Requests a bid, asynchronously, using information supplied in the mmAdRequest dictionary.
 *
 * @param placementId The ad's placement ID.
 * @param requestInfo Additional targeting information relevant to this individual request. This value may be `nil`.
 * @param completion The block to execute after the request finishes.
 */
+ (void)requestBidForPlacementId:(nonnull NSString*)placementId
                     requestInfo:(nullable MMRequestInfo*)requestInfo
                      completion:(nullable void (^)(NSString * _Nullable bid, NSError * _Nullable error))completion;

/**
 * Asynchronously load interstitial content. This both retrieves the interstitial and loads its content offscreen.
 *
 * An ad is only considered 'ready for display' after it has fired its interstitialAdLoadDidSucceed: message.
 *
 * @param requestInfo Additional targeting information relevant to this individual request.
 */
-(void)load:(nullable MMRequestInfo*)requestInfo;

/**
 * Displays the interstitial ad.
 * 
 * If the ad is not ready for display (has not finished loading or is expired) this will invoke the corresponding
 * delegate callback and no other actions will be taken.
 *
 * @param controller The view controller from which the interstitial will be presented.
 */
-(void)showFromViewController:(UIViewController*)controller;

@end

NS_ASSUME_NONNULL_END

#endif
