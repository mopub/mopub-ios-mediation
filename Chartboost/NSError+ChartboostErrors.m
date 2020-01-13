//
//  NSError+ChartboostErrors.m
//  MoPubSDK
//
//  Copyright © 2019 Chartboost. All rights reserved.
//

#import "NSError+ChartboostErrors.h"

#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
#import <MoPubSDKFramework/MoPub.h>
#else
#import "MPError.h"
#endif


@implementation NSError (ChartboostErrors)

+ (NSError *)errorWithCacheEvent:(CHBCacheEvent *)event error:(CHBCacheError *)error
{
    return [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd
             localizedDescription:[NSString stringWithFormat:@"Chartboost adapter failed to load %@ with location %@ and error %@", [self adTypeNameForAd:event.ad], event.ad.location, error.description]];
}

+ (NSError *)errorWithShowEvent:(CHBShowEvent *)event error:(CHBShowError *)error
{
    return [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd
             localizedDescription:[NSString stringWithFormat:@"Chartboost adapter failed to show %@ with location %@ and error %@", [self adTypeNameForAd:event.ad], event.ad.location, error.description]];
}

+ (NSError *)errorWithClickEvent:(CHBClickEvent *)event error:(CHBClickError *)error
{
    return [NSError errorWithCode:MOPUBErrorUnknown
             localizedDescription:[NSString stringWithFormat:@"Chartboost adapter failed to click %@ with location %@ and error %@", [self adTypeNameForAd:event.ad], event.ad.location, error.description]];
}

+ (NSError *)errorWithDidFinishHandlingClickEvent:(CHBClickEvent *)event error:(CHBClickError *)error
{
    return [NSError errorWithCode:MOPUBErrorUnknown
             localizedDescription:[NSString stringWithFormat:@"Chartboost adapter did finish handling click for %@ with location %@ and error %@", [self adTypeNameForAd:event.ad], event.ad.location, error.description]];
}

+ (NSError *)adRequestCalledTwiceOnSameEvent
{
    return [NSError errorWithCode:MOPUBErrorUnknown
             localizedDescription:@"Chartboost adapter error: requestAdWithSize called twice on the same event."];
}

+ (NSError *)adRequestFailedDueToSDKStartWithAdOfType:(NSString *)adType
{
    return [NSError errorWithCode:MOPUBErrorAdapterInvalid
             localizedDescription:[NSString stringWithFormat:@"Failed to load Chartboost %@: sdk initialization failed.", adType]];
}

+ (NSString *)adTypeNameForAd:(id<CHBAd>)ad
{
    if ([ad isKindOfClass:CHBInterstitial.class]) {
        return @"interstitial";
    } else if ([ad isKindOfClass:CHBRewarded.class]) {
        return @"rewarded";
    } else if ([ad isKindOfClass:CHBBanner.class]) {
        return @"banner";
    } else {
        return @"ad";
    }
}

@end
