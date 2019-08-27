## Changelog
   * 6.8.1.0
     * This version of the adapters has been certified with AppLovin SDK 6.8.1.

   * 6.8.0.0
     * This version of the adapters has been certified with AppLovin SDK 6.8.0.

    * 6.7.1.1
     * Fix banner size passing as part of ad format unification. This version is only compatible with the 5.8.0+ release of the MoPub SDK.

   * 6.7.1.0
     * This version of the adapters has been certified with AppLovin SDK 6.7.1.

   * 6.6.1.0
     * This version of the adapters has been certified with AppLovin SDK 6.6.1.

   * 6.6.0.0
     * This version of the adapters has been certified with AppLovin SDK 6.6.0.

   * 6.5.4.0
     * This version of the adapters has been certified with AppLovin SDK 6.5.4.
     * Fix compiler warnings.
     * Remove `userDeclinedToViewAd:` rewarded video delegate method as prompts have been removed.

   * 6.4.2.0
     * This version of the adapters has been certified with AppLovin SDK 6.4.2.

   * 6.4.0.0
     * This version of the adapters has been certified with AppLovin SDK 6.4.0
     * Pass MoPub's log level to AppLovin. To adjust AppLovin's log level via MoPub's log settings, reference [this page](https://developers.mopub.com/publishers/ios/test/#enable-logging).

   * 6.2.0.1
     * Persist the AppLovin SDK Key for Unity publishers without access to set it in the project's info.plist. Click [here](https://developers.mopub.com/publishers/mediation/networks/applovin/#download-and-integration) for further implementation instructions.

   * 6.2.0.0
     * This version of the adapters has been certified with AppLovin SDK 6.2.0.
     * Addressed some issues and optimized adapter:
     * Allow passing in of SDK key via the initialization `configuration` object as many publishers integrate without SDK key in the `Info.plist`.
     * Add support for using a cached `configuration` NSDictionary for initialization.
     * Do not consider banner ad display failure as ad load failure.
     * Do not consider users closing rewarded ad early or reward validation failure as an ad load failure.
     * Bumped AppLovin SDK plugin version to "MoPub-6.2.0.0".
   
   * 6.1.4.4
     * Adapters now fetch only the core MoPub iOS SDK (excluding viewability SDKs). Publishers wishing to integrate viewability should fetch the `mopub-ios-sdk` dependency in their own Podfile.

   * 6.1.4.3
     * Update Adapter Version in AppLovinAdapterConfiguration to accommodate podspec changes for Unity releases.
     
   * 6.1.4.2
     * Move source_files to the `Network` subspec.

   * 6.1.4.1
     * **Note**: This version is only compatible with the 5.5.0+ release of the MoPub SDK.
     * Add the `AppLovinAdapterConfiguration` class to: 
          * pre-initialize the AppLovin SDK during MoPub SDK initialization process
          * store adapter and SDK versions for logging purpose
          * return the Advanced Biding token previously returned by `AppLovinAdvancedBidder.m`
     * Streamline adapter logs via `MPLogAdEvent` to make debugging more efficient. For more details, check the [iOS Initialization guide](https://developers.mopub.com/docs/ios/initialization/) and [Writing Custom Events guide](https://developers.mopub.com/docs/ios/custom-events/).

   * 6.1.4.0
     * This version of the adapters has been certified with AppLovin SDK 6.1.4.

   * 5.1.2.1
     * Add support for AppLovin to be an Advanced Bidder on the MoPub platform.

   * 5.1.2.0
     * This version of the adapters has been certified with AppLovin SDK 5.1.2.

   * 5.1.1.0 
     * This version of the adapters has been certified with AppLovin SDK 5.1.1.

   * 5.1.0.2 
     * Add the `trackClick` delegate for interstitial to complete 5.1.0.1. 

   * 5.1.0.1
     * Align MoPub's interstitial impression tracking to that of AppLovin.
        * Automatic impression tracking is disabled, and AppLovin's `wasDisplayedIn` is used to fire MoPub impressions.

   * 5.1.0.0
     * This version of the adapters has been certified with AppLovin SDK 5.1.0

   * 5.0.2.0
     * This version of the adapters has been certified with AppLovin SDK 5.0.2

   * 5.0.1.2
     * Minor bug fixes to the import statements

   * 5.0.1.1
     * Update adapters to be compatible with MoPub iOS SDK framework

   * 5.0.1.0
      * This version of the adapters has been certified with AppLovin SDK 5.0.1
      * General Data Protection Regulation (GDPR) update to support a way for publishers to determine GDPR applicability and to obtain/manage consent from users in European Economic Area, the United Kingdom, or Switzerland to serve personalize ads. Only applicable when integrated with MoPub version 5.0.0 and above

   * 4.8.4.0
      * This version of the adapters has been certified with AppLovin SDK 4.8.4
      * Guarantee ad load callbacks for interstitials and rewarded videos to be executed on the main queue.
   * 4.8.3.0
      * This version of the adapters has been certified with AppLovin SDK 4.8.3
  
  * Initial Commit
