## Changelog
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
