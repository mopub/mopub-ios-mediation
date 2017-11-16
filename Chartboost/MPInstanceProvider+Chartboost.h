//
//  MPInstanceProvider+Chartboost.h
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "MPInstanceProvider.h"

@class MPChartboostRouter;

@interface MPInstanceProvider (Chartboost)

- (MPChartboostRouter *)sharedMPChartboostRouter;

@end
