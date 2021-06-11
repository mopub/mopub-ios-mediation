
## Changelog
* 3.7.2.0
  * This version of the adapters has been certified with Unity Ads 3.7.2 and MoPub SDK 5.17.0.
  * Remove duplicate `fullscreenAdAdapterAdDidDismiss` callback for interstitial ads.

* 3.7.1.2
  * Add `fullscreenAdAdapterAdWillPresent` and `fullscreenAdAdapterAdDidPresent` to notify publishers of the fullscreen ad show event. Remove `fullscreenAdAdapterAdWillAppear` and  `fullscreenAdAdapterAdDidAppear` as they are now deprecated by the MoPub iOS SDK.
  * Publishers must use v5.17.0 of the MoPub SDK at the minimum.

* 3.7.1.1
  * Remove deprecated usage of Rewarded Video APIs.

* 3.7.1.0
  * This version of the adapters has been certified with Unity Ads 3.7.1 and MoPub SDK 5.16.2.

* 3.6.0.1
  * Add support for `fullscreenAdAdapterAdWillDismiss` when a fullscreen creative is about to close. Publishers must use v5.16.1 of the MoPub SDK at the minimum.

* 3.6.0.0
  * This version of the adapters has been certified with Unity Ads 3.6.0 and MoPub SDK 5.15.0.

* 3.5.1.2
  * Replace imports using `MoPubSDKFramework` with `MoPubSDK`. No external impacts to publishers.

* 3.5.1.1
  * Add support for `fullscreenAdAdapterAdDidDismiss:` to signal that the fullscreen ad is closing and the state should be reset. To use this adapter version, you need v5.15.0 of the MoPub iOS SDK at the minimum.

* 3.5.1.0
  * This version of the adapters has been certified with Unity Ads 3.5.1 and MoPub SDK 5.14.1.

* 3.5.0.0
  * This version of the adapters has been certified with Unity Ads 3.5.0 and MoPub SDK 5.14.1.
  * Note that Unity Ads team does not recommend this version of their SDK with iOS 14. For full compliance, expect an upcoming adapter release for Unity Ads upcoming version 3.5.1.

* 3.4.8.1
  * This version of the adapters has been certified with Unity Ads 3.4.8 and MoPub SDK 5.14.1.

* 3.4.8.0
  * This version of the adapters has been certified with Unity Ads 3.4.8 and MoPub SDK 5.13.1.
  * Note that, while Unity Ads 3.4.8 supports iOS 14, this adapter version is not certified using iOS 14. For iOS 14 compatibility, expect an upcoming adapter release.

* 3.4.6.1
  * Fix adapter compiler warnings.

* 3.4.6.0
  * This version of the adapters has been certified with Unity Ads 3.4.6 and MoPub SDK 5.13.0.

* 3.4.2.1
  * Refactor non-native adapter classes to use the new consolidated API from MoPub.
  * This and newer adapter versions are only compatible with 5.13.0+ MoPub SDK.

* 3.4.2.0
  * This version of the adapters has been certified with Unity Ads 3.4.2.

* 3.4.0.1
  * Log Unity Ads placement Id in the ad lifecycle events.

* 3.4.0.0
  * This version of the adapters has been certified with Unity Ads 3.4.0.
  
* 3.3.0.1
  * Update adapter to handle Unity Ads load behaviors seamlessly for fullscreen ads.
  * Fix incompatible type warning for MoPub `logLevel`. 
  
* 3.3.0.0
  * This version of the adapters has been certified with Unity Ads 3.3.0 and is compatible with iOS 13.
  * Update the banner adapter to use new load API.
  * Fix banner ads refresh to render correctly.

* 3.2.0.1
  * Stop implementing deprecated request API.

* 3.2.0.0
  * This version of the adapters has been certified with Unity Ads 3.2.0.
  * **Note**:On MoPub adunit refresh, Unity Banners may not render correctly and this issue will be fixed in the upcoming Unity SDK versions. This behavior is inconsistent and there is no suggested workaround at the moment

* 3.1.0.0
  * This version of the adapters has been certified with Unity Ads 3.1.0.
  * Add load API functionality via metadata API to prevent rewarded and interstitial placements from loading in UnityAds until `load` is called.

* 3.0.3.0
  * This version of the adapters has been certified with UnityAds 3.0.3.

* 3.0.1.1
  * Pass MoPub's log level to Unity Ads. To adjust Unity Ads' log level via MoPub's log settings, reference [this page](https://developers.mopub.com/publishers/ios/test/#enable-logging).

* 3.0.1.0
  * This version of the adapters has been certified with Unity Ads 3.0.1.
  * Includes checks for Unity Ads availability to avoid timeouts.
  
* 3.0.0.5
  * Rename `MPUnityRouter` to `UnityRouter` for consistency with other adapter class names. 

* 3.0.0.4
  * Adapters now fetch only the core MoPub iOS SDK (excluding viewability SDKs). Publishers wishing to integrate viewability should fetch the `mopub-ios-sdk` dependency in their own Podfile.

* 3.0.0.3
  * Update Adapter Version in UnityAdsAdapterConfiguration to accommodate podspec changes for Unity releases.
  
* 3.0.0.2
  * Move source_files to the `Network` subspec.

* 3.0.0.1
  * **Note**: This version is only compatible with the 5.5.0+ release of the MoPub SDK.
  * Add the `UnityAdsAdapterConfiguration` class to: 
    * pre-initialize the Unity Ads SDK during MoPub SDK initialization process
    * store adapter and SDK versions for logging purpose
    * Streamline adapter logs via `MPLogAdEvent` to make debugging more efficient. For more details, check the [iOS Initialization guide](https://developers.mopub.com/docs/ios/initialization/) and [Writing Custom Events guide](https://developers.mopub.com/docs/ios/custom-events/).
    * Allow supported mediated networks and publishers to opt-in to process a user’s personal data based on legitimate interest basis. More details [here](https://developers.mopub.com/docs/publisher/gdpr-guide/#legitimate-interest-support).

* 3.0.0.0
  * This version of the adapters has been certified with UnityAds 3.0.0.
  * Add support for banner ad.
  * Update GDPR consent passing logic to use MoPub's `isGDPRApplicable` and `canCollectPersonalInfo`.

* 2.3.0.1
  * Handle no-fill scenarios from Unity Ads. 

* 2.3.0.0
  * This version of the adapters has been certified with UnityAds 2.3.0

* 2.2.0.6
  * Update to share consent with Unity Ads only when user provides an explicit yes/no. In all other cases, Unity Ads SDK will collect its own consent per the guidelines mention in https://unity3d.com/legal/gdpr

* 2.2.0.5
  * Update adapters to be compatible with MoPub iOS SDK framework

* 2.2.0.4
  * Notify Unity Ads even when the user does not consent

* 2.2.0.3
  * This version of the adapters has been certified with UnityAds 2.2.0
  * General Data Protection Regulation (GDPR) update to support a way for publishers to determine GDPR applicability and to obtain/manage consent from users in European Economic Area, the United Kingdom, or Switzerland to serve personalize ads. Only applicable when integrated with MoPub version 5.0.0 and above
    
* 2.2.0.2
  * This version of the adapters has been certified with UnityAds 2.2.0.
  * Podspec version bumped in order to pin the network SDK version.
    
* 2.2.0.0
  * This version of the adapters has been certified with UnityAds 2.2.0.

* 2.1.1.3
  * This version of the adapters has been certified with UnityAds 2.1.1.

* Initial Commit
  * Adapters moved from [mopub-iOS-sdk](https://github.com/mopub/mopub-ios-sdk) to [mopub-iOS-mediation](https://github.com/mopub/mopub-iOS-mediation/)
