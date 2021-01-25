//
//  IronSourceRewardedVideoCustomEvent.h
//

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
    #import <MoPubSDK/MoPub.h>
#else
    #import "MPFullscreenAdAdapter.h"
#endif

#import "IronSourceRewardedVideoDelegate.h"
#import <IronSource/IronSource.h>
#import "IronSourceManager.h"
#import "IronSourceUtils.h"

@interface IronSourceRewardedVideoCustomEvent : MPFullscreenAdAdapter <MPThirdPartyFullscreenAdAdapter>

@end
