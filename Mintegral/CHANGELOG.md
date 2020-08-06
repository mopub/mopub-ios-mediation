## Changelog
* 6.3.5.0.3
   * Stop calling `inlineAdAdapterWillBeginUserAction:` to fix a freezing issue in Unity games.
   
 * 6.3.5.0.2
    * Fix adapter compiler warnings.

 * 6.3.5.0.1
    * Add missing MoPub imports.

 * 6.3.5.0.0
    * This version of the adapters has been certified with Mintegral 6.3.5.0 and MoPub 5.13.1.

 * 6.3.4.0.0
    * This version of the adapters has been certified with Mintegral 6.3.4.0 and MoPub 5.13.1.
    * Add support for Mintegral's `onVideoAdDidClosed:`. MoPub's `fullscreenAdAdapterAdDidDisappear:` will fire at this time when the video has been closed.

 * 6.3.3.0.0
    * This version of the adapters has been certified with Mintegral 6.3.3.0 and MoPub 5.13.0.

 * 6.2.0.0.2
    * Refactor non-native adapter classes to use the new consolidated API from MoPub.
    * To use this and newer adapter versions, you must use MoPub 5.13.0 or newer.

 * 6.2.0.0.1
    * Stop calling `bannerCustomEventWillBeginAction:` to fix a freezing issue in Unity games.

 * 6.2.0.0.0
    * This version of the adapters has been certified with Mintegral 6.2.0.0 and MoPub 5.12.1.

 * 6.1.2.0.1
    * MoPub now collects GDPR consent on behalf of Mintegral.

 * 6.1.2.0.0
    * This version of the adapters has been certified with Mintegral 6.1.2.0 and MoPub 5.11.0.

 * 6.1.1.0.1
    * Import `<MoPub/MoPub.h>` for banner, interstitial, and rewarded video adapter classes. 

 * 6.1.1.0.0
    * This version of the adapters has been certified with Mintegral 6.1.1.0 and MoPub 5.11.0.

 * 6.1.0.0.0
    * This version of the adapters has been certified with Mintegral 6.1.0.0.

 * 6.0.0.0.0
    * This version of the adapters has been certified with Mintegral 6.0.0.0.
    * Add a mute API for interstitial and rewarded video. Unless muted via `[MintegralAdapterConfiguration setMute:YES]`, creatives play unmuted by default. 

 * 5.9.0.0.0
    * This version of the adapters has been certified with Mintegral 5.9.0.0 

 * 5.8.8.0.0
    * This version of the adapters has been certified with Mintegral 5.8.8.0. 

 * 5.8.4.0.2
    * Maintain compatibility with v5.11.0 of the MoPub iOS SDK. This is the minimum adapter version for v5.11.0 integrations with MoPub. 

 * 5.8.4.0.1
    * MoPub will not be collecting GDPR consent on behalf of Mintegral. It is publisher’s responsibility to work with Mintegral to ensure GDPR compliance.
    * This version of the adapters has been certified with Mintegral 5.8.4.0.
    * Add support for Advanced Bidding.

 * 5.8.4.0.0
    * Do Not integrate this version.
    * Initial commit of the Mintegral adapters.
