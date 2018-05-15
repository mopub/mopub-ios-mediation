//
//  MMAd+Experimental.h
//  MMAdSDK
//
//  Created by Bill Dawson on 3/10/16.
//  Copyright © 2016 Millennial Media. All rights reserved.
//
//  Experimental for Incentivized VAST ads. See MAK-1090

#import <Foundation/Foundation.h>
#import "MMAd.h"
#import "MMXIncentiveEvent.h"

@protocol MMXIncentiveDelegate <NSObject>
@optional

/*
 * Callback fired when an incentivized VAST ad's video 
 * is played all the way to completion.
 *
 * @param ad The VAST ad placement whose video completed.
 */
-(BOOL)incentivizedAdCompletedVideo:(MMAd*)ad;

/*
 * General purpose callback for custom events.
 * event was triggered.
 *
 * @param event Data object containing details of the event.
 */
-(BOOL)incentivizedAd:(MMAd*)ad triggeredEvent:(MMXIncentiveEvent *)event;

@end

@interface MMAd (Experimental)

/*
 * Delegate invoked when VAST incentivized video ad completes or
 * when custom event fires from VAST incentivized video.
 */
@property (nonatomic, weak) id<MMXIncentiveDelegate> xIncentiveDelegate;

/*
 * Subclasses call this when their event forwarders forward an
 * incentive event.
 *
 * @param event Incentive Event
 */
-(void)xIncentiveEventWasTriggered:(MMXIncentiveEvent*)event;

@end
