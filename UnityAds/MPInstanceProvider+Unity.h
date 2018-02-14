//
//  MPInstanceProvider+Unity.h
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#import "MPInstanceProvider.h"

@class MPUnityRouter;

@interface MPInstanceProvider (Unity)

- (MPUnityRouter *)sharedMPUnityRouter;

@end
