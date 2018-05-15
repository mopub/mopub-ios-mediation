//
//  MMSDK+CustomEvent.h
//  MMAdSDK
//
//  Created by Stephen Tramer on 5/8/15.
//  Copyright (c) 2015 Millennial Media. All rights reserved.
//

#import <MMAdSDK/MMSDK.h>
#import "MMCustomEvent.h"

@interface MMSDK (CustomEvent)

/**
 *  Gets a custom event with the specified name.
 *
 * To verify that your adapter registration is working correctly,  use this in your tests like as follows:
 *  <pre><code>
 *      id<MMCustomEvent> banner = [MMSDK customEventForNetwork:kNetworkID placementType:MMPlacementTypeInline andDelegate:placement];
 *      XCTAssert([banner isKindOfClass:[MMFacebookBannerController class]], @"Returned controller was not banner: %@", [banner class]);
 *  </code><pre>
 *
 *  @param networkName The name of the custom event to retrieve. This is provided in the playlist by the gateway/endpoint.
 *  @param placementType The type of placement that will be used for displaying the custom event.
 *  @param delegate Custom event delegate
 *  @return An object which represents the custom event interface to the client SDK.
 */
+(id<MMCustomEvent>)customEventForNetwork:(NSString *)networkName
                            placementType:(MMPlacementType)placementType
                              andDelegate:(id)delegate;


/**
 *  Registers a custom event object with the system.
 *
 *  @param customEventClass     The custom event class to use. This class is responsible for managing the interations between the
 *                              Millennial SDK and the client SDK.
 *  @param networkName          The name of the ad network (mediator). This will be a value that is provided by Millennial Media, 
 *                              and is used internally as a return value from the request gateway/endpoint to identify this client 
 *                              mediation interface.
 *  @param placementType        The type of placement that will be used for displaying the custom event.
 */
+(void)registerCustomEvent:(Class<MMCustomEvent>)customEventClass
                     named:(NSString *)networkName
          forPlacementType:(MMPlacementType)placementType;

@end
