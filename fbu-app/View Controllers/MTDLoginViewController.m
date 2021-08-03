//
//  MTDLoginViewController.m
//  fbu-app
//
//  Created by mwen on 7/12/21.
//

#import "MTDLoginViewController.h"
#import "Parse/Parse.h"
#import "MTDUser.h"

@interface MTDLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordLabel;
@end

@implementation MTDLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (IBAction)onTapLogin:(id)sender {
    NSString *email = self.emailLabel.text;
    NSString *password = self.passwordLabel.text;
    
    [MTDUser logInWithUsernameInBackground:email password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            NSLog(@"User log in failed: %@", error.localizedDescription);
            [self alertUserOfError];
            
        } else {
            [self performSegueWithIdentifier:@"loggedInSegue" sender:nil];
        }
    }];
}

- (void)alertUserOfError {
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
}

- (void)dismissKeyboard {
    [self.emailLabel resignFirstResponder];
    [self.passwordLabel resignFirstResponder];
}

@end
