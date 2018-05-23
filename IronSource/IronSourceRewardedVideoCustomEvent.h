//
//  IronSourceRewardedVideoCustomEvent.h
//

#if __has_include(<MoPub/MoPub.h>)
    #import "MPRewardedVideoReward.h"
    #import "MPRewardedVideoCustomEvent.h"
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
    #import <MoPubSDKFramework/MPRewardedVideoReward.h>
    #import <MoPubSDKFramework/MPRewardedVideoCustomEvent.h>
#endif
#import <IronSource/IronSource.h>

@interface IronSourceRewardedVideoCustomEvent : MPRewardedVideoCustomEvent <ISDemandOnlyRewardedVideoDelegate>


@end
