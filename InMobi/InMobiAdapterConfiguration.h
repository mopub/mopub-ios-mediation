//
//  InMobiAdapterConfiguration.h
//  MoPub
//
//  Copyright © 2021 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
    #import <MoPubSDK/MoPub.h>
#else
    #import "MPBaseAdapterConfiguration.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface InMobiAdapterConfiguration : MPBaseAdapterConfiguration

@property (nonatomic, copy, readonly) NSString * adapterVersion;
@property (nonatomic, copy, readonly) NSString * biddingToken;
@property (nonatomic, copy, readonly) NSString * moPubNetworkName;
@property (nonatomic, copy, readonly) NSString * networkSdkVersion;

typedef enum {
    kIMIncorrectAccountID,
    kIMIncorrectPlacemetID
} IMErrorCode;

extern NSString * const kIMErrorDomain;
extern NSString * const kIMPlacementIdKey;
extern NSString * const kIMAccountIdKey;

+ (BOOL)isInMobiSDKInitialized;

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> * _Nullable)configuration
                                  complete:(void(^ _Nullable)(NSError * _Nullable))complete;

+ (void)initializeInMobiSDK:(NSString *)accountId;

+ (NSError *)validateAccountId:(NSString *)accountId forOperation:(NSString *)operation;

+ (NSError *)validatePlacementId:(NSString *)placementId forOperation:(NSString *)operation;

+ (NSError *)createInitializationError:(NSString *)operation;

+ (NSError *)createErrorForOperation:(NSString *)operation forParameterName:(NSString *)parameterName;

+ (NSError *)createErrorWith:(NSString *)description andReason:(NSString *)reason andSuggestion:(NSString *)suggestion;

+ (void)setupInMobiSDKDemographicsParams:(NSString *)accountId;

typedef void (^IMCompletionBlock)(void);

+ (void)invokeOnMainThreadAsSynced:(BOOL)sync withCompletionBlock:(IMCompletionBlock)compBlock;

@end

NS_ASSUME_NONNULL_END
