## Changelog
* 9.1.7.2
     * Replace `InMobiSDK` with `ImMobiSDK/Core` to exclude the Moat SDK in order to avoid UIWebView deprecation issues.

* 9.1.7.1
     * Add `fullscreenAdAdapterAdWillPresent` and `fullscreenAdAdapterAdDidPresent` to notify publishers of the fullscreen ad show event. Remove `fullscreenAdAdapterAdWillAppear` and  `fullscreenAdAdapterAdDidAppear` as they are now deprecated by the MoPub iOS SDK.
     * Publishers must use v5.17.0 of the MoPub SDK at the minimum.

* 9.1.7.0
     * Initial commit.
     * This version of the adapters has been certified with InMobi 9.1.7 and MoPub SDK 5.16.2.
     * This and newer adapter versions are only compatible with 5.16.2+ MoPub SDK.
