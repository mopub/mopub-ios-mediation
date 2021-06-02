#import "OguryAdapterConfiguration.h"
#import <OguryAds/OguryAds.h>
#import <OguryChoiceManager/OguryChoiceManager.h>

#if __has_include("MoPub.h")
#import "MPError.h"
#import "MPLogging.h"
#endif

#pragma mark - Constants

NSString * const kOguryConfigurationAdUnitId = @"ad_unit_id";

static NSString * const OguryErrorDomain = @"com.mopub.mopub-ios-sdk.mopub-ogury-adapters";
static NSString * const OguryConfigurationMediationName = @"MoPub";
static NSString * const OguryConfigurationKeyAssetKey = @"asset_key";
static NSString * const OguryConfigurationAdapterVersion = @"1.3.5.0";
static NSString * const OguryConfigurationNetworkName = @"ogury";

@implementation OguryAdapterConfiguration

#pragma mark - Properties

- (NSString *)adapterVersion {
    return OguryConfigurationAdapterVersion;
}

- (NSString *)biddingToken {
    return nil;
}

- (NSString *)moPubNetworkName {
    return OguryConfigurationNetworkName;
}

- (NSString *)networkSdkVersion {
    return [[OguryAds shared] sdkVersion];
}

#pragma mark - Methods

+ (void)updateInitializationParameters:(NSDictionary *)parameters {
    NSString * assetKey = parameters[OguryConfigurationKeyAssetKey];
    
    if (assetKey != nil && assetKey.length > 0) {
        NSDictionary * configuration = @{ OguryConfigurationKeyAssetKey: assetKey };
        [OguryAdapterConfiguration setCachedInitializationParameters:configuration];
    }
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> * _Nullable)configuration complete:(void(^ _Nullable)(NSError * _Nullable))complete {
    [[OguryAds shared] defineMediationName:OguryConfigurationMediationName];
    
    if (!configuration || [configuration count] == 0) {
        NSError *error = [NSError errorWithCode:MOPUBErrorAdapterInvalid localizedDescription:@"Ogury initialization skipped because the configuration dictionary is nil or empty."];
        
        MPLogEvent([MPLogEvent error:error message:nil]);
        
        if (complete != nil) {
            complete(error);
        }
        
        return;
    }
    
    NSString *assetKey = configuration[OguryConfigurationKeyAssetKey];
    
    if (!assetKey || [assetKey isEqualToString:@""]) {
        NSError *error = [NSError errorWithDomain:OguryErrorDomain code:MOPUBErrorAdapterInvalid userInfo:@{
            NSLocalizedDescriptionKey: @"Ogury initialization skipped because the asset key is missing or empty.",
            NSLocalizedRecoverySuggestionErrorKey: @"Please input a valid asset key from the Ogury dashboard."
        }];
        
        MPLogEvent([MPLogEvent error:error message:nil]);
        
        if (complete != nil) {
            complete(error);
        }
        
        return;
    }
    
    [[OguryAds shared] setupWithAssetKey:assetKey];
    MPLogInfo(@"Ogury SDK successfully initialized.");
    
    complete(nil);
}

+ (NSError *)MoPubErrorFromOguryError:(OguryAdsErrorType)oguryError {
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
    
    return [NSError errorWithDomain:OguryErrorDomain code:mopubErrorCode.integerValue userInfo:@{NSLocalizedDescriptionKey:localizedDescription}];
}

@end
