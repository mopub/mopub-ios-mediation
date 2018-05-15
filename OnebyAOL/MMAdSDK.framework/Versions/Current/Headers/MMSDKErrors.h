//
//  MMSDKErrors.h
//  MMAdSDK
//
//  Copyright (c) 2015-17 Millennial Media, Inc. All rights reserved.
//

#ifndef MMAdSDK_Errors_h
#define MMAdSDK_Errors_h

#import <Foundation/Foundation.h>

#pragma mark - Error codes

extern NSString* __nonnull const MMSDKErrorDomain;

/** The errors which can be returned from the SDK in the `MMSDKErrorDomain`. */
typedef NS_ENUM(NSInteger, MMSDKError) {
    /** The server returned a response code indicating an error when an ad request was made. */
    MMSDKErrorServerResponseBadStatus = -1,
    /** The server did not return any valid content when a request was made. */
    MMSDKErrorServerResponseNoContent = -2,
    /** The native object is missing an advertiser required component. */
    MMSDKErrorNativeAdMissingRequiredComponent = -4,
    /** A request for this placement instance is already in progress. */
    MMSDKErrorPlacementRequestInProgress = -6,
    /** An interstitial ad is already loaded for this object. */
    MMSDKErrorInterstitialAdAlreadyLoaded = -7,
    /** The interstitial ad is expired and cannot be shown. */
    MMSDKErrorInterstitialAdExpired = -8,
    /** The interstitial ad is not ready to be shown. */
    MMSDKErrorInterstitialAdNotReady = -9,
    /** The interstitial ad content is not available to be shown. */
    MMSDKErrorInterstitialAdContentUnavailable = -10,
    /** The interstitial ad could not be presented because no view controller was provided. */
    MMSDKErrorInterstitialNoViewControllerProvided = -11,
    /** The interstitial ad could not be presented because it is already presented. */
    MMSDKErrorInterstitialViewControllerAlreadyPresented = -12,
    /** The video player set up failed. */
    MMSDKErrorVideoSetUpFailed = -13,
    /** 'Play' was sent to the video when it was not ready to play. */
    MMSDKErrorVideoNotReady = -14,
    /** The video player stalled. */
    MMSDKErrorVideoStalled = -15,
    /** Error during video playback. */
    MMSDKErrorVideoPlaybackFailed = -16,
    /** The video player timed out while loading a video. */
    MMSDKErrorVideoPlayerVideoLoadTimeout = -17,
    /** The video player timed out during preparation to play. */
    MMSDKErrorVideoPlayerVideoPrepareTimeout = -18,
    /** The VAST document did not contain a compatible media file. */
    MMSDKErrorVASTNoCompatibleMediaFile = -19,
    /** An error was encountered during VAST parsing. */
    MMSDKErrorVASTParserFailure = -20,
    /** The client SDK being mediated to experienced an error. */
    MMSDKErrorClientMediationError = -21,
    /** SDK requests have been disabled for this application. Please contact your Account Manager to resolve the issue. */
    MMSDKErrorRequestsDisabled = -22,
    /** The video player wasn't expanded when collapse called. */
    MMSDKErrorVideoPlayerNotExpanded = -23,
    /** The video player was areadly expanded. */
    MMSDKErrorVideoPlayerAlreadyExpanded = -24,
    /** There was no content available to load (no-fill) */
    MMSDKErrorNoFill = -25,
    /** There was a version mismatch between the request and the response. */
    MMSDKErrorVersionMismatch = -26,
    /** Downloading media for the ad failed. */
    MMSDKErrorMediaDownloadFailed = -27,
    /** A request operation timed out. */
    MMSDKErrorRequestTimeout = -28,
    /** The VAST document did not contain an impression. */
    MMSDKErrorVASTMissingRequiredImpression = -29,
    /** The VAST document contains more than 3 Wrapper tags. */
    MMSDKErrorVASTExcessiveWrappers = -30,
    /** The SDK has not yet been initialized. */
    MMSDKErrorNotInitialized = -31,
    /** A request abort was requested, but the request succeeded. */
    MMSDKErrorSuccessDuringAbort = -32,
    /** A request abort was requested, but the request failed due to an error. */
    MMSDKErrorFailureDuringAbort = -33,
    /** A request abort was requested, but no request was in progress. */
    MMSDKErrorNoRequestAbort = -34,
    /** A bid request yielded an error instead. */
    MMSDKErrorBidRequestFailure = -35,
    /** An internal error indicating required information was missing. */
    MMSDKErrorMissingInformation = -36,
    /** No registered adpater for the requested ad type. */
    MMSDKErrorMissingAdapter = -37,
    /** An ad requested an unload. */
    MMSDKErrorAdUnloaded = -38,
};

#endif


