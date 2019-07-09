## Changelog
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
