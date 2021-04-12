//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "NSError+Ogury.h"
#import "OguryAdapterConfiguration.h"

@implementation NSError (Ogury)

+ (NSError *)ogy_MoPubErrorFromOguryError:(OguryAdsErrorType)oguryError {
    NSNumber *mopubErrorCode;
    NSString *localizedDescription;

    switch (oguryError) {

        case OguryAdsErrorLoadFailed:
            mopubErrorCode = @(MOPUBErrorAdapterFailedToLoadAd);
            localizedDescription = @"The ad failed to load for an unknown reason.";
            break;

        case OguryAdsErrorNoInternetConnection:
            mopubErrorCode = @(MOPUBErrorAdapterFailedToLoadAd);
            localizedDescription = @"The device has no Internet connection. Try again when the device is connected to Internet again.";
            break;

        case OguryAdsErrorAdDisable:
            mopubErrorCode = @(MOPUBErrorAdapterFailedToLoadAd);
            localizedDescription = @"Ad serving has been disabled for this placement/application.";
            break;

        case OguryAdsErrorProfigNotSynced:
            mopubErrorCode = @(MOPUBErrorSDKNotInitialized);
            localizedDescription = @"An internal SDK error occurred.";
            break;

        case OguryAdsErrorAdExpired:
            mopubErrorCode = @(MOPUBErrorAdapterFailedToLoadAd);
            localizedDescription = @"The loaded ad is expired. You must call the show method within 4 hours after the load";
            break;

        case OguryAdsErrorSdkInitNotCalled:
            mopubErrorCode = @(MOPUBErrorSDKNotInitialized);
            localizedDescription = @"The setup method has not been called before a call to the load or show methods.";
            break;

        case OguryAdsErrorAnotherAdAlreadyDisplayed:
            mopubErrorCode = @(MOPUBErrorFullScreenAdAlreadyOnScreen);
            localizedDescription = @"Another ad is already displayed on the screen.";
            break;

        case OguryAdsErrorCantShowAdsInPresentingViewController:
            mopubErrorCode = @(MOPUBErrorFullScreenAdAlreadyOnScreen);
            localizedDescription = @"Currently a ViewController is being presented and it is preventing the ad from displaying.";
            break;

        case OguryAdsErrorUnknown:
        default:
            mopubErrorCode = @(MOPUBErrorUnknown);
            localizedDescription = @"Unkown error type.";
            break;
    }

    return [NSError errorWithDomain:kOguryErrorDomain code:mopubErrorCode.integerValue userInfo:@{NSLocalizedDescriptionKey:localizedDescription}];
}

@end
