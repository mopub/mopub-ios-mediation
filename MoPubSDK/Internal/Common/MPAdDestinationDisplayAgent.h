//
//  MPAdDestinationDisplayAgent.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPActivityViewControllerHelper+TweetShare.h"
#import "MPURLResolver.h"
#import "MPProgressOverlayView.h"
#import "MPAdBrowserController.h"
#import "MPStoreKitProvider.h"

typedef NS_ENUM(NSInteger, MOPUBDisplayAgentType) {
    MOPUBDisplayAgentTypeInApp = 0,
    MOPUBDisplayAgentTypeNativeSafari,
    MOPUBDisplayAgentTypeSafariViewController
};

@protocol MPAdDestinationDisplayAgentDelegate;

@interface MPAdDestinationDisplayAgent : NSObject <MPProgressOverlayViewDelegate,
                                                   MPAdBrowserControllerDelegate,
                                                   MPSKStoreProductViewControllerDelegate,
                                                   MPActivityViewControllerHelperDelegate>

@property (nonatomic, weak) id<MPAdDestinationDisplayAgentDelegate> delegate;

+ (MPAdDestinationDisplayAgent *)agentWithDelegate:(id<MPAdDestinationDisplayAgentDelegate>)delegate;
+ (BOOL)shouldUseSafariViewController;
- (void)displayDestinationForURL:(NSURL *)URL;
- (void)cancel;

@end

@protocol MPAdDestinationDisplayAgentDelegate <NSObject>

- (UIViewController *)viewControllerForPresentingModalView;
- (void)displayAgentWillPresentModal;
- (void)displayAgentWillLeaveApplication;
- (void)displayAgentDidDismissModal;

@optional

- (MPAdConfiguration *)adConfiguration;

@end
