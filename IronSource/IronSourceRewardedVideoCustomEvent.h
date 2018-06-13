//
//  IronSourceRewardedVideoCustomEvent.h
//

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
    #import <MoPubSDKFramework/MoPub.h>
#else
    #import "MPRewardedVideoReward.h"
    #import "MPRewardedVideoCustomEvent.h"
#endif
#import <IronSource/IronSource.h>

@interface IronSourceRewardedVideoCustomEvent : MPRewardedVideoCustomEvent <ISDemandOnlyRewardedVideoDelegate>


@end
