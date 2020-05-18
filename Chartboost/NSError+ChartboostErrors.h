//
//  NSError+ChartboostErrors.h
//  MoPubSDK
//
//  Copyright © 2019 Chartboost. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __has_include(<Chartboost/Chartboost+Mediation.h>)
#import <Chartboost/Chartboost+Mediation.h>
#else
#import "Chartboost+Mediation.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface NSError (ChartboostErrors)
+ (NSError *)errorWithCacheEvent:(CHBCacheEvent *)event error:(CHBCacheError *)error;
+ (NSError *)errorWithShowEvent:(CHBShowEvent *)event error:(CHBShowError *)error;
+ (NSError *)errorWithClickEvent:(CHBClickEvent *)event error:(CHBClickError *)error;
+ (NSError *)errorWithDidFinishHandlingClickEvent:(CHBClickEvent *)event error:(CHBClickError *)error;
+ (NSError *)adRequestCalledTwiceOnSameEvent;
+ (NSError *)adRequestFailedDueToSDKStartWithAdOfType:(NSString *)adType;
@end

NS_ASSUME_NONNULL_END
