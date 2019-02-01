## Changelog
* 6.8.1.3
    * Update Adapter Version in MillennialAdapterConfiguration to accommodate podspec changes for Unity releases.
    
* 6.8.1.2
    * Move source_files to the `Network` subspec. 

* 6.8.1.1
    * **Note**: This version is only compatible with the 5.5.0+ release of the MoPub SDK.
    * Add the `MillennialAdapterConfiguration` class to: 
         * pre-initialize the One by AOL SDK during MoPub SDK initialization process
         * store adapter and SDK versions for logging purpose
    * Streamline adapter logs via `MPLogAdEvent` to make debugging more efficient. For more details, check the [iOS Initialization guide](https://developers.mopub.com/docs/ios/initialization/) and [Writing Custom Events guide](https://developers.mopub.com/docs/ios/custom-events/).

* 6.8.1.0
    * This version of the adapters has been certified with One by AOL 6.8.1.
    * Fix an issue with native ad images not showing.
    * Fix an issue with native ad click tracker not fired.

* 6.8.0.4
    * MoPub will not be obtaining consent on behalf of One by AOL. Publishers should work directly with One by AOL to understand their obligations to comply with GDPR. Changes are updated on the supported partners page and our GDPR FAQ.
    * Fix a duplicate symbol issue in the native ad adapter.
    
* 6.8.0.3
    * update adapters to remove dependency on MPInstanceProvider
    * Update adapters to be compatible with MoPub iOS SDK framework

* 6.8.0.2
  * Removed support for OnebyAOL SDK dependency and added the support back for adapter pods.

* 6.8.0.1
  * Updated consent data value to lower case
  * Removed cocoapods support
    
* 6.8.0.0
   * This version of the adapters has been certified with One by AOL 6.8.0.
   * General Data Protection Regulation (GDPR) update to support a way for publishers to determine GDPR applicability and to obtain/manage consent from users in European Economic Area, the United Kingdom, or Switzerland to serve personalize ads. Only applicable when integrated with MoPub version 5.0.0 and above

 * 6.7.0.0
    * This version of the adapters has been certified with One by AOL 6.7.0.

  * 6.6.0.1
    * This version of the adapters has been certified with One by AOL 6.6.0.

  * Initial Commit
  	* Adapters moved from [mopub-iOS-sdk](https://github.com/mopub/mopub-ios-sdk) to [mopub-iOS-mediation](https://github.com/mopub/mopub-iOS-mediation/)
