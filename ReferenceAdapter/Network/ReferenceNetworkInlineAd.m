//
//  ReferenceNetworkBanner.m
//  MoPub-Reference-Adapters
//
//  Created by Kelly Dun on 3/1/21.
//

#import "NSError+ReferenceNetwork.h"
#import "ReferenceNetworkInlineAd.h"

@interface ReferenceNetworkInlineAd()
@property (nonatomic, strong, nullable) UIImageView *ad;
@property (nonatomic, strong, nullable) UIImage *cachedCreative;
@property (nonatomic, copy) NSString *creativeImageName;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, copy) NSString *placement;
@end

@implementation ReferenceNetworkInlineAd

#pragma mark - Initialization

- (instancetype)initWithPlacement:(NSString *)placement isMediumRectangle:(BOOL)isMediumRectangle {
    if (self = [super init]) {
        _ad = nil;
        _delegate = nil;
        _isLoading = NO;
        _placement = placement;
        
        // Cache the creative.
        _creativeImageName = (isMediumRectangle ? @"MediumRectangle300x250" : @"Banner320x50");
        _cachedCreative = [UIImage imageNamed:_creativeImageName inBundle:self.resourceBundle compatibleWithTraitCollection:nil];
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
        strongSelf.ad = inlineAd;
        
        // Report the load result.
        if (strongSelf.ad != nil) {
            [strongSelf.delegate inlineAdDidLoad];
        }
        else {
            NSError *error = [NSError failedToLoadImage:strongSelf.creativeImageName];
            [strongSelf.delegate inlineAdDidFailToLoad:error];
        }
    });
}

- (void)show {
    if (self.ad != nil) {
        [self.delegate inlineAdDidShow:self.ad];
        [self.delegate inlineAdImpressionTracked];
        
        // Clear out ad once it's been shown
        self.ad = nil;
    }
    else {
        NSError *error = [NSError failedToShowImage:@"no ad loaded"];
        [self.delegate inlineAdDidFailToShow:error];
    }
}

#pragma mark - Gesture Recognizers

- (void)onCreativeTapped {
    [self.delegate inlineAdClicked];
    
    NSURL *clickthroughUrl = [NSURL URLWithString:@"https://www.mopub.com"];
    [UIApplication.sharedApplication openURL:clickthroughUrl options:@{} completionHandler:^(BOOL success) {
        // no-op
    }];
}

@end
