//
//  SignupViewController.m
//  fbu-app
//
//  Created by mwen on 7/12/21.
//

#import "SignupViewController.h"
#import "Parse/Parse.h"
#import "MTDList.h"

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
    [PFUser logOut];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

# pragma mark - sign up user

- (IBAction)onTapSignUp:(id)sender {
    if ([self.passwordField.text isEqualToString:self.confirmPasswordField.text]){
        PFUser* newUser = [self initializeUser];
        
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
            if (error != nil) {
                NSLog(@"Error: %@", error.localizedDescription);
                [self alertUserOfError:@"The username is already taken!" withTitle:@"Sign up Failed"];
            } else {
                [self performSegueWithIdentifier:@"signedUpSegue" sender:nil];
            }
        }];
    } else {
        [self alertUserOfError:@"Please input matching passwords!" withTitle:@"Sign up Failed"];
    }
}

- (PFUser *) initializeUser {
    PFUser *newUser = [PFUser user];
    
    newUser.username = [NSString stringWithFormat:@"%@ %@", self.firstNameField.text, self.lastNameField.text];
    newUser[@"firstName"] = self.firstNameField.text;
    newUser.email = self.emailField.text;
    newUser[@"lastName"] = self.lastNameField.text;
    newUser.password = self.passwordField.text;
    
    NSMutableArray *preDefinedLists = [[NSMutableArray alloc] init];
    [self createPredefinedLists:@"My Day" toList:preDefinedLists];
    [self createPredefinedLists:@"My Tomorrow" toList:preDefinedLists];
    [self createPredefinedLists:@"All" toList:preDefinedLists];
    
    newUser[@"lists"] = preDefinedLists;
    
    return newUser;
}

- (void)createPredefinedLists:(NSString *) name toList:(NSMutableArray *) definedList {
    MTDList *newList = [MTDList createList:name ifDefault: YES withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
    }];
    [definedList addObject:newList];
}

# pragma mark - alert error

- (void)alertUserOfError: (NSString *) message withTitle: (NSString *) title {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:^{
    }];
}

-(void)dismissKeyboard {
    [self.firstNameField resignFirstResponder];
    [self.lastNameField resignFirstResponder];
    [self.emailField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.confirmPasswordField resignFirstResponder];
}

@end
