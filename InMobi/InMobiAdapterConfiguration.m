//
//  InMobiAdapterConfiguration.m
//  MoPub
//
//  Copyright © 2021 MoPub. All rights reserved.
//

#import "InMobiAdapterConfiguration.h"
#import <InMobiSDK/IMSdk.h>

#if __has_include("MoPub.h")
    #import "MPLogging.h"
    #import "MPConstants.h"
#endif

@implementation InMobiAdapterConfiguration

#pragma mark - MPAdapterConfiguration

- (NSString *)adapterVersion {
    return @"9.1.2.0";
}

- (NSString *)biddingToken {
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    [paramsDict setObject:@"c_mopub" forKey:@"tp"];
    [paramsDict setObject:MP_SDK_VERSION forKey:@"tp-ver"];
    return [IMSdk getTokenWithExtras:paramsDict andKeywords:nil];
}

- (NSString *)moPubNetworkName {
    return @"inmobi";
}

- (NSString *)networkSdkVersion {
    return [IMSdk getVersion];
}

NSString * const kIMErrorDomain = @"com.inmobi.mopubcustomevent.iossdk";
NSString * const kIMPlacementIdKey = @"placementid";
NSString * const kIMAccountIdKey   = @"accountid";

static const NSString * IM_MPADAPTER_GDPR_CONSENT_AVAILABLE = @"gdpr_consent_available";
static const NSString * IM_MPADAPTER_GDPR_CONSENT_APPLICABLE = @"gdpr";
static const NSString * IM_MPADAPTER_GDPR_CONSENT_IAB = @"gdpr_consent";

NSDictionary * userConsentDictionary;

static BOOL isInMobiSDKInitialized = false;

+ (BOOL)isInMobiSDKInitialized {
    return isInMobiSDKInitialized;
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> *)configuration
                                  complete:(void(^)(NSError *))complete {
    NSString * const accountId = configuration[kIMAccountIdKey];
    
    NSError *accountIdError = [InMobiAdapterConfiguration validateAccountId:accountId forOperation:@"initialization"];
    if (accountIdError) {
        MPLogInfo(@"InMobi adapters will attempt lazy initialization upon first ad request instead. Make sure InMobi Account Id info is present on the MoPub UI.");
        isInMobiSDKInitialized = false;
        complete(accountIdError);
    } else {
        [InMobiAdapterConfiguration initializeInMobiSDK:accountId];
        complete(nil);
    }
}

+ (void)initializeInMobiSDK:(NSString *)accountId {
    if(!isInMobiSDKInitialized) {
        NSDictionary * gdprConsentObject = [self getGDPRConsentDictionary];
        [IMSdk setLogLevel:[self getInMobiLoggingLevelFromMopubLogLevel:[MPLogging consoleLogLevel]]];
        
        IMCompletionBlock completionBlock = ^{
            [IMSdk initWithAccountID:accountId consentDictionary:gdprConsentObject andCompletionHandler:nil];
        };
        [InMobiAdapterConfiguration invokeOnMainThreadAsSynced:YES withCompletionBlock:completionBlock];
        
        MPLogInfo(@"InMobi SDK initialized successfully.");
        isInMobiSDKInitialized = true;
    } else {
        MPLogInfo(@"InMobi SDK already initialized, no need to reinitialize.");
    }
}

+ (void)updateGDPRConsent {
    [IMSdk updateGDPRConsent:[self getGDPRConsentDictionary]];
}

#pragma mark - InMobiAdapterConfiguration Error Handling Methods

+ (NSError *)validateAccountId:(NSString *)accountId forOperation:(NSString *)operation {
    accountId = [accountId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (accountId != nil && accountId.length > 0 && ([accountId length] == 32 || [accountId length] == 36)) {
        return nil;
    }
    
    NSError * error = [self createErrorForOperation:operation forParameterName:kIMAccountIdKey];
    return error;
}

+ (NSError *)validatePlacementId:(NSString *)placementId forOperation:(NSString *)operation {
    if (placementId == nil || placementId.length <= 0) {
        NSError * error = [self createErrorForOperation:operation forParameterName:kIMPlacementIdKey];
        return error;
    }
    
    long long placementIdLong = [placementId longLongValue];
    if (placementIdLong <= 0) {
        NSError * error = [self createErrorForOperation:operation forParameterName:kIMPlacementIdKey];
        return error;
    }
    
    return nil;
}

+ (NSError *)createErrorForOperation:(NSString *)operation forParameterName:(NSString *)parameterName {
    if (parameterName == nil) {
        parameterName = @"InMobi Account Id and/or Placement Id";
    }
    
    NSString * description = [NSString stringWithFormat:@"InMobi adapter unable to proceed with %@", operation];
    NSString * reason      = [NSString stringWithFormat:@"%@ is nil/empty", parameterName];
    NSString * suggestion  = [NSString stringWithFormat:@"Make sure the InMobi's %@ is configured on the MoPub UI.", parameterName];
    
    return [InMobiAdapterConfiguration createErrorWith:description
                                               andReason:reason
                                           andSuggestion:suggestion];
}

+ (NSError *)createErrorWith:(NSString *)description andReason:(NSString *)reason andSuggestion:(NSString *)suggestion {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey            : NSLocalizedString(description, nil),
                               NSLocalizedFailureReasonErrorKey     : NSLocalizedString(reason, nil),
                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(suggestion, nil)
                               };

    MPLogDebug(@"%@. %@. %@", description, reason, suggestion);
    
    return [NSError errorWithDomain:kIMErrorDomain
                               code:0
                           userInfo:userInfo];
}

+ (IMSDKLogLevel)getInMobiLoggingLevelFromMopubLogLevel:(MPBLogLevel)logLevel
{
    switch (logLevel) {
        case MPBLogLevelDebug:
            return kIMSDKLogLevelDebug;
        case MPBLogLevelInfo:
            return kIMSDKLogLevelError;
        case MPBLogLevelNone:
            return kIMSDKLogLevelNone;
    }
    return kIMSDKLogLevelNone;
}

#pragma mark - InMobiAdapterConfiguration SDK Demographics Params Setup

// Edit this method to pass custom demographic params on InMobi adapters
+ (void)setupInMobiSDKDemographicsParams:(NSString *)accountId {
    /*
    Sample for setting up the InMobi SDK Demographic params.
    Publisher need to set the values of params as they want.
    
    [IMSdk setAreaCode:@"1223"];
    [IMSdk setEducation:kIMSDKEducationHighSchoolOrLess];
    [IMSdk setGender:kIMSDKGenderMale];
    [IMSdk setAge:12];
    [IMSdk setPostalCode:@"234"];
    [IMSdk setLocationWithCity:@"BAN" state:@"KAN" country:@"IND"];
    [IMSdk setLanguage:@"ENG"];
    */
}

#pragma mark - InMobiAdapterConfiguration GDPR Consent

/**
 * @discussion Use this method to pass the consent dictionary which has to be consumed by the InMobi SDK
 * The following keys are currently supported by the InMobi SDK and are available as a const NSStirng as part of the adapter
 * 1) IM_MPADAPTER_GDPR_CONSENT_AVAILABLE = Use this key to set the Boolean consent as given by the user
 * 2) IM_MPADAPTER_GDPR_CONSENT_APPLICABLE = Use this key to indicate whether GDPR is applicable for this user
 * 3) IM_MPADAPTER_GDPR_CONSENT_IAB = Usde this key to set the IAB GDPR Consent string
 * This method can be invoked multiple times during a session  to update the consent as required
 *
 * @param consentDictionary An NSDictionary object which contains the user's consent
 */
+ (void)setGDPRConsentDictionary:(NSDictionary *)consentDictionary {
    userConsentDictionary = consentDictionary;
}

/**
 * @discussion Use this method to read the currently set ConsentDictionary.
 * @return A NSDictionary instance which was set using setGDPRConsentDictionary: method or nil, otherwise
 */
+ (NSDictionary *)getGDPRConsentDictionary {
    return userConsentDictionary;
}

+ (void)invokeOnMainThreadAsSynced:(BOOL)sync withCompletionBlock:(IMCompletionBlock)compBlock {
    if (sync) {
        if ([[NSThread currentThread] isMainThread]) {
            compBlock();
        } else {
            dispatch_sync(dispatch_get_main_queue(), compBlock);
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), compBlock);
    }
}

@end
