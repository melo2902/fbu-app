//
//  APIManager.m
//  fbu-app
//
//  Created by mwen on 7/13/21.
//

#import "APIManager.h"

@implementation APIManager
#pragma mark - Auth
// Currently implemented in Settings View Controllers
+ (void)signInUser {
    NSURL *oAuthURL = [NSURL URLWithString:@"https://oauth.groupme.com/oauth/authorize?client_id=ArUTvcq7X9Nkt0xJTnkP1wPXfAuOCSNB3lE6ZvxbxGAdDKkr"];
    SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:oAuthURL];
    if (oAuthURL) {
        if ([SFSafariViewController class] != nil) {
            UIViewController *rootController = [UIApplication sharedApplication].keyWindow.rootViewController;
            [rootController presentViewController:sfvc animated:YES completion:nil];
//            [self presentViewController:sfvc animated:YES completion:nil];
        } else {
            NSLog(@"Oh no can't open url because no safari view controller");
        }
    } else {
        // will have a nice alert displaying soon.
    }
}

//+ (BOOL)isLoggedIn {
//    if ([Lockbox unarchiveObjectForKey:@"oAuthToken"]) {
//        return YES;
//    }
//    return NO;
//}

+ (NSString *)getAuthToken {
    return @"KPap1zhC20J3k7gL2baYtAF1p4SelSZRAYfgNBVK";
//    if ([AccountManager isLoggedIn]) {
//        return [Lockbox unarchiveObjectForKey:@"oAuthToken"];
//    } else {
//        [NSException raise:@"GroupMe Not logged in" format:@"User is not logged in to GroupMe"];
//    }
//    return nil;
}

+ (NSDictionary *)getUserData {
//    NSAssert([AccountManager isLoggedIn], @"Error! User must be logged in before attempting to access data");
//    if (![Lockbox unarchiveObjectForKey:@"userData"]) {
    NSMutableString *URLString = [[NSMutableString alloc] init];
//    [URLString appendString:@"https://api.groupme.com/groups?token="];
    [URLString appendString:@"https://api.groupme.com/v3/users/me?token="];
    [URLString appendString:[APIManager getAuthToken]];
    NSError* error = nil;
    NSLog(@"%@", URLString);
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:URLString] options:NSDataReadingUncached error:&error];
    NSDictionary *userData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSLog(@"%@", userData);
    
    return userData;
//        [Lockbox archiveObject:[userData objectForKey:@"response"] forKey:@"userData"];
//    }
//    return [Lockbox unarchiveObjectForKey:@"userData"];
}
@end
