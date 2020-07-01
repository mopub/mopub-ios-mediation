//
//  IronSourceInterstitialCustomEvent.h
//

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
    #import <MoPubSDKFramework/MoPub.h>
#else
    #import "MPFullscreenAdAdapter.h"
#endif
#import <IronSource/IronSource.h>
#import "IronSourceInterstitialDelegate.h"
#import "IronSourceManager.h"
#import "IronSourceUtils.h"

@interface IronSourceInterstitialCustomEvent : MPFullscreenAdAdapter <MPThirdPartyFullscreenAdAdapter>

@end
