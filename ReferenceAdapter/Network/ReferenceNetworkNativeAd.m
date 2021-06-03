//
//  ReferenceNativeAd.m
//  MoPub-Reference-Adapters
//
//  Created by Kelly Dun on 3/3/21.
//

#import "ReferenceNetworkNativeAd.h"
#import "NSError+ReferenceNetwork.h"

@interface ReferenceNetworkNativeAd()
@property (nonatomic, strong, nullable) UIImage *cachedCreative;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, copy) NSString *placement;
@end

@implementation ReferenceNetworkNativeAd

#pragma mark - Initialization

- (instancetype)initWithPlacement:(NSString *)placement {
    if (self = [super init]) {
        _isLoading = NO;
        _placement = placement;
        
        // Cache the creative.
        _cachedCreative = [UIImage imageNamed:@"MediumRectangle336x280" inBundle:self.resourceBundle compatibleWithTraitCollection:nil];
    }
    
    return self;
}

#pragma mark - Simulated Ad Loading

- (void)load {
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
        
        UIImageView *creative = strongSelf.cachedCreative != nil ? [[UIImageView alloc] initWithImage:strongSelf.cachedCreative] : nil;
        creative.contentMode = UIViewContentModeCenter;
        creative.userInteractionEnabled = YES;
        [creative addGestureRecognizer:recognizer];
        
        // Generate the fake assets
        ReferenceNetworkNativeAssets *assets = [[ReferenceNetworkNativeAssets alloc] init];
        assets.callToActionText = @"Click me!";
        assets.clickthrough = @"https://www.mopub.com";
        assets.creative = creative;
        assets.text = @"Test description";
        assets.title = @"Reference Native Ad";
        
        // Report the load result.
        if (creative != nil) {
            [strongSelf.delegate nativeAdDidLoad:assets];
        }
        else {
            NSError *error = [NSError failedToLoadImage:@"MediumRectangle336x280"];
            [strongSelf.delegate nativeAdDidFailToLoad:error];
        }
    });
}

#pragma mark - Gesture Recognizers

- (void)onCreativeTapped {
    [self.delegate nativeAdDidClick];
}

@end
