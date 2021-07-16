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
#import "Group.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *userPFPView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //    definesPresentationContext = true
    self.userNameLabel.text = PFUser.currentUser.username;
}

- (IBAction)onTapAddPlatform:(id)sender {
    //    Later need to allow the user multiple choices
    [self signInUser];
}

- (void)signInUser {
    NSURL *oAuthURL = [NSURL URLWithString:@"https://oauth.groupme.com/oauth/authorize?client_id=ArUTvcq7X9Nkt0xJTnkP1wPXfAuOCSNB3lE6ZvxbxGAdDKkr"];
    SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:oAuthURL];
    if (oAuthURL) {
        if ([SFSafariViewController class] != nil) {
            //            UIViewController *rootController = [UIApplication sharedApplication].keyWindow.rootViewController;
            //            [rootController presentViewController:sfvc animated:YES completion:nil];
            [self presentViewController:sfvc animated:YES completion:nil];
            
//            [APIManager getUserData];
//            I think my logged in is saved from before
//            Only the top group is preseent and half of it
//            Want to remove this later
            NSMutableString *URLString = [[NSMutableString alloc] init];
            [URLString appendString:@"https://api.groupme.com/v3/users/me?token="];
            [URLString appendString:[APIManager getAuthToken]];
//            I think I'm just using my own getAuthToken, I need to be able to grab other peoples
            NSLog(@"%@", URLString);
            NSError* error = nil;
            NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:URLString] options:NSDataReadingUncached error:&error];
            NSDictionary *userData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

            [self updateUserwithPlatform:userData[@"response"][@"name"]];
        } else {
            NSLog(@"Oh no can't open url because no safari view controller");
        }
    } else {
        // will have a nice alert displaying soon.
    }
}

//potentially load all the conversations when the user first chooses, so it doesn't have to update the stuff at the verybeginnign (consistency in the remaining)
-(void) updateUserwithPlatform:(NSString*) name {
    PFUser *user = PFUser.currentUser;
    
    user[@"GroupMe"] =  @{}.mutableCopy;
    user[@"GroupMe"][@"name"] = name;
    user[@"GroupMe"][@"readConversations"] = [[NSMutableArray alloc]init];
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
