## Changelog
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
