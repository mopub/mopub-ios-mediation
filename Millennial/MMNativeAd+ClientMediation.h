//
//  MMNativeAd+ClientMediation.h
//
//  Copyright (c) 2015 Millennial Media, Inc. All rights reserved.
//

#import <MMAdSDK/MMNativeAd.h>

extern NSString* const MMNativeImageInfoURLKey;
extern NSString* const MMNativeImageInfoWidthKey;
extern NSString* const MMNativeImageInfoHeightKey;

@interface MMNativeAd (ClientMediation)

- (void)reportClick;
- (void)invokeCallToAction;

@property (nonatomic, readonly) NSArray* supportedTypes;

@property (nonatomic, readonly) NSString* titleText;
@property (nonatomic, readonly) NSString* bodyText;
@property (nonatomic, readonly) NSString* callToActionText;
@property (nonatomic, readonly) NSDictionary* iconImageInfo;
@property (nonatomic, readonly) NSDictionary* mainImageInfo;
@property (nonatomic, readonly) NSString* disclaimerText;

@end
