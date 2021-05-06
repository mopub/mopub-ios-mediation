//
//  NSError+ReferenceNetwork.m
//  MoPub-Reference-Adapters
//
//  Created by Kelly Dun on 3/1/21.
//

#import "NSError+ReferenceNetwork.h"

/// Error domain.
NSString *const kReferenceNetworkSDKErrorDomain = @"mopub-ios-mediation.reference-adapter-sdk";

/// Error codes.
typedef NS_ENUM(NSInteger, ReferenceNetworkSDKErrorCode) {
    ReferenceNetworkSDKErrorCodeFailedToLoadImage = -100,
    ReferenceNetworkSDKErrorCodeFailedToShowImage = -200,
    ReferenceNetworkSDKErrorCodeNoPlacementId     = -300,
};

@implementation NSError (ReferenceNetwork)

+ (NSError *)failedToLoadImage:(NSString *)imageName {
    NSString *description = [NSString stringWithFormat:@"Failed to load %@", imageName];
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: description };
    return [NSError errorWithDomain:kReferenceNetworkSDKErrorDomain code:ReferenceNetworkSDKErrorCodeFailedToLoadImage userInfo:userInfo];
}

+ (NSError *)failedToLoadViewController {
    NSString *description = @"Failed to load view controller containing the creative.";
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: description };
    return [NSError errorWithDomain:kReferenceNetworkSDKErrorDomain code:ReferenceNetworkSDKErrorCodeFailedToLoadImage userInfo:userInfo];
}

+ (NSError *)failedToShowImage:(NSString *)reason {
    NSString *description = [NSString stringWithFormat:@"Failed to show image: %@", reason];
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: description };
    return [NSError errorWithDomain:kReferenceNetworkSDKErrorDomain code:ReferenceNetworkSDKErrorCodeFailedToShowImage userInfo:userInfo];
}

+ (NSError *)noPlacementId {
    NSString *description = @"No placementId";
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: description };
    return [NSError errorWithDomain:kReferenceNetworkSDKErrorDomain code:ReferenceNetworkSDKErrorCodeNoPlacementId userInfo:userInfo];
}

@end
