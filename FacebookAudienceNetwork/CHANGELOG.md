## Changelog
* 6.5.0.0
    * This version of the adapters has been certified with Facebook Audience Network 6.5.0 and MoPub 5.17.0.

* 6.4.1.1
    * Add `fullscreenAdAdapterAdWillPresent` and `fullscreenAdAdapterAdDidPresent` to notify publishers of the fullscreen ad show event. Remove `fullscreenAdAdapterAdWillAppear` and  `fullscreenAdAdapterAdDidAppear` as they are now deprecated by the MoPub iOS SDK.
    * Publishers must use v5.17.0 of the MoPub SDK at the minimum.

* 6.4.1.0
    * This version of the adapters has been certified with Facebook Audience Network 6.4.1 and MoPub 5.16.2.

* 6.4.0.0
    * This version of the adapters has been certified with Facebook Audience Network 6.4.0 and MoPub 5.16.2.
    * **Update**: Facebook has retroactively withdrawn this SDK version from production. Publishers should use v6.4.1.0 of the adapters and get v6.4.1 of the Facbook Audience Network.

* 6.3.1.0
    * This version of the adapters has been certified with Facebook Audience Network 6.3.1 and MoPub 5.16.2.

* 6.3.0.0
    * This version of the adapters has been certified with Facebook Audience Network 6.3.0 and MoPub 5.16.1.

* 6.2.1.1
    * Add support for `fullscreenAdAdapterAdWillDismiss` when a fullscreen creative is about to close. Publishers must use v5.16.1 of the MoPub SDK at the minimum.

* 6.2.1.0
    * This version of the adapters has been certified with Facebook Audience Network 6.2.1 and MoPub 5.15.0.

* 6.2.0.2
    * Replace imports using `MoPubSDKFramework` with `MoPubSDK`. No external impacts to publishers.

* 6.2.0.1
    * Add support for `fullscreenAdAdapterAdDidDismiss:` to signal that the fullscreen ad is closing and the state should be reset. To use this adapter version, you need v5.15.0 of the MoPub iOS SDK at the minimum.

* 6.2.0.0
    * This version of the adapters has been certified with Facebook Audience Network 6.2.0 and MoPub 5.14.1.

* 6.0.0.1
    * This version of the adapters has been certified with Facebook Audience Network 6.0.0 and MoPub 5.14.0.

* 6.0.0.0
    * This version of the adapters has been certified with Facebook Audience Network 6.0.0 and MoPub 5.13.1.

* 5.10.1.1
    * Fix adapter compiler warnings.

* 5.10.1.0
    * This version of the adapters has been certified with Facebook Audience Network 5.10.1 and MoPub 5.13.1.

* 5.10.0.0
    * This version of the adapters has been certified with Facebook Audience Network 5.10.0 and MoPub 5.13.0.

* 5.9.0.1
    * Refactor non-native adapter classes to use the new consolidated API from MoPub.
    * To use this and newer adapter versions, you must use MoPub 5.13.0 or newer.

* 5.9.0.0
    * This version of the adapters has been certified with Facebook Audience Network 5.9.0 and MoPub 5.12.1.

* 5.8.0.0
    * This version of the adapters has been certified with Facebook Audience Network 5.8.0 and MoPub 5.11.0.

* 5.7.1.0
    * This version of the adapters has been certified with Facebook Audience Network 5.7.1.

* 5.7.0.0
    * This version of the adapters has been certified with Facebook Audience Network 5.7.0.

* 5.6.1.0
    * This version of the adapters has been certified with Facebook Audience Network 5.6.1.

* 5.6.0.0
    * This version of the adapters has been certified with Facebook Audience Network 5.6.0.
    * Add support for [native banner](https://developers.facebook.com/docs/audience-network/ios-native-banner/). Refer to the [Mediate Facebook page](https://developers.mopub.com/publishers/mediation/networks/facebook/) for integration instructions.

* 5.5.1.0
    * This version of the adapters has been certified with Facebook Audience Network 5.5.1 and is compatible with iOS 13.

* 5.5.0.1
    * Remove native video handling code and associated comments. Publishers can enable/disable video on the Facebook Audience Network dashboard.

* 5.5.0.0
    * This version of the adapters has been certified with Facebook Audience Network 5.5.0.

* 5.4.0.1
    * Fix banner size passing as part of ad format unification. This version is only compatible with the 5.8.0+ release of the MoPub SDK.

* 5.4.0.0
    * This version of the adapters has been certified with Facebook Audience Network 5.4.0.

* 5.3.2.1
    * Fix mapping for native ads that causes invalid argument exceptions due to invalid URLs. 
    * Update the initialilization logic in `FacebookAdapterConfiguration` to have completion callbacks.

* 5.3.2.0
    * This version of the adapters has been certified with Facebook Audience Network 5.3.2.
    * Removed dependency on `CoreLocation.framework`.

* 5.3.0.0
    * This version of the adapters has been certified with Facebook Audience Network 5.3.0.

* 5.2.0.1
    * Nil out the 1-hour expiration timer to release memory after a rewarded video has been shown.

* 5.2.0.0
    * This version of the adapters has been certified with Facebook Audience Network 5.2.0. 
    * Add `FacebookNativeAdRenderer` to render native ads using [predefined layouts from Facebook Audience Network](https://developers.facebook.com/docs/audience-network/ios/nativeadtemplate). You won't need to use a custom layout. Simply pass your `MPStaticNativeAdRendererSettings` to the `FacebookNativeAdRenderer`'s `rendererConfigurationWithRendererSettings:` call, and register that configuration with the ad request.
     * Replace `FBAdChoicesView` with `FBAdOptionsView`.

* 5.1.0.4
    * Adapters now fetch only the core MoPub iOS SDK (excluding viewability SDKs). Publishers wishing to integrate viewability should fetch the `mopub-ios-sdk` dependency in their own Podfile.

* 5.1.0.3
    * Update Adapter Version in FacebookAdapterConfiguration to accommodate podspec changes for Unity releases.
    
* 5.1.0.2
    * Move source_files to the `Network` subspec. 

* 5.1.0.1
    * **Note**: This version is only compatible with the 5.5.0+ release of the MoPub SDK.
    * Add the `FacebookAdapterConfiguration` class to: 
         * pre-initialize the Facebook Audience Netwok SDK during MoPub SDK initialization process
         * store adapter and SDK versions for logging purpose
         * return the Advanced Biding token previously returned by `FacebookAdvancedBidder.m`
    * Streamline adapter logs via `MPLogAdEvent` to make debugging more efficient. For more details, check the [iOS Initialization guide](https://developers.mopub.com/docs/ios/initialization/) and [Writing Custom Events guide](https://developers.mopub.com/docs/ios/custom-events/).

* 5.1.0.0
    * This version of the adapters has been certified with Facebook Audience Network 5.1.0.

* 5.0.1.0
    * This version of the adapters has been certified with Facebook Audience Network 5.0.1.

* 5.0.0.0
    * This version of the adapters has been certified with Facebook Audience Network 5.0.0.
    * Remove calls to disableAutoRefresh for banner (deprecated by Facebook).
    * Enable publishers to use the advertiser name asset as it is a required asset starting in Facebook 4.99.0 (https://developers.facebook.com/docs/audience-network/guidelines/native-ads#name).

* 4.99.2.1
    * Align MoPub's interstitial impression tracking to that of Facebook Audience Network.
        * Automatic impression tracking is disabled, and Facebook's `interstitialAdWillLogImpression` is used to fire MoPub impressions.

* 4.99.2.0
    * This version of the adapters has been certified with Facebook Audience Network 4.99.2.

* 4.99.1.0
    * This version of the adapters has been certified with Facebook Audience Network 4.99.1 for all ad formats. Publishers must use the latest native ad adapters for compatibility.

* 4.99.0.0
    * This version of the adapters has been certified with Facebook Audience Network 4.99.0 for all ad formats except native ads.
    * This version of the Audience Network SDK deprecates several existing native ad APIs used in the existing adapters. As a result, the current native ad adapters are not compatible. Updates require changes from the MoPub SDK as well, so we are planning to release new native ad adapters along with our next SDK release. Publishers integrated with Facebook native ads are recommended to use the pre-4.99.0 SDKs until the updates are available.

* 4.28.1.3
    * Update adapters to remove dependency on MPInstanceProvider
    * Update adapters to be compatible with MoPub iOS SDK framework

* 4.28.1.2
    * This version of the adapters has been certified with Facebook Audience Network 4.28.1.
    * Enables advanced bidding for all adapters and adds FacebookAdvancedBidder.
    
* 4.28.1.1
    * This version of the adapters has been certified with Facebook Audience Network 4.28.1.
    * Rename delegate method rewardedVideoAdComplete to rewardedVideoAdVideoComplete per Facebook Audience Network change.
* 4.28.1.0
    * This version of the adapters has been certified with Facebook Audience Network 4.28.1.

  * 4.28.0.1
    * This version of the adapters has been certified with Facebook Audience Network 4.28.0.
	* Removed star rating from the native ad adapter since it has been deprecated by Facebook.

  * 4.28.0.0
    * This version of the adapters has been certified with Facebook Audience Network 4.28.0.
    * Updated native adapters to handle the use-case of empty clickable views
    * Updated Rewarded Video header files to be consistent with the rest of the header files

  * 4.27.0.1
    * This version of the adapters has been certified with Facebook Audience Network 4.27.0.

  * Initial Commit
  	* Adapters moved from [mopub-iOS-sdk](https://github.com/mopub/mopub-ios-sdk) to [mopub-iOS-mediation](https://github.com/mopub/mopub-iOS-mediation/)
