## Changelog
* 6.8.4.2.0
    * This version of the adapters has been certified with ironSource 6.8.4.2.

* 6.8.4.1.0
    * This version of the adapters has been certified with ironSource 6.8.4.1.

 * 6.8.4.0.1
    * Fix missing `MPLogging.h` import to avoid build errors.

 * 6.8.4.0.0
    * This version of the adapters has been certified with ironSource 6.8.4.0.
    * Revise adapter code to comply with ironSource 6.8.4.0.
    * Remove `placementName` as ironSource 6.8.4.0 no longer uses it.
    * Gracefully fail ad loads if the unique `instanceIds` are not used during concurrent ad requests for rewarded video.

 * 6.8.3.0.0
    * This version of adapters has been certified with IronSource 6.8.3.0.
  
 * 6.8.1.0.2
    * Call `rewardedVideoDidFailToLoadAdForCustomEvent` after logging a failure case to avoid potential crashes on nil IDs during Load failure. 
  
 * 6.8.1.0.1
    * Log load failure before calling delegate method `rewardedVideoDidFailToLoadAdForCustomEvent` to fix crash due to dangling pointer.
    
 * 6.8.1.0.0
    * This version of the adapters has been certified with IronSource 6.8.1.0.
    
 * 6.8.0.0.4
    * Adapters now fetch only the core MoPub iOS SDK (excluding viewability SDKs). Publishers wishing to integrate viewability should fetch the `mopub-ios-sdk` dependency in their own Podfile.

 * 6.8.0.0.3
    * Update Adapter Version in IronsSourceAdapterConfiguration to accommodate podspec changes for Unity releases.
    
 * 6.8.0.0.2
    * Move source_files to the `Network` subspec.

 * 6.8.0.0.1
    * **Note**: This version is only compatible with the 5.5.0+ release of the MoPub SDK.
    * Add the `IronSourceAdapterConfiguration` class to: 
         * pre-initialize the ironSource SDK during MoPub SDK initialization process
         * store adapter and SDK versions for logging purpose
    * Streamline adapter logs via `MPLogAdEvent` to make debugging more efficient. For more details, check the [iOS Initialization guide](https://developers.mopub.com/docs/ios/initialization/) and [Writing Custom Events guide](https://developers.mopub.com/docs/ios/custom-events/).

 * 6.8.0.0.0
    * This version of the adapters has been certified with IronSource 6.8.0.0
    
 * 6.7.12.0
    * This version of the adapters has been certified with IronSource 6.7.12

 * 6.7.11.0
    * This version of the adapters has been certified with IronSource 6.7.11

 * 6.7.10.0
    * This version of the adapters has been certified with IronSource 6.7.10

 * 6.7.9.3.0
    * This version of the adapters has been certified with IronSource 6.7.9.3

 * 6.7.9.2.0
    * This version of the adapters has been certified with IronSource 6.7.9.2

 * 6.7.9.1.2
    * Notify MoPub when the ironSource `interstitialDidFailToShowWithError` delegate fires
    * Improve ironSource SDK initialization
    
 * 6.7.9.1.1
 	  * Update adapters to be compatible with MoPub iOS SDK framework

 * 6.7.9.1.0
    * This version of the adapters has been certified with IronSource 6.7.9.1 

 * 6.7.9.0
    * This version of the adapters has been certified with IronSource 6.7.9.
    * General Data Protection Regulation (GDPR) update to support a way for publishers to determine GDPR applicability and to obtain/manage consent from users in European Economic Area, the United Kingdom, or Switzerland to serve personalize ads. Only applicable when integrated with MoPub version 5.0.0 and above
    
 * 6.7.8.0
    * This version of the adapters has been certified with IronSource 6.7.8.

  * 6.7.5.0
    * This version of the adapters has been certified with IronSource 6.7.5.

  * Initial Commit
  	* Adapters moved from [mopub-iOS-sdk](https://github.com/mopub/mopub-ios-sdk) to [mopub-iOS-mediation](https://github.com/mopub/mopub-iOS-mediation/)
