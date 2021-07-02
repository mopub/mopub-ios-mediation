#import "TapjoyAdapterConfiguration.h"
#import "TapjoyGlobalMediationSettings.h"
#import <Tapjoy/Tapjoy.h>
#if __has_include("MoPub.h")
#import "MoPub.h"
#endif

// Initialization configuration keys
static NSString * const kTapjoySdkKey       = @"sdkKey";
static NSString * const kTapjoyDebugEnabled = @"debugEnabled";

// Errors
static NSString * const kAdapterErrorDomain = @"com.mopub.mopub-ios-sdk.mopub-tapjoy-adapters";

typedef NS_ENUM(NSInteger, TapjoyAdapterErrorCode) {
    TapjoyAdapterErrorCodeMissingSdkKey,
    TapjoyAdapterErrorCodeFailedToConnect,
};

@interface TapjoyAdapterConfiguration()
@property (nonatomic, assign) BOOL isConnecting;
@property (nonatomic, copy) void(^initializationCompleteBlock)(NSError *);
@end

@implementation TapjoyAdapterConfiguration

#pragma mark - Caching

+ (void)updateInitializationParameters:(NSDictionary *)parameters {
    // These should correspond to the required parameters checked in
    // `initializeNetworkWithConfiguration:complete:`
    NSString * sdkKey = parameters[kTapjoySdkKey];
    BOOL isDebugEnabled = [parameters[kTapjoyDebugEnabled] boolValue];
    
    if (sdkKey != nil) {
        NSDictionary * configuration = @{ kTapjoySdkKey: sdkKey, kTapjoyDebugEnabled: (isDebugEnabled ? @"1" : @"0") };
        [TapjoyAdapterConfiguration setCachedInitializationParameters:configuration];
    }
}

#pragma mark - MPAdapterConfiguration

- (NSString *)adapterVersion {
    return @"12.8.1.0";
}

- (NSString *)biddingToken {
    NSString *token = [Tapjoy getUserToken];
    return (token.length > 0 ? token : @"1");
}

- (NSString *)moPubNetworkName {
    // ⚠️ Do not change this value! ⚠️
    return @"tapjoy";
}

- (NSString *)networkSdkVersion {
    return [Tapjoy getVersion];
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> *)configuration
                                  complete:(void(^)(NSError *))complete {
    // Tapjoy SDK is already initialized.
    if ([Tapjoy isConnected]) {
        if (complete != nil) {
            complete(nil);
        }
        return;
    }
    
    // Instantiate Mediation Settings
    TapjoyGlobalMediationSettings * mediationSettings = [MoPub.sharedInstance globalMediationSettingsForClass:TapjoyGlobalMediationSettings.class];
    
    // Grab sdkKey and connect flags defined in MoPub dashboard
    NSString * sdkKey = configuration[kTapjoySdkKey];
    BOOL enableDebug = [configuration[kTapjoyDebugEnabled] boolValue];
    
    // Initialize from global mediation settings
    if (mediationSettings.sdkKey != nil) {
        MPLogInfo(@"Connecting to Tapjoy via MoPub mediation settings");
        [self setupListeners];
        self.initializationCompleteBlock = complete;
        [Tapjoy connect:mediationSettings.sdkKey options:mediationSettings.connectFlags];
        
        self.isConnecting = YES;
        
    }
    // Initialize from inputted configuration settings
    else if (sdkKey != nil) {
        MPLogInfo(@"Connecting to Tapjoy via MoPub dashboard settings");
        NSMutableDictionary *connectOptions = [[NSMutableDictionary alloc] init];
        [connectOptions setObject:@(enableDebug) forKey:TJC_OPTION_ENABLE_LOGGING];
        [self setupListeners];
        self.initializationCompleteBlock = complete;
        [Tapjoy connect:sdkKey options:connectOptions];
        
        self.isConnecting = YES;
    }
    // Fail
    else {
        NSError * error = [NSError errorWithDomain:kAdapterErrorDomain code:TapjoyAdapterErrorCodeMissingSdkKey userInfo:@{ NSLocalizedDescriptionKey: @"Tapjoy adapter cannot initialize with an empty 'sdkKey'. Please check the dashboard to ensure that it is set." }];
        MPLogEvent([MPLogEvent error:error message:nil]);

        if (complete != nil) {
            complete(error);
        }
    }
    
    BOOL debugEnabled = (MPLogging.consoleLogLevel == MPBLogLevelDebug);

    [Tapjoy setDebugEnabled:debugEnabled];
}

#pragma mark - Tapjoy Initialization Helpers

- (void)setupListeners {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tjcConnectSuccess:)
                                                 name:TJC_CONNECT_SUCCESS
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tjcConnectFail:)
                                                 name:TJC_CONNECT_FAILED
                                               object:nil];
}

- (void)tjcConnectSuccess:(NSNotification *)notifyObj {
    MPLogInfo(@"Tapjoy connect Succeeded");
    self.isConnecting = NO;
    [self fetchMoPubGDPRSettings];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (self.initializationCompleteBlock != nil) {
        self.initializationCompleteBlock(nil);
        self.initializationCompleteBlock = nil;
    }
}

- (void)tjcConnectFail:(NSNotification *)notifyObj {
    NSError * error = [NSError errorWithDomain:kAdapterErrorDomain code:TapjoyAdapterErrorCodeFailedToConnect userInfo:@{ NSLocalizedDescriptionKey: @"Tapjoy connect Failed" }];
    MPLogEvent([MPLogEvent error:error message:nil]);
    
    self.isConnecting = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (self.initializationCompleteBlock != nil) {
        self.initializationCompleteBlock(error);
        self.initializationCompleteBlock = nil;
    }
}

// Collect latest MoPub GDPR settings and pass them to Tapjoy
- (void)fetchMoPubGDPRSettings {
    // If the GDPR applies setting is unknown, assume it has been skipped/unset
    MPBool gdprApplies = [MoPub sharedInstance].isGDPRApplicable;
    if (gdprApplies != MPBoolUnknown ) {
        //Turn the MPBool into a proper bool
        if(gdprApplies == MPBoolYes) {
            [[Tapjoy getPrivacyPolicy] setSubjectToGDPR:YES];
            
            NSString *consentString = [[MoPub sharedInstance] canCollectPersonalInfo] ? @"1" : @"0";
            [[Tapjoy getPrivacyPolicy] setUserConsent: consentString];
        } else {
            [[Tapjoy getPrivacyPolicy] setSubjectToGDPR:NO];
            [[Tapjoy getPrivacyPolicy] setUserConsent: @"-1"];
        }
    }
}

@end
