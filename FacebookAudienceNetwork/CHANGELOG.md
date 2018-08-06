## Changelog
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
