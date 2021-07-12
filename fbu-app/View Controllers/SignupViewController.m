//
//  SignupViewController.m
//  fbu-app
//
//  Created by mwen on 7/12/21.
//

#import "SignupViewController.h"
#import "Parse/Parse.h"

@interface SignupViewController ()
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;
@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];

    [self.view addGestureRecognizer:tap];
}

- (IBAction)onTapSignUp:(id)sender {
    if ([self.passwordField.text isEqualToString:self.confirmPasswordField.text]){
        
        // initialize a user object
        PFUser *newUser = [PFUser user];
        
        // set user properties
        newUser.username = [NSString stringWithFormat:@"%@ %@", self.firstNameField.text, self.lastNameField.text];
        newUser[@"firstName"] = self.firstNameField.text;
//        newUser.email = self.emailField.text;
        newUser[@"lastName"] = self.lastNameField.text;
        newUser.password = self.passwordField.text;
        
        // call sign up function on the object
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
            if (error != nil) {
                NSLog(@"Error: %@", error.localizedDescription);
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sign Up Failed"
                    message:@"The username is already taken!"
                    preferredStyle:(UIAlertControllerStyleAlert)];
                
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                    style:UIAlertActionStyleDefault
                    handler:^(UIAlertAction * _Nonnull action) {
                }];

                [alert addAction:okAction];
                
                [self presentViewController:alert animated:YES completion:^{
                }];
            } else {
                NSLog(@"User registered successfully");
                
                // manually segue to logged in view
                [self performSegueWithIdentifier:@"signedUpSegue" sender:nil];
            }
        }];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sign Up Failed"
            message:@"Please input matching passwords!"
            preferredStyle:(UIAlertControllerStyleAlert)];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
            style:UIAlertActionStyleDefault
            handler:^(UIAlertAction * _Nonnull action) {
        }];

        [alert addAction:okAction];
        
        [self presentViewController:alert animated:YES completion:^{
        }];
    }
}

-(void)dismissKeyboard {
    [self.firstNameField resignFirstResponder];
    [self.lastNameField resignFirstResponder];
    [self.emailField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.confirmPasswordField resignFirstResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)emailLabel:(id)sender {
}
@end
