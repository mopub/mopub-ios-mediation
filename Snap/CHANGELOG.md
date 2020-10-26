## Changelog
* 1.0.6.0
  * This version of the adapters has been certified with SnapAudienceNetwork 1.0.6 and MoPub SDK 5.14.1.

* 1.0.4.2
  * Fix adapter compiler warnings.

* 1.0.4.1
  * Refactor non-native adapter classes to use the new consolidated API from MoPub.
  * This and newer adapter versions are only compatible with 5.13.0+ MoPub SDK.

* 1.0.4.0
  * This version of the adapters has been certified with SnapAudienceNetwork 1.0.4 and MoPub SDK 5.11.0.
    
* 1.0.3.0
  * This version of the adapters has been certified with SnapAudienceNetwork 1.0.3.
  * Pass MoPub's log level to SnapAudienceNetwork. To adjust SnapAudienceNetwork' log level via MoPub's log settings, reference [this page](https://developers.mopub.com/publishers/ios/test/#enable-logging).

* 1.0.2.1
  * This version of the adapters has been certified with SnapAudienceNetwork 1.0.2.
  * Fetch `appId` from the MoPub UI and cache it for subsequent ad request.
  * Make ad request in `SnapAdCustomInterstitialEvent` after the Snap SDK finishes initialization.
  * Stop implementing deprecated request API.

 * 1.0.1.0
  * This version of the adapters has been certified with SnapAudienceNetwork 1.0.1.

 * 0.0.1.0
  * Initial Commit
  * This version of the adapters has been certified with SnapAudienceNetwork 0.0.1.
