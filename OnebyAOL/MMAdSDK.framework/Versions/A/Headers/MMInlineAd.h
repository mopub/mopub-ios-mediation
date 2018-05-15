//
//  MMInlineAd.h
//  MMAdSDK
//
//  Copyright (c) 2015 Millennial Media, Inc. All rights reserved.
//

#ifndef MMInlineAd_Header_h
#define MMInlineAd_Header_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "MMAd.h"

/**
 *  A special value used to disable the refresh interval for inline ads.
 */
extern const NSTimeInterval MMInlineDisableRefresh;

@class MMRequestInfo;
@class MMInlineAd;

NS_ASSUME_NONNULL_BEGIN

/**
 * The delegate of an MMInlineAd object. This delegate provides information about the relevant placement and ad activity
 * that an application may need to respond to.
 */
@protocol MMInlineDelegate <NSObject>
@required
/**
 * The view controller over which modal content will be displayed.
 *
 * @return A view controller that is used for presenting modal content.
 */
- (UIViewController *)viewControllerForPresentingModalView;

@optional
/**
 * Callback indicating that an ad request has succeeded.
 *
 * This method is always called on the main thread.
 *
 * @param ad The ad placement which was successfully requested.
 */
-(void)inlineAdRequestDidSucceed:(MMInlineAd *)ad;

/**
 * Callback indicating that ad content failed to load or render.
 *
 * This method is always called on the main thread.
 *
 * @param ad The ad placement for which the request failed.
 * @param error The error indicating the failure.
 */
-(void)inlineAd:(MMInlineAd *)ad requestDidFailWithError:(NSError*)error;

/**
 *  Callback indicating that the user has interacted with ad content.
 *
 * This callback should not be used to adjust the contents of your application -- it should
 * be used only for the purposes of reporting.
 *
 * This method is always called on the main thread.
 *
 * @param ad The ad placement which was tapped.
 */
-(void)inlineAdContentTapped:(MMInlineAd *)ad;

/**
 * Callback indicating that the ad is preparing to be resized.
 *
 * This method is always called on the main thread.
 *
 * @param ad The ad placement.
 * @param frame The size and location of the ad placement.
 * @param isClosingResize This flag indicates the resize close button was tapped, causing a resize to the default/original size.
 */
-(void)inlineAd:(MMInlineAd *)ad willResizeTo:(CGRect)frame isClosing:(BOOL)isClosingResize;

/**
 * Callback indicating the ad has finished resizing.
 *
 * This method is always called on the main thread.
 *
 * @param ad The ad placement.
 * @param frame The size and location of the ad placement.
 * @param isClosingResize This flag indicates the resize close button was tapped, causing a resize to the default/original size.
 */
-(void)inlineAd:(MMInlineAd *)ad didResizeTo:(CGRect)frame isClosing:(BOOL)isClosingResize;

/**
 * Callback indicating that the ad is preparing to present a modal view.
 *
 * This method is always called on the main thread.
 *
 * @param ad The ad placement.
 */
-(void)inlineAdWillPresentModal:(MMInlineAd *)ad;

/**
 * Callback indicating that the ad has presented a modal view.
 *
 * This method is always called on the main thread.
 *
 * @param ad The ad placement.
 */
-(void)inlineAdDidPresentModal:(MMInlineAd *)ad;

/**
 * Callback indicating that the ad is preparing to dismiss a modal view.
 *
 * This method is always called on the main thread.
 *
 * @param ad The ad placement.
 */
-(void)inlineAdWillCloseModal:(MMInlineAd *)ad;

/**
 * Callback indicating that the ad has dismissed a modal view.
 *
 * This method is always called on the main thread.
 *
 * @param ad The ad placement.
 */
-(void)inlineAdDidCloseModal:(MMInlineAd *)ad;

/**
 * Callback invoked prior to the application going into the background due to a user interaction with an ad.
 *
 * This method is always called on the main thread.
 *
 * @param ad The ad placement.
 */
-(void)inlineAdWillLeaveApplication:(MMInlineAd *)ad;

/**
 * Callback invoked when an abort for an in-progress request successfully stops processing.
 *
 * This method is always called on the main thread.
 *
 * @param ad The ad placement.
 */
-(void)inlineAdAbortDidSucceed:(MMInlineAd *)ad;

/**
 * Callback invoked when an abort for an in-progress request fails.
 *
 * Note that depending on the reason for abort failure, the relevant delegate callback 
 * (inlineAdRequestDidSucceed: or inlineAd:requestDidFailWithError:) is invoked *before*
 * this method.
 *
 * This method is always called on the main thread.
 *
 * @param ad The ad placement.
 * @param error Error indicating the manner in which the abort failed.
 */
-(void)inlineAd:(MMInlineAd *)ad abortDidFailWithError:(NSError*)error;

@end

/**
 * Sizing constants for inline ads.
 */
typedef NS_ENUM(NSInteger, MMInlineAdSize) {
    /** An inline placement sized for a 320x50 banner ad. */
    MMInlineAdSizeBanner = 0,
    /** An inline placement sized for a 320x100 banner ad. */
    MMInlineAdSizeLargeBanner,
    /** An inline placement sized for a 300x250 rectangle ad. */
    MMInlineAdSizeMediumRectangle,
    /** An inline placement sized for a 468x60 full size banner ad. */
    MMInlineAdSizeFullBanner,
    /** An inline placement sized for a 728x90 leaderboard ad. */
    MMInlineAdSizeLeaderboard,
    /** An inline placement sized for a flexible (device) width and height. Height may vary by device, orientation, or ad network. */
    MMInlineAdSizeFlexible
};

/**
 * The class representing an "inline" advertisment. Inline ads consist of ads which are meant to be displayed
 * alongside other, native content, such as banners or other inserted views.
 */
@interface MMInlineAd : MMAd

/**
 * Requests a bid, asynchronously, using information supplied in the mmAdRequest dictionary.
 *
 * @param placementId The ad's placement ID.
 * @param adSize The size of the banner to request.
 * @param requestInfo Additional targeting information relevant to this individual request. This value may be `nil`.
 * @param completion The block to execute after the request finishes.
 */
+ (void)requestBidForPlacementId:(nonnull NSString*)placementId
                          adSize:(MMInlineAdSize)adSize
                     requestInfo:(nullable MMRequestInfo*)requestInfo
                      completion:(nullable void (^)(NSString * _Nullable bid, NSError * _Nullable error))completion;

/**
 * Initializes an inline placement. This method must be invoked from the main thread.
 *
 * @param placementId The ad's placement ID.
 * @param adSize The size of the banner to request.
 */
-(nullable instancetype)initWithPlacementId:(NSString*)placementId adSize:(MMInlineAdSize)adSize;

/**
 * Initializes an inline placement with an explicitly defined size. This method must be invoked from the main thread.
 *
 * @param placementId The ad's placement ID.
 * @param freeformSize  The explicit size of the placement to request.
 */
-(nullable instancetype)initWithPlacementId:(NSString*)placementId size:(CGSize)freeformSize;

/**
 * The minimum refresh interval, in seconds, for the ad.
 *
 * The refreshInterval may not be set to a value less than the minimumRefreshInterval.
 */
+(NSTimeInterval)minimumRefreshInterval;

/**
 * Requests an ad, asynchronously, using information supplied in the mmAdRequest dictionary.
 *
 * If no refreshInterval has been set, a single, non-refreshing ad request will be made.
 * If there is a positive refreshInterval, ads will automatically refresh using the interval.
 *
 * @param requestInfo Additional targeting information relevant to this individual request. This value may be `nil`.
 */
-(void)request:(nullable MMRequestInfo*)requestInfo;

/**
 * Attempts to cancel a currently pending request.
 *
 * Note that there is not a guarantee that this method will result in canceling a pending request, or that
 * a request may be canceled for a reason other than a user-initiated abort. 
 *
 * Additonally, in certain timing-dependent multithread scenarios, an abort may be requested 'too late'.
 * This would be where a request has succeeded/failed and is being processed on the appropriate thread,
 * while a different thread requests an 'abort'. In this case the abort message is ignored and none of 
 * the abort callbacks are invoked.
 *
 * See the documentation for inlineAd:abortDidFailWithError: for details on how this method affects callbacks.
 */
-(void)abort;

/**
 * The view containing the ad. This view should not have its subviews modified, or be styled, in any way. 
 * 
 * The MMInlineAd view's bounds are specificed by the size passed in via the constructor.
 */
@property (nonatomic, readonly) UIView* view;

/**
 * The auto-refresh interval for the ad, in seconds. Auto-refreshing is disabled by default.
 *
 * Setting refreshInterval to a positive value starts auto-refresh for subsequent requests.
 * If the value is already non-zero, the new value takes precedence after the next request.
 *
 * If set to a (positive) value lower than the minimumRefreshInterval, the minimumRefreshInterval
 * is used.
 *
 * Refresh behavior is automatically disabled when a view is not visible onscreen or while
 * the app is suspended, and automatically resumes when the view becomes visible or the app
 * becomes active.
 *
 * Setting the `MMInlineDisableRefresh` value disables refresh behavior.
 */
@property (nonatomic, assign) NSTimeInterval refreshInterval;

/**
 * The background color for requested space not filled by the ads.
 * 
 * If this value is not set, it defaults to `[UIColor clearColor]`.
 */
@property (nonatomic, readwrite) UIColor* flexibleBackgroundColor;

/**
 * The transition style for modal presentation of views presented by this inline ad.
 *
 * The default value is `UIModalTransitionStyleCoverVertical`. `UIModalTransitionStylePartialCurl`
 * is not supported and will instead set the default value.
 */
@property (assign, nonatomic) UIModalTransitionStyle modalTransitionStyle;

/**
 * The inline's delegate.
 */
@property (nonatomic, weak, nullable) id<MMInlineDelegate> delegate;

/**
 * The size of the currently retrieved ad. If no ad has been retrieved this value is `CGSizeZero`.
 *
 * Note that this value may differ from requestedSize.
 */
@property (nonatomic, readonly) CGSize size;

/**
 * The size which any ads will be requested to fit.
 *
 * This value is based on the size (or size constant) used at the time of initialization. In the
 * case of `MMInlineAdSizeFlexible`, it is the largest size which could be filled with a complete ad.
 */
@property (nonatomic, readonly) CGSize requestedSize;

@end

NS_ASSUME_NONNULL_END
#endif
