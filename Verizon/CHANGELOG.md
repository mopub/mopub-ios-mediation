## Changelog
* 1.13.0.0
    * This version of the adapters has been certified with Verizon 1.13.0 and MoPub 5.17.0.

* 1.9.0.2
    * Add `fullscreenAdAdapterAdWillPresent` and `fullscreenAdAdapterAdDidPresent` to notify publishers of the fullscreen ad show event. Remove `fullscreenAdAdapterAdWillAppear` and  `fullscreenAdAdapterAdDidAppear` as they are now deprecated by the MoPub iOS SDK.
    * Publishers must use v5.17.0 of the MoPub SDK at the minimum.

* 1.9.0.1
    * Add support for `fullscreenAdAdapterAdWillDismiss` when a fullscreen creative is about to close. Publishers must use v5.16.1 of the MoPub SDK at the minimum.

* 1.9.0.0
    * This version of the adapters has been certified with Verizon 1.9.0 and MoPub 5.15.0.
    * Refactor native ad impression tracking logic. No external changes for publishers.
    * Native ads now require a disclaimer/sponsored text view.

* 1.8.1.2
    * Replace imports using `MoPubSDKFramework` with `MoPubSDK`. No external impacts to publishers.

* 1.8.1.1
    * Add support for `fullscreenAdAdapterAdDidDismiss:` to signal that the fullscreen ad is closing and the state should be reset. To use this adapter version, you need v5.15.0 of the MoPub iOS SDK at the minimum.
    * Remove `nativeVideoView` as part of MoPub's native video code removal. This does not impact Verizon. No external changes or actions rerquired for publishers. 

* 1.8.1.0
    * This version of the adapters has been certified with Verizon 1.8.1 and MoPub 5.14.1.

* 1.8.0.1
    * This version of the adapters has been certified with Verizon 1.8.0 and MoPub 5.14.0.

* 1.8.0.0
    * This version of the adapters has been certified with Verizon 1.8.0 and MoPub 5.13.1.
    * Impression is no longer tracked on ad show, but via a dedicated callback from Verizon.

* 1.7.0.1
    * Fix adapter compiler warnings.

* 1.7.0.0
    * This version of the adapters has been certified with Verizon 1.7.0 and MoPub 5.13.1.

* 1.6.0.0
    * This version of the adapters has been certified with Verizon 1.6.0 and MoPub 5.13.0.
    * Implement Advanced Bidding token compression and encoding.
    * Add Super Auction and Advanced Bidding to Rewarded Video. 

* 1.5.0.1
    * Refactor non-native adapter classes to use the new consolidated API from MoPub.
    * To use this and newer adapter versions, you must use MoPub 5.13.0 or newer.

* 1.5.0.0
    * Compress the Advanced Bidding token to adhere to MoPub's spec.
    * This version of the adapters has been certified with Verizon 1.5.0 and MoPub 5.11.0.

* 1.4.0.0
    * Update Advanced Bidding API
    * This version of the adapters has been certified with Verizon 1.4.0.
    
* 1.3.1.0
   * This version of the adapters has been certified with Verizon 1.3.1.
   
* 1.3.0.0
   * This version of the adapters has been certified with Verizon 1.3.0.
   * Remove Advanced Bidding token generation logic from the adapters. The equivalent logic will be added to the Verizon SDK.
   
 * 1.2.2.0
    * This version of the adapters has been certified with Verizon 1.2.2.

 * 1.2.1.2
    * Add support for Advanced Bidding for banner and interstitial.

 * 1.2.1.1
    * Guard MoPub import statements to avoid compilation issues.

 * 1.2.1.0
    * This version of the adapters has been certified with Verizon 1.2.1.

 * 1.2.0.1
    * Remove Millennial custom event fallback logic.

 * 1.2.0.0
    * Update to support native API changes from Verizon 1.2.0.
    * This version of the adapters has been certified with Verizon 1.2.0 and is compatible with iOS 13.

 * 1.1.4.2
    * Stop implementing deprecated request API.

 * 1.1.4.1
    * Add support for rewarded video and native ad formats.
    
 * 1.1.4.0
    * This version of the adapters has been certified with Verizon 1.1.4.

 * 1.1.2.0
    * This version of the adapters has been certified with Verizon 1.1.2.
    * Fix a `nullable` in the params of `interstitialAdEvent:`.

 * 1.0.5.1
    * Fix a logging syntax error.

 * 1.0.5.0
    * This version of the adapters has been certified with Verizon 1.0.5.
