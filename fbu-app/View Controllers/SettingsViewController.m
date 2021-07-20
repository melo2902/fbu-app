//
//  SettingsViewController.m
//  fbu-app
//
//  Created by mwen on 7/12/21.
//

#import "SettingsViewController.h"
#import "SceneDelegate.h"
#import "LoginViewController.h"
#import "APIManager.h"
#import "Parse/Parse.h"
#import "Platform.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *userPFPView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.userNameLabel.text = PFUser.currentUser.username;
}

- (IBAction)onTapAddPlatform:(id)sender {
    // Later allow users to have multiple choices
    [self signInUser];
}

- (void)signInUser {
    NSURL *oAuthURL = [NSURL URLWithString:@"https://oauth.groupme.com/oauth/authorize?client_id=ArUTvcq7X9Nkt0xJTnkP1wPXfAuOCSNB3lE6ZvxbxGAdDKkr"];
    SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:oAuthURL];
    if (oAuthURL) {
        if ([SFSafariViewController class] != nil) {
            [self presentViewController:sfvc animated:YES completion:nil];
            
            NSMutableString *URLString = [[NSMutableString alloc] init];
            [URLString appendString:@"https://api.groupme.com/v3/users/me?token="];
            [URLString appendString:[APIManager getAuthToken]];

            NSError* error = nil;
            NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:URLString] options:NSDataReadingUncached error:&error];
            NSDictionary *userData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

            Platform *newPlatform = [[Platform alloc] initWithJSONData:userData onPlatform: @"GroupMe"];
            [self updateUser:newPlatform withPlatform: @"GroupMe"];
            
        } else {
            NSLog(@"Oh no can't open url because no safari view controller");
        }
    } else {
        // will have a nice alert displaying soon.
    }
}

-(void) updateUser:(Platform*) platform withPlatform: (NSString*) name {
    PFUser *user = PFUser.currentUser;
    user[name] = platform;
    
    [user saveInBackground];
}

- (IBAction)onTapLogOut:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
    }];
    
    SceneDelegate *sceneDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    sceneDelegate.window.rootViewController = loginViewController;
}

@end
