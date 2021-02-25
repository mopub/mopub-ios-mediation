## Changelog
  * 7.69.0.3
    * Fix static banner size leaking to subsequent adapter instances.

  * 7.69.0.2
    * Add support for `fullscreenAdAdapterAdWillDismiss` when a fullscreen creative is about to close. Publishers must use v5.16.1 of the MoPub SDK at the minimum.

  * 7.69.0.1
    * Fix a bug where native video playback controls were not responsive to user gestures.

  * 7.69.0.0
    * This version of the adapters has been certified with AdMob 7.69.0 and MoPub 5.15.0.

  * 7.68.0.2
    * Replace imports using `MoPubSDKFramework` with `MoPubSDK`. No external impacts to publishers.

  * 7.68.0.1
    * Add support for `fullscreenAdAdapterAdDidDismiss:` to signal that the fullscreen ad is closing and the state should be reset. To use this adapter version, you need v5.15.0 of the MoPub iOS SDK at the minimum.
    * Remove `nativeVideoView` as part of MoPub's native video code removal. This does not impact AdMob. No external changes or actions rerquired for publishers. 

  * 7.68.0.0
    * This version of the adapters has been certified with AdMob 7.68.0 and MoPub 5.14.1.
    * MoPub now tracks banner impressions via Google's `adViewDidRecordImpression` callback.

  * 7.66.0.1
    * Prevent oversized banner ads from serving by failing the ad request if the creative's width or height is greater than the publishers-specified width or height.

  * 7.66.0.0
    * This version of the adapters has been certified with AdMob 7.66.0 and MoPub 5.14.0.

  * 7.65.0.0
    * This version of the adapters has been certified with AdMob 7.65.0 and MoPub 5.13.1.

  * 7.64.0.1
    * Remove unnecessary `VALID_ARCHS` declaration.

  * 7.64.0.0
    * This version of the adapters has been certified with AdMob 7.64.0 and MoPub 5.13.1. 
    * Note that, while AdMob 7.64.0 supports iOS 14, this adapter version is not certified using iOS 14. For iOS 14 compatibility, expect an upcoming adapter release.

  * 7.63.0.0
    * This version of the adapters has been certified with AdMob 7.63.0 and MoPub 5.13.1.

  * 7.62.0.1
    * Fix adapter compiler warnings.

  * 7.62.0.0
    * This version of the adapters has been certified with AdMob 7.62.0 and MoPub 5.13.1.

  * 7.61.0.1
    * Remove i386 architecture support for iPhone simulators.

  * 7.61.0.0
    * This version of the adapters has been certified with AdMob 7.61.0 and MoPub 5.13.0.

  * 7.60.0.0
    * This version of the adapters has been certified with AdMob 7.60.0 and MoPub 5.13.0.

  * 7.59.0.1
    * Refactor non-native adapter classes to use the new consolidated API from MoPub.
    * Remove banner size mapping checks to fully take advantage of adaptive banner.
    * To use this and newer adapter versions, you must use MoPub 5.13.0 or newer.
    
  * 7.59.0.0
    * This version of the adapters has been certified with AdMob 7.59.0 and MoPub 5.12.1.

  * 7.58.0.1
    * Redefine valid architectures.

  * 7.58.0.0
    * This version of the adapters has been certified with AdMob 7.58.0 and MoPub 5.12.1.

  * 7.57.0.0
    * This version of the adapters has been certified with AdMob 7.57.0 and MoPub 5.11.0.

  * 7.56.0.0
    * This version of the adapters has been certified with AdMob 7.56.0

  * 7.55.1.0
    * This version of the adapters has been certified with AdMob 7.55.1

  * 7.55.0.0
    * This version of the adapters has been certified with AdMob 7.55.0

  * 7.53.1.2
    * MoPub now collects GDPR consent on behalf of Google.

  * 7.53.1.1
    * Maintain compatibility with v5.11.0 of the MoPub iOS SDK. This is the minimum adapter version for v5.11.0 integrations with MoPub. 

  * 7.53.1.0
    * This version of the adapters has been certified with AdMob 7.53.1.

  * 7.52.0.3
    * Fix an issue with native ads not responding to playback controls.

  * 7.52.0.2
    * Map banner ad sizes starting from largest height x width.

  * 7.52.0.1
    * Expose `setNpaString:` in `GoogleAdMobAdapterConfiguration.h` so publishers can set a new npa without re-initializing the MoPub SDK. 

  * 7.52.0.0
    * This version of the adapters has been certified with AdMob 7.52.0.

  * 7.51.0.0
    * This version of the adapters has been certified with AdMob 7.51.0.

  * 7.50.0.1
    * Stop implementing deprecated request API.

  * 7.50.0.0
    * This version of the adapters has been certified with AdMob 7.50.0 and is compatible with iOS 13.

  * 7.49.0.0
    * This version of the adapters has been certified with AdMob 7.49.0.
    * Use ad sizes forwarded from the MoPub SDK instead of the ad server. To ensure an optimal ad experience, publishers should use the MoPub 5.8.0+ SDK and unified banner ad units. If you are using a pre-5.8.0 MoPub SDK or unable to pass the safe area in the 5.8.0 MoPub SDK, check your ad unit setup in the Advanced Options section on the MoPub UI (more info at https://developers.mopub.com/publishers/ui/apps/manage-ad-units/#create-an-ad-unit).

  * 7.48.0.0
    * This version of the adapters has been certified with AdMob 7.48.0.

  * 7.47.0.0
    * This version of the adapters has been certified with AdMob 7.47.0.

  * 7.46.0.0
    * This version of the adapters has been certified with AdMob 7.46.0.

  * 7.44.0.0
    * This version of the adapters has been certified with AdMob 7.44.0.

  * 7.43.0.0
    * This version of the adapters has been certified with AdMob 7.43.0.
    * Move the `npa` from `MediationSettings` to `NetworkConfiguration`. [Click here](https://developers.mopub.com/publishers/mediation/networks/google/#instructions-for-passing-users-ad-preference-to-admob) for updated usage isntructions.

  * 7.42.2.0
    * Updated the adapter to use Google's new rewarded API.
    * This version of the adapters has been certified with AdMob 7.42.2.
    * Added support for publishers to pass `tagForChildDirectedTreatment` and `tagForUnderAgeOfConsent` tags to AdMob SDK via localExtras.

  * 7.39.0.0
    * This version of the adapters has been certified with AdMob 7.39.0.

  * 7.37.0.4
    * Adapters now fetch only the core MoPub iOS SDK (excluding viewability SDKs). Publishers wishing to integrate viewability should fetch the `mopub-ios-sdk` dependency in their own Podfile.

  * 7.37.0.3
    * Update Adapter Version in GoogleAdMobAdapterConfiguration to accommodate podspec changes for Unity releases. 

  * 7.37.0.2
    * Move source_files to the `Network` subspec. 

  * 7.37.0.1
    * **Note**: This version is only compatible with the 5.5.0+ release of the MoPub SDK.
    * Add the `GoogleAdMobAdapterConfiguration` class to: 
         * pre-initialize the AdMob SDK during MoPub SDK initialization process
         * store adapter and SDK versions for logging purpose
    * Streamline adapter logs via `MPLogAdEvent` to make debugging more efficient. For more details, check the [iOS Initialization guide](https://developers.mopub.com/docs/ios/initialization/) and [Writing Custom Events guide](https://developers.mopub.com/docs/ios/custom-events/).

  * 7.37.0.0
    * This version of the adapters has been certified with AdMob 7.37.0.
    * Allow publishers to pass test device IDs to the adapters (via localExtras) to get test ads from AdMob.

  * 7.36.0.2
    * Add support for publishers to pass a content URL to AdMob's ad request via the localExtras (if set). For more information on content mapping for apps, see https://support.google.com/admob/answer/6270563?hl=en.

  * 7.36.0.1
    * Disable user interaction on the AdChoices icon.

  * 7.36.0.0
    * This version of the adapters has been certified with AdMob 7.36.0.

  * 7.35.1.0
    * This version of the adapters has been certified with AdMob 7.35.1.

  * 7.34.0.1
    * Start using `MPLogInfo` instead of `MPGoogleLogInfo`.

  * 7.34.0.0
    * This version of the adapters has been certified with AdMob 7.34.0.
    * Update the native ad adapter to use Google's MediaView and GADUnifiedNativeAd per requirements (https://developers.google.com/admob/ios/native-unified).

  * 7.32.0.1
    * The interstitial adapter now uses `initWithAdUnitID` instead of specifying the `adUnitID` property, since that is now read-only.

  * 7.32.0.0
    * This version of the adapters has been certified with AdMob 7.32.0.

  * 7.31.0.2
    * Add the `trackClick` delegate to complete 7.31.0.1.

  * 7.31.0.1
    * Align MoPub's interstitial impression tracking to that of AdMob.
        * Automatic impression tracking is disabled, and AdMob's `interstitialWillPresentScreen` is used to fire MoPub impressions.

  * 7.31.0.0
    * This version of the adapters has been certified with AdMob 7.31.0.

  * 7.30.0.3
    * Minor bug fixes to the import statements
    
  * 7.30.0.3
    * Append user's ad personalization preference via MoPub's GlobalMediationSettings to AdMob's ad requests. Publishers should work with Google to be GDPR-compliant and Google's personalization preference does not MoPub's consent.

  * 7.30.0.2
    * update adapters to remove dependency on MPInstanceProvider
    * Update adapters to be compatible with MoPub iOS SDK framework

  * 7.30.0.1
  	* Updated the adapter's cocoapods dependency to MoPub version 5.0

  * 7.30.0.0
    * This version of the adapters has been certified with AdMob 7.30.0.
    
  * 7.29.0.0
    * This version of the adapters has been certified with AdMob 7.29.0.

  * 7.27.0.1
    * This version of the adapters has been certified with AdMob 7.27.0.

  * Initial Commit
  	* Adapters moved from [mopub-iOS-sdk](https://github.com/mopub/mopub-ios-sdk) to [mopub-iOS-mediation](https://github.com/mopub/mopub-iOS-mediation/)
