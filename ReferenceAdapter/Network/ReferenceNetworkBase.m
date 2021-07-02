//
//  ReferenceNetworkBase.m
//  MoPub-Reference-Adapters
//
//  Created by Kelly Dun on 3/2/21.
//

#import "ReferenceNetworkBase.h"

static NSString * const kPodsResourcesBundleName = @"ReferenceNetworkSDKResources";
static NSString * const kBundleExtension = @"bundle";

@implementation ReferenceNetworkBase

- (NSBundle *)resourceBundle {
    // CocoaPods creates a resource bundle inside its own bundle to prevent namespace collisions. Try that first:
    NSURL * bundleURL = [[NSBundle bundleForClass:self.class] URLForResource:kPodsResourcesBundleName withExtension:kBundleExtension];
    if (bundleURL != nil) {
        NSBundle * resourceBundle = [NSBundle bundleWithURL:bundleURL];
        return resourceBundle;
    }
    
    // For any other situation, the bundle should simply be the same bundle as the class requesting it:
    return [NSBundle bundleForClass:self.class];
}

@end
