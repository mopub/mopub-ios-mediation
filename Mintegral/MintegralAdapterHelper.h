//
//  MintegralAdapterHelper.h
//  MoPubSampleApp
//
//  Copyright © 2017年 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_include(<MoPubSDKFramework/MoPub.h>)
#import <MoPubSDKFramework/MoPub.h>
#else
#import "MoPub.h"
#endif


#define MintegralAdapterVersion  MTGSDKVersion@".1"

extern NSString *const kMintegralErrorDomain;

@interface MintegralAdapterHelper : NSObject


+(BOOL)isSDKInitialized;

+(void)sdkInitialized;

+(void)setGDPRInfo:(NSDictionary *)info;

@end
