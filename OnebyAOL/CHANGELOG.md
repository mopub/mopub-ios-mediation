## Changelog
* 6.8.1.4
    * MoPub will not be obtaining consent on behalf of One by AOL. Publishers should work directly with One by AOL to understand their obligations to comply with GDPR. Changes are updated on the supported partners page and our GDPR FAQ.
    * Fix a duplicate symbol issue in the native ad adapter.
    
* 6.8.1.3
    * update adapters to remove dependency on MPInstanceProvider
    * Update adapters to be compatible with MoPub iOS SDK framework

* 6.8.1.2
  * Removed support for OnebyAOL SDK dependency and added the support back for adapter pods.

* 6.8.1.1
  * This version of the adapters has been certified with One by AOL 6.8.1.
  * Updated consent data value to lower case
  * Removed cocoapods support
    
* 6.8.1.0
   * This version of the adapters has been certified with One by AOL 6.8.1.
   * General Data Protection Regulation (GDPR) update to support a way for publishers to determine GDPR applicability and to obtain/manage consent from users in European Economic Area, the United Kingdom, or Switzerland to serve personalize ads. Only applicable when integrated with MoPub version 5.0.0 and above

 * 6.7.0.0
    * This version of the adapters has been certified with One by AOL 6.7.0.

  * 6.6.0.1
    * This version of the adapters has been certified with One by AOL 6.6.0.

  * Initial Commit
  	* Adapters moved from [mopub-iOS-sdk](https://github.com/mopub/mopub-ios-sdk) to [mopub-iOS-mediation](https://github.com/mopub/mopub-iOS-mediation/)
