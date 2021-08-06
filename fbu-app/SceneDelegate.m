//
//  SceneDelegate.m
//  fbu-app
//
//  Created by mwen on 7/12/21.
//

#import "SceneDelegate.h"
#import "Parse/Parse.h"

@interface SceneDelegate ()
@end

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    ParseClientConfiguration *config = [ParseClientConfiguration  configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {

            configuration.applicationId = @"HGQvhLmE9R4DCSEYQRsvWzU6QZgMYNoUllXVYNLS";
            configuration.clientKey = @"aitdkgyAW5U3ciAbTYLOioiT8kfviLtGLVj2IwGE";
            configuration.server = @"https://parseapi.back4app.com";
        }];

        [Parse initializeWithConfiguration:config];
    
    if (PFUser.currentUser) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    }
}

@end
