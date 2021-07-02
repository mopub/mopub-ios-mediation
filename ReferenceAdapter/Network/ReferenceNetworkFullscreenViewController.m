//
//  ReferenceNetworkFullscreenViewController.m
//  MoPub-Reference-Adapters
//
//  Created by Kelly Dun on 3/1/21.
//

#import "ReferenceNetworkFullscreenViewController.h"

@interface ReferenceNetworkFullscreenViewController ()
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIImageView *creative;
@property (nonatomic, assign) BOOL firstAppearanceDone;
@end

@implementation ReferenceNetworkFullscreenViewController

#pragma mark - Initialization

- (instancetype)initWithCreative:(UIImageView *)creative {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _closeButton = nil;
        _creative = creative;
        _creative.translatesAutoresizingMaskIntoConstraints = NO;
        _firstAppearanceDone = NO;
    }
    
    return self;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Configure view
    self.view.backgroundColor = UIColor.blackColor;
    
    // Place the creative.
    [self.view addSubview:self.creative];
    
    // Load the close button and place it disbaled and hidden.
    UIImage *closeButtonImage = [UIImage imageNamed:@"CloseButton" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.enabled = NO;
    button.hidden = YES;
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button addTarget:self action:@selector(onCloseButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:closeButtonImage forState:UIControlStateNormal];
    self.closeButton = button;
    
    [self.view addSubview:button];
    
    // Determine the margins to use.
    UILayoutGuide *margins = self.view.layoutMarginsGuide;
    if (@available(iOS 11.0, *)) {
        margins = self.view.safeAreaLayoutGuide;
    }
    
    // Activate constraints at once.
    NSArray<NSLayoutConstraint *> *constraints = @[
        [self.creative.leadingAnchor constraintEqualToAnchor:margins.leadingAnchor],
        [self.creative.trailingAnchor constraintEqualToAnchor:margins.trailingAnchor],
        [self.creative.topAnchor constraintEqualToAnchor:margins.topAnchor],
        [self.creative.bottomAnchor constraintEqualToAnchor:margins.bottomAnchor],
        [self.closeButton.leadingAnchor constraintEqualToAnchor:margins.leadingAnchor constant:5],
        [self.closeButton.topAnchor constraintEqualToAnchor:margins.topAnchor constant:5],
        [self.closeButton.widthAnchor constraintEqualToConstant:50],
        [self.closeButton.heightAnchor constraintEqualToConstant:50],
    ];
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // The following code should only be executed on the first
    // appearance.
    if (self.firstAppearanceDone == YES) {
        return;
    }
    
    // Block enabling the close button.
    __typeof__(self) __weak weakSelf = self;
    void (^enableCloseButton)(void) = ^void() {
        __typeof__(self) strongSelf = weakSelf;
        strongSelf.closeButton.enabled = YES;
        strongSelf.closeButton.hidden = NO;
    };

    // Start the timer.
    if (self.closeButtonDelay > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.closeButtonDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __typeof(self) strongSelf = weakSelf;
            [strongSelf.delegate timerDidComplete];

            enableCloseButton();
        });
    }
    // Show close button immediately.
    else {
        enableCloseButton();
    }
    
    // Complete the first appearance section.
    self.firstAppearanceDone = YES;
        
    // Notify the first appearance.
    [self.delegate didAppear];
}

#pragma mark - Button Events

- (void)onCloseButtonPressed {
    [self.delegate didTapClose];
}

@end
