//
//  IronSourceInterstitialCustomEvent.h
//

#if __has_include(<MoPub/MoPub.h>)
    #import "MPInterstitialCustomEvent.h"
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
    #import <MoPubSDKFramework/MPInterstitialCustomEvent.h>
#endif
#import <IronSource/IronSource.h>

@interface IronSourceInterstitialCustomEvent : MPInterstitialCustomEvent <ISDemandOnlyInterstitialDelegate>


@end
