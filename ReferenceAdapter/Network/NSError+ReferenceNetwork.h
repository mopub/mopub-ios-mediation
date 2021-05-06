//
//  NSError+ReferenceNetwork.h
//  MoPub-Reference-Adapters
//
//  Created by Kelly Dun on 3/1/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSError (ReferenceNetwork)

+ (NSError *)failedToLoadImage:(NSString *)imageName;
+ (NSError *)failedToLoadViewController;
+ (NSError *)failedToShowImage:(NSString *)reason;
+ (NSError *)noPlacementId;

@end

NS_ASSUME_NONNULL_END
