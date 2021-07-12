//
//  LoginViewController.m
//  fbu-app
//
//  Created by mwen on 7/12/21.
//

#import "LoginViewController.h"
#import "Parse/Parse.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordLabel;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)onTapLogin:(id)sender {
    NSString *email = self.emailLabel.text;
    NSString *password = self.passwordLabel.text;
    
//    Check if we can do logInwithEmail
    [PFUser logInWithUsernameInBackground:email password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            NSLog(@"User log in failed: %@", error.localizedDescription);
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Log In Failed"
                message:@"Check to make sure that your username and password are valid!"
                preferredStyle:(UIAlertControllerStyleAlert)];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                style:UIAlertActionStyleDefault
                handler:^(UIAlertAction * _Nonnull action) {
            }];
            
            [alert addAction:okAction];
            
            [self presentViewController:alert animated:YES completion:^{
            }];
            
        } else {
            NSLog(@"User logged in successfully");
            
            // display view controller that needs to shown after successful login
            [self performSegueWithIdentifier:@"loggedInSegue" sender:nil];
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)usernameLabel:(id)sender {
}
@end
