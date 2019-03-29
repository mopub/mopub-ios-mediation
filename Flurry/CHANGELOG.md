## Changelog
  * 9.3.1.0
    * This version of the adapters has been certified with Flurry 9.3.1.
    * Fix `apiKey` null check in `requestInterstitialWithCustomEventInfo` that causes incorrect ad failures.

  * 9.2.1.5
    * Adapters now fetch only the core MoPub iOS SDK (excluding viewability SDKs). Publishers wishing to integrate viewability should fetch the `mopub-ios-sdk` dependency in their own Podfile.

  * 9.2.1.4
    * Update the Adapter Version to accommodate podspec changes for Unity releases.
    
  * 9.2.1.3
    * Move source_files to the `Network` subspec. 

  * 9.2.1.2
    * **Note**: This version is only compatible with the 5.5.0+ release of the MoPub SDK.
    * Add the `FlurryAdapterConfiguration` class to: 
         * pre-initialize the Flurry SDK during MoPub SDK initialization process
         * store adapter and SDK versions for logging purpose
    * Streamline adapter logs via `MPLogAdEvent` to make debugging more efficient. For more details, check the [iOS Initialization guide](https://developers.mopub.com/docs/ios/initialization/) and [Writing Custom Events guide](https://developers.mopub.com/docs/ios/custom-events/).

  * 9.2.1.1
    * Ensure an exclusive pairing between Flurry's FlurryNativeAdAdapter and FlurryNativeVideoAdRenderer.

  * 9.2.1.0
    * This version of the adapters has been certified with Flurry 9.2.1.

  * 9.2.0.0
    * This version of the adapters has been certified with Flurry 9.2.0.

  * 9.0.0.0
    * This version of the adapters has been certified with Flurry 9.0.0.

  * 8.4.0.3  
    * Update adapters to remove dependency on MPInstanceProvider
    * Update adapters to be compatible with MoPub iOS SDK framework

  * 8.4.0.2
    * Updated the adapter's cocoapods dependency to MoPub version 5.0

  * 8.4.0.1
    * This version of the adapters has been certified with Flurry 8.4.0.
    * Podspec version bumped in order to pin the network SDK version.
    
  * 8.4.0.0
    * This version of the adapters has been certified with Flurry 8.4.0.
    
  * 8.3.4.0
    * This version of the adapters has been certified with Flurry 8.3.4.

  * Initial Commit
  	* Adapters moved from [mopub-iOS-sdk](https://github.com/mopub/mopub-ios-sdk) to [mopub-iOS-mediation](https://github.com/mopub/mopub-iOS-mediation/)
