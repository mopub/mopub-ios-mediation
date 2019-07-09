//
//  IronSourceInterstitialDelegate_h
//

@protocol IronSourceInterstitialDelegate

- (void)interstitialDidLoad:(NSString *)instanceId;
- (void)interstitialDidFailToLoadWithError:(NSError *)error instanceId:(NSString *)instanceId;
- (void)interstitialDidOpen:(NSString *)instanceId;
- (void)interstitialDidClose:(NSString *)instanceId;
- (void)interstitialDidFailToShowWithError:(NSError *)error instanceId:(NSString *)instanceId;
- (void)didClickInterstitial:(NSString *)instanceId;

@end
