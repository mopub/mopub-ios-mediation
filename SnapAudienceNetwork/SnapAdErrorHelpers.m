#import "SnapAdErrorHelpers.h"
#import <SAKSDK/SAKSDK.h>

NSError *SnapAdCreateError(Class domainClass, NSString *description, NSString *reason, NSString *suggestion)
{
    NSDictionary<NSErrorUserInfoKey, id> *userInfo = @{
        NSLocalizedDescriptionKey: NSLocalizedString(description, nil),
        NSLocalizedFailureReasonErrorKey: NSLocalizedString(reason, nil),
        NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(suggestion, nil)
    };
    return [NSError errorWithDomain:NSStringFromClass(domainClass) code:0 userInfo:userInfo];
}

NSString *SnapAdErrorDescription(NSError *error)
{
    NSString *errorDescription;
    switch (error.code) {
        case SAKErrorNetworkError:
            errorDescription = @"SAKErrorNetworkError";
            break;
        case SAKErrorNotEligible:
            errorDescription = @"SAKErrorNotEligible";
            break;
        case SAKErrorFailedToParse:
            errorDescription = @"SAKErrorFailedToParse";
            break;
        case SAKErrorSDKNotInitialized:
            errorDescription = @"SAKErrorSDKNotInitialized";
            break;
        case SAKErrorNoAdAvailable:
            errorDescription = @"SAKErrorNoAdAvailable";
            break;
        case SAKErrorCodeNoCreativeEndpoint:
            errorDescription = @"SAKErrorCodeNoCreativeEndpoint";
            break;
        case SAKErrorCodeMediaDownloadError:
            errorDescription = @"SAKErrorCodeMediaDownloadError";
            break;
        case SAKErrorFailedToRegister:
            errorDescription = @"SAKErrorFailedToRegister";
            break;
        case SAKErrorAdsDisabled:
            errorDescription = @"SAKErrorAdsDisabled";
            break;
        default:
            errorDescription = @"Snap Ad Kit Unknown Error";
    }
    return errorDescription;
}
