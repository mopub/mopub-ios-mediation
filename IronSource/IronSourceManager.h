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

+ (instancetype)sharedManager;
- (void)initIronSourceSDKWithAppKey:(NSString *)appKey forAdUnits:(NSSet *)adUnits;
- (void)loadRewardedAdWithDelegate:(id<IronSourceRewardedVideoDelegate>)delegate
                        instanceID:(NSString *)instanceID;
- (void)presentRewardedAdFromViewController:(nonnull UIViewController *)viewController
                                 instanceID:(NSString *)instanceID;
- (void)requestInterstitialAdWithDelegate:(id<IronSourceInterstitialDelegate>)delegate
                               instanceID:(NSString *)instanceID;
- (void)presentInterstitialAdFromViewController:(nonnull UIViewController *)viewController
                                     instanceID: (NSString *) instanceID;

@end
