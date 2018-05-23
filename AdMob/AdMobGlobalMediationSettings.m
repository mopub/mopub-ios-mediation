#import "AdMobGlobalMediationSettings.h"

@implementation AdMobGlobalMediationSettings

- (void)setNpaPref: (NSString *) pref {
    [[NSUserDefaults standardUserDefaults] setObject:pref forKey:@"npaPref"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
