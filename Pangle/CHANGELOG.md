## Changelog
   * 3.3.6.2.2
     * Add support for `fullscreenAdAdapterAdWillDismiss` when a fullscreen creative is about to close. Publishers must use v5.16.1 of the MoPub SDK at the minimum.
     
   * 3.3.6.2.1
     * Fix native ad icon rendering issue.
     * Support 1:1 native video size.
     * Pass `UserExtData` data for Pangle SDK to collect ad source information.
     
   * 3.3.6.2.0
     * This version of the adapters has been certified with Pangle 3.3.6.2 and MoPub SDK 5.15.0.

   * 3.3.6.1.0
     * This version of the adapters has been certified with Pangle 3.3.6.1 and MoPub SDK 5.15.0.

   * 3.3.6.0.1
     * Service release. No new features.
     
   * 3.3.6.0.0
     * Drop support for deep link in banner and native ad adapters. 
     * Support an error argument in the `rewardedVideoAdServerRewardDidFail:` callback
     * This version of the adapters has been certified with Pangle 3.3.6.0 and MoPub SDK 5.15.0.

   * 3.3.1.5.2
     * Replace imports using `MoPubSDKFramework` with `MoPubSDK`. No external impacts to publishers.

   * 3.3.1.5.1
     * Add support for `fullscreenAdAdapterAdDidDismiss:` to signal that the fullscreen ad is closing and the state should be reset. To use this adapter version, you need v5.15.0 of the MoPub iOS SDK at the minimum.
     * Remove `nativeVideoView` as part of MoPub's native video code removal. This does not impact Pangle. No external changes or actions rerquired for publishers. 

   * 3.3.1.5.0
     * This version of the adapters has been certified with Pangle 3.3.1.5 and MoPub SDK 5.14.1.

   * 3.3.0.5.0
     * This version of the adapters has been certified with Pangle 3.3.0.5 and MoPub SDK 5.14.1.
     * Pangle SDK 3.3.0.5 resolves an issue that causes reporting discrepancy for Advanced Bidding ads.

   * 3.2.6.2.3
     * Add support for banner format.

   * 3.2.6.2.2
     * Fix ad request failures if Pangle is not initialized with an app ID.

   * 3.2.6.2.1
     * This version of the adapters has been certified with Pangle 3.2.6.2 and MoPub SDK 5.14.1.

   * 3.2.6.2.0
     * This version of the adapters has been certified with Pangle 3.2.6.2 and MoPub SDK 5.13.1.

   * 3.2.5.2.0
     * This version of the adapters has been certified with Pangle 3.2.5.2 and MoPub SDK 5.13.1.

   * 3.2.5.1.0
     * Support Advanced Bidding.
     * This version of the adapters has been certified with Pangle 3.2.5.1 and MoPub SDK 5.13.1.
     * Note that, while Pangle 3.2.5.1 supports iOS 14, this adapter version is not certified using iOS 14. For iOS 14 compatibility, expect an upcoming adapter release.

   * 3.2.0.1.0
     * This version of the adapters has been certified with Pangle 3.2.0.1 and MoPub SDK 5.13.1.

   * 3.1.0.9.0
     * This version of the adapters has been certified with Pangle 3.1.0.9 and MoPub SDK 5.13.1.

   * 3.1.0.5.1
     * Fix adapter compiler warnings.

   * 3.1.0.5.0
     * Rename ad renderer's name to `PangleAdRenderer`.
     * This version of the adapters has been certified with Pangle 3.1.0.5 and MoPub SDK 5.13.1.

   * 3.1.0.4.0
     * Initial commit.
     * This version of the adapters has been certified with Pangle 3.1.0.4 and MoPub SDK 5.13.1.
     * This and newer adapter versions are only compatible with 5.13.0+ MoPub SDK.
