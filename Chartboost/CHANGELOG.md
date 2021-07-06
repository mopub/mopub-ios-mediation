## Changelog
  * 8.4.2.1
      * Fix potential race condition when requesting Chartboost ads.
     
  * 8.4.2.0
      * This version of the adapters has been certified with Chartboost 8.4.2 and MoPub SDK 5.17.0.

  * 8.4.1.1
      * Add `fullscreenAdAdapterAdWillPresent` and `fullscreenAdAdapterAdDidPresent` to notify publishers of the fullscreen ad show event. Remove `fullscreenAdAdapterAdWillAppear` and  `fullscreenAdAdapterAdDidAppear` as they are now deprecated by the MoPub iOS SDK.
      * Publishers must use v5.17.0 of the MoPub SDK at the minimum.

  * 8.4.1.0
      * This version of the adapters has been certified with Chartboost 8.4.1 and MoPub SDK 5.16.1.

  * 8.4.0.1
      * Add support for `fullscreenAdAdapterAdWillDismiss` when a fullscreen creative is about to close. Publishers must use v5.16.1 of the MoPub SDK at the minimum.

  * 8.4.0.0
      * This version of the adapters has been certified with Chartboost 8.4.0 and MoPub SDK 5.15.0.

  * 8.3.1.1.2
      * Replace imports using `MoPubSDKFramework` with `MoPubSDK`. No external impacts to publishers.

  * 8.3.1.1.1
      * Add support for `fullscreenAdAdapterAdDidDismiss:` to signal that the fullscreen ad is closing and the state should be reset. To use this adapter version, you need v5.15.0 of the MoPub iOS SDK at the minimum.

  * 8.3.1.1.0
      * This version of the adapters has been certified with Chartboost 8.3.1.1 and MoPub SDK 5.14.1.

  * 8.3.1.1
      * This version of the adapters has been certified with Chartboost 8.3.1 and MoPub SDK 5.14.1.

  * 8.3.1.0
      * Re-enable passing of `CBLoggingLevelVerbose` on Chartboost log level settings.
      * This version of the adapters has been certified with Chartboost 8.3.1 and MoPub SDK 5.13.1.
      * Note that, while Chartboost 8.3.1 supports iOS 14, this adapter version is not certified using iOS 14.
      For iOS 14 compatibility, expect an upcoming adapter release.

  * 8.2.1.0
      * This version of the adapters has been certified with Chartboost 8.2.1 and MoPub SDK 5.13.1.

  * 8.2.0.3
      * Disable passing `CBLoggingLevelVerbose` to prevent app crashes caused by Chartboost SDK 8.2.0 and 8.2.1

  * 8.2.0.2
      * Fix adapter compiler warnings.

  * 8.2.0.1 
      * Add support for Chartboost `CHBGDPRDataUseConsent` API.
  
  * 8.2.0.0
      * This version of the adapters has been certified with Chartboost 8.2.0 and MoPub SDK 5.13.1.

  * 8.1.0.2
      * Refactor non-native adapter classes to use the new consolidated API from MoPub.
      * To use this and newer adapter versions, you must use MoPub 5.13.0 or newer.

  * 8.1.0.1
      * This version of the adapters has been certified MoPub SDK 5.12.0.
      * Fix Chartboost initialization and consent setting failure.
      * Revise majority of import statements

  * 8.1.0.0
      * This version of the adapters has been certified with Chartboost 8.1.0 and MoPub 5.11.0.
      * Add support for multiple Chartboost ad instances.
      * Refactor ad logic related code from `Chartboost Router` into related ad custom event objects.
      * Add Chartboost Rewarded Video adapter import statements
      
  * 8.0.4.0
      * This version of the adapters has been certified with Chartboost 8.0.4.

  * 8.0.3.0
      * This version of the adapters has been certified with Chartboost 8.0.3 and is compatible with iOS 13.

  * 8.0.1.3
      * Stop downcasting log level to `int`.

  * 8.0.1.2
      * Convert banner width and height to integers before passing them to Chartboost.

  * 8.0.1.1
      * Stop implementing deprecated request API.

  * 8.0.1.0
      * This version of the adapters has been certified with Chartboost 8.0.1.
      * Added banner adapter.

  * 7.5.0.0
      * This version of the adapters has been certified with Chartboost 7.5.0.
      * Fix empty Chartboost location Strings.
      * Use the new `setMediation:` API

  * 7.3.1.0
      * This version of the adapters has been certified with Chartboost 7.3.1.
      * Pass MoPub's log level to Chartboost. To adjust Chartboost's log level via MoPub's log settings, reference [this page](https://developers.mopub.com/publishers/ios/test/#enable-logging).

  * 7.3.0.5
      * Rename `MPChartboostRouter` to `ChartboostRouter` for consistency with other adapter class names.

  * 7.3.0.4
      * Adapters now fetch only the core MoPub iOS SDK (excluding viewability SDKs). Publishers wishing to integrate viewability should fetch the `mopub-ios-sdk` dependency in their own Podfile.

  * 7.3.0.3
      * Update Adapter Version in ChartboostAdapterConfiguration to accommodate podspec changes for Unity releases.
      
  * 7.3.0.2
      * Move source_files to the `Network` subspec.

  * 7.3.0.1
      * **Note**: This version is only compatible with the 5.5.0+ release of the MoPub SDK.
      * Add the `ChartboostAdapterConfiguration` class to: 
           * pre-initialize the Chartboost SDK during MoPub SDK initialization process
           * store adapter and SDK versions for logging purpose
      * Streamline adapter logs via `MPLogAdEvent` to make debugging more efficient. For more details, check the [iOS Initialization guide](https://developers.mopub.com/docs/ios/initialization/) and [Writing Custom Events guide](https://developers.mopub.com/docs/ios/custom-events/).
      * Allow supported mediated networks and publishers to opt-in to process a user’s personal data based on legitimate interest basis. More details [here](https://developers.mopub.com/docs/publisher/gdpr-guide/#legitimate-interest-support).

  * 7.3.0.0
      * Use Chartboost's `setPIDataUseConsent` instead of `restrictDataCollection` to pass GDPR consent data per Chartboost's 7.3.0 release.

  * 7.2.0.3
      * Override Chartboost's didDismissRewardedVideo callback 
      * Adapters now explicitly cache ads instead of calling Chartboost SDK's `setAutoCacheAds` to avoid request tracking issues.

  * 7.2.0.2  
      * Minor bug fixes to the import statements

  * 7.2.0.1
      * update adapters to remove dependency on MPInstanceProvider
      * Update adapters to be compatible with MoPub iOS SDK framework

  * 7.2.0.0
    * This version of the adapters has been certified with Chartboost 7.2.0
    * General Data Protection Regulation (GDPR) update to support a way for publishers to determine GDPR applicability and to obtain/manage consent from users in European Economic Area, the United Kingdom, or Switzerland to serve personalize ads. Only applicable when integrated with MoPub version 5.0.0 and above

  * 7.1.2.1
    * This version of the adapters has been certified with Chartboost 7.1.2.
    * Podspec version bumped in order to pin the network SDK version.

  * 7.1.2.0
    * This version of the adapters has been certified with Chartboost 7.1.2.

  * 7.0.4.1
    * This version of the adapters has been certified with Chartboost 7.0.4.

  * Initial Commit
  	* Adapters moved from [mopub-iOS-sdk](https://github.com/mopub/mopub-ios-sdk) to [mopub-iOS-mediation](https://github.com/mopub/mopub-iOS-mediation/)
