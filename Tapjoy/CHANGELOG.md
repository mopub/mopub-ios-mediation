## Changelog
  * 12.2.0.1
    * **Note**: This version is only compatible with the 5.5.0+ release of the MoPub SDK.
    * Add the `TapjoyAdapterConfiguration` class to: 
         * pre-initialize the Tapjoy SDK during MoPub SDK initialization process
         * store adapter and SDK versions for logging purpose
         * return the Advanced Biding token previously returned by `TapjoyAdvancedBidder.m`
    * Streamline adapter logs via `MPLogAdEvent` to make debugging more efficient. For more details, check the [iOS Initialization guide](https://developers.mopub.com/docs/ios/initialization/) and [Writing Custom Events guide](https://developers.mopub.com/docs/ios/custom-events/).

  * 12.2.0.0
    * This version of the adapters has been certified with Tapjoy 12.2.0.
    
  * 12.1.0.0
    * This version of the adapters has been certified with Tapjoy 12.1.0.

  * 12.0.0.0
    * This version of the adapters has been certified with Tapjoy 12.0.0.
    * Add `TapjoyAdvancedBidder` for publishers using Advanced Bidding.

  * 11.12.2.1
    * Update adapters to be compatible with MoPub iOS SDK framework
    
  * 11.12.2.0
    * This version of the adapters has been certified with Tapjoy 11.12.2.
    * General Data Protection Regulation (GDPR) update to support a way for publishers to determine GDPR applicability and to obtain/manage consent from users in European Economic Area, the United Kingdom, or Switzerland to serve personalize ads. Only applicable when integrated with MoPub version 5.0.0 and above.
    
  * 11.12.0.2
    * Update import statements for MoPub frameworks

  * 11.12.0.1
   	* Updated the adapter's cocoapods dependency to MoPub version 5.0

  * 11.12.0.0
    * This version of the adapters has been certified with Tapjoy 11.12.0.

  * 11.11.1.2
    * This version of the adapters has been certified with Tapjoy 11.11.1.

  * Initial Commit
  	* Adapters moved from [mopub-ios-sdk](https://github.com/mopub/mopub-ios-sdk) to [mopub-ios-mediation](https://github.com/mopub/mopub-iOS-mediation/)
