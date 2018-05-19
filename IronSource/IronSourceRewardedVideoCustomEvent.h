//
//  MOPUBRVAdapterIronSource.h
//

#import "MPRewardedVideoReward.h"
#import "MPRewardedVideoCustomEvent.h"
#import <IronSource/IronSource.h>

@interface IronSourceRewardedVideoCustomEvent : MPRewardedVideoCustomEvent <ISDemandOnlyRewardedVideoDelegate>


@end
