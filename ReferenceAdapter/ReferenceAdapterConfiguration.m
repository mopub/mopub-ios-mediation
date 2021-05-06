//
//  ReferenceAdapterConfiguration.m
//  MoPub-Reference-Adapters
//
//  Created by Kelly Dun on 3/1/21.
//

#import "ReferenceAdapterConfiguration.h"
#import "ReferenceNetworkSDK.h"

@implementation ReferenceAdapterConfiguration

#pragma mark - Required MPBaseAdapterConfiguration Overrides

/// The version of the adapter.
- (NSString *)adapterVersion {
    return @"1.0.0.0";
}

/// An optional identity token used for ORTB bidding requests required for Advanced Bidding.
- (NSString * _Nullable)biddingToken {
    // Some networks require their SDK to be initialized before obtaining an
    // Advanced Bidding token. In those cases, this should return `nil`.
    if (ReferenceNetworkSDK.isInitialized == NO) {
        return nil;
    }
    
    // Retrieval of the Advanced Bidding token should be synchronous.
    return ReferenceNetworkSDK.token;
}

/// MoPub-specific name of the network.
/// @remarks This value should correspond to `creative_network_name` in the dashboard.
- (NSString *)moPubNetworkName {
    return @"reference_network";
}

/// The version of the underlying network SDK.
- (NSString *)networkSdkVersion {
    return ReferenceNetworkSDK.version;
}

/// Initializes the underlying network SDK with a given set of initialization parameters.
/// @param configuration Optional set of JSON-codable configuration parameters that correspond specifically to the network.
///                     Only @c NSString, @c NSNumber, @c NSArray, and @c NSDictionary types are allowed.
///                     This value may be @c nil.
/// @param complete Optional completion block that is invoked when the underlying network SDK has completed initialization. This value may be @c nil.
/// @remarks Classes that implement this protocol must account for the possibility of @c initializeNetworkWithConfiguration:complete: being
///          called multiple times. It is up to each individual adapter to determine whether re-initialization is allowed or not.
- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> * _Nullable)configuration
                                  complete:(void(^ _Nullable)(NSError * _Nullable))complete {
    // Check if network SDK has already been initialized before continuing.
    // Complete immediately with no error if it's already initialized.
    if (ReferenceNetworkSDK.isInitialized == YES) {
        if (complete != nil) {
            complete(nil);
        }
        return;
    }
    
    // Parse out any network specific initialization parameters from `configuration`,
    // and pass them into the network SDK initialization.
    // For example: Extracting the placement IDs of the network to initialize.
    NSArray<NSString *> *placementIds = configuration[@"placement_ids"];
    
    // Initialize the reference SDK 
    [ReferenceNetworkSDK initializeNetworkWithPlacementIds:placementIds completion:^{
        // Pass back any initialization errors, or `nil` if there were no errors.
        NSError *error = nil;

        if (complete != nil) {
            complete(error);
        }
    }];
}

@end
