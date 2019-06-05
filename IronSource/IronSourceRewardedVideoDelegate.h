//
//  IronSourceRewardedVideoDelegate.h
//

@protocol IronSourceRewardedVideoDelegate

- (void)rewardedVideoDidFailToLoadWithError:(NSError *)error instanceId:(NSString *)instanceId;
- (void)rewardedVideoDidLoad:(NSString *)instanceId;
- (void)rewardedVideoDidClose:(NSString *)instanceId;
- (void)rewardedVideoDidClick:(NSString *)instanceId;
- (void)rewardedVideoDidOpen:(NSString *)instanceId;
- (void)rewardedVideoDidFailToShowWithError:(NSError *)error instanceId:(NSString *)instanceId;
- (void)rewardedVideoAdRewarded:(NSString *)instanceId;

@end
