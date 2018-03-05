//
//  MOPUBRVAdapterIronSource.h
//

#import "MPRewardedVideoReward.h"
#import "MPRewardedVideoCustomEvent.h"
#import <IronSource/IronSource.h>

/*
 * Certified with IronSource 6.7.5
 */
@interface IronSourceRewardedVideoCustomEvent : MPRewardedVideoCustomEvent <ISDemandOnlyRewardedVideoDelegate>


@end
