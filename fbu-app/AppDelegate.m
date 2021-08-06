//
//  AppDelegate.m
//  fbu-app
//
//  Created by mwen on 7/12/21.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
#import "Parse/Parse.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNAuthorizationOptions options = UNAuthorizationOptionAlert + UNAuthorizationOptionSound + UNAuthorizationOptionBadge + UNAuthorizationOptionCarPlay;
    
    [center requestAuthorizationWithOptions:options
     completionHandler:^(BOOL granted, NSError * _Nullable error) {
      if (!granted) {
        NSLog(@"User did not grant access");
      }
    }];
    
    return YES;
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

@end
