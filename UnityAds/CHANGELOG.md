
## Changelog
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
