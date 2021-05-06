//
//  ReferenceNetworkFullscreenAd.m
//  MoPub-Reference-Adapters
//
//  Created by Kelly Dun on 3/1/21.
//

#import "NSError+ReferenceNetwork.h"
#import "ReferenceNetworkFullscreenAd.h"
#import "ReferenceNetworkFullscreenViewController.h"

@interface ReferenceNetworkFullscreenAd() <ReferenceNetworkFullscreenViewControllerDelegate>
@property (nonatomic, strong, nullable) UIViewController *ad;
@property (nonatomic, strong, nullable) UIImage *cachedCreative;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL isRewarded;
@property (nonatomic, copy) NSString *placement;
@end

@implementation ReferenceNetworkFullscreenAd

#pragma mark - Initialization

- (instancetype)initWithPlacement:(NSString *)placement isRewarded:(BOOL)isRewarded {
    if (self = [super init]) {
        _ad = nil;
        _delegate = nil;
        _isLoading = NO;
        _isRewarded = isRewarded;
        _placement = placement;
        
        // Cache the creative.
        _cachedCreative = [UIImage imageNamed:@"Fullscreen360x640" inBundle:self.resourceBundle compatibleWithTraitCollection:nil];
    }
    
    return self;
}

#pragma mark - Computed Properties

- (BOOL)isLoaded {
    return (self.ad != nil);
}

#pragma mark - Simulated Ad Loading

- (void)load {
    // Already loaded, do nothing
    if (self.isLoaded == YES) {
        return;
    }
    
    // Load in progress, do nothing.
    if (self.isLoading == YES) {
        return;
    }
    
    // Start the loading process.
    self.isLoading = YES;
    
    // Simulate loading the "ad"
    __typeof__(self) __weak weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // Capture a strong reference
        __typeof__(self) strongSelf = weakSelf;
        
        // Ad is no longer loading
        strongSelf.isLoading = NO;
        
        // Generate the ad and add the clickthrough to the `UIImageView`.
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:strongSelf action:@selector(onCreativeTapped)];
        UIImageView *inlineAd = strongSelf.cachedCreative != nil ? [[UIImageView alloc] initWithImage:strongSelf.cachedCreative] : nil;
        inlineAd.contentMode = UIViewContentModeCenter;
        inlineAd.userInteractionEnabled = YES;
        [inlineAd addGestureRecognizer:recognizer];
        [inlineAd sizeToFit];
        
        if (inlineAd == nil) {
            NSError *error = [NSError failedToLoadImage:@"Fullscreen360x640"];
            [strongSelf.delegate fullscreenAdDidFailToLoad:error];
            return;
        }
        
        // Generate the `UIViewController` that will present the creative.
        ReferenceNetworkFullscreenViewController *viewController = [[ReferenceNetworkFullscreenViewController alloc] initWithCreative:inlineAd];
        viewController.closeButtonDelay = (strongSelf.isRewarded ? 5.0: 0.0);
        viewController.delegate = strongSelf;
        viewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        
        strongSelf.ad = viewController;
        
        // Report the load result.
        if (strongSelf.ad != nil) {
            [strongSelf.delegate fullscreenAdDidLoad];
        }
        else {
            NSError *error = [NSError failedToLoadViewController];
            [strongSelf.delegate fullscreenAdDidFailToLoad:error];
        }
    });
}

- (void)showFromViewController:(UIViewController *)presentingViewController {
    if (self.ad != nil) {
        [self.delegate fullscreenAdWillPresent];
        
        __weak __typeof__(self) weakSelf = self;
        [presentingViewController presentViewController:self.ad animated:YES completion:^{
            __typeof__(self) strongSelf = weakSelf;
            [strongSelf.delegate fullscreenAdDidPresent];
        }];
    }
    else {
        NSError *error = [NSError failedToShowImage:@"no ad loaded"];
        [self.delegate fullscreenAdDidFailToShow:error];
    }
}

#pragma mark - Gesture Recognizers

- (void)onCreativeTapped {
    [self.delegate fullscreenAdClicked];
    
    NSURL *clickthroughUrl = [NSURL URLWithString:@"https://www.mopub.com"];
    [UIApplication.sharedApplication openURL:clickthroughUrl options:@{} completionHandler:^(BOOL success) {
        // no-op
    }];
}

#pragma mark - ReferenceNetworkFullscreenViewControllerDelegate

- (void)didAppear {
    // The creative has appeared onscreen and is visible. Fire the impression tracker.
    // THIS IS NOT TO BE CONFUSED WITH PRESENTATION WHICH DOES NOT TAKE INTO ACCOUNT
    // WHETHER THE VIEW IS ACTUALLY VISIBLE ONSCREEN
    [self.delegate fullscreenAdImpressionTracked];
}

- (void)didTapClose {
    [self.delegate fullscreenAdWillDismiss];
    
    __typeof__(self) __weak weakSelf = self;
    [self.ad.presentingViewController dismissViewControllerAnimated:YES completion:^{
        __typeof__(self) strongSelf = weakSelf;
        [strongSelf.delegate fullscreenAdDidDismiss];
    }];
    
    // Clear out the ad.
    self.ad = nil;
}

- (void)timerDidComplete {
    // The fullscreen ad will reward the user.
    if (self.isRewarded) {
        [self.delegate fullscreenAdWillRewardUser];
    }
}

@end
