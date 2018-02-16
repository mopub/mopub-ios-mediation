//
//  MPInstanceProvider+Chartboost.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "MPInstanceProvider+Chartboost.h"
#import "MPChartboostRouter.h"

@implementation MPInstanceProvider (Chartboost)

- (MPChartboostRouter *)sharedMPChartboostRouter
{
    return [self singletonForClass:[MPChartboostRouter class]
                          provider:^id{
                              return [[MPChartboostRouter alloc] init];
                          }];
}

@end
