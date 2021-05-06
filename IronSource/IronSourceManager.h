//
//  IronSourceManager.h
//

#import <IronSource/IronSource.h>
#import "IronSourceRewardedVideoDelegate.h"
#import "IronSourceRewardedVideoCustomEvent.h"
#import "IronSourceConstants.h"
#import "IronSourceInterstitialDelegate.h"

@interface IronSourceManager
: NSObject <ISDemandOnlyRewardedVideoDelegate, ISDemandOnlyInterstitialDelegate>

+ (instancetype _Nonnull )sharedManager;
- (void)initIronSourceSDKWithAppKey:(NSString *_Nonnull)appKey forAdUnits:(NSSet *_Nonnull)adUnits;
- (void)loadRewardedAdWithDelegate:(id<IronSourceRewardedVideoDelegate>_Nonnull)delegate
                        instanceID:(NSString *_Nonnull)instanceID WithAdMarkup: (NSString *_Nullable) adMarkup;
- (void)presentRewardedAdFromViewController:(nonnull UIViewController *)viewController
                                 instanceID:(NSString *_Nonnull)instanceID;
- (void)requestInterstitialAdWithDelegate:(id<IronSourceInterstitialDelegate>_Nonnull)delegate
                               instanceID:(NSString *_Nonnull)instanceID WithAdMarkup: (NSString *_Nullable) adMarkup;
- (void)presentInterstitialAdFromViewController:(nonnull UIViewController *)viewController
                                     instanceID: (NSString *_Nonnull) instanceID;

@end
