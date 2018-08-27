## Changelog
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
