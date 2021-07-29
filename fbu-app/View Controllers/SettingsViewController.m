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

@interface SettingsViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *userPFPView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userEmailLabel;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.userNameLabel.text = PFUser.currentUser.username;
    self.userEmailLabel.text = PFUser.currentUser.email;
    
    if (PFUser.currentUser[@"pfp"]) {
       PFFileObject *pfp = PFUser.currentUser[@"pfp"];
       
       [pfp getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
           if (!error) {
               UIImage *originalImage = [UIImage imageWithData:imageData];
               self.userPFPView.image = originalImage;
               self.userPFPView.layer.cornerRadius = self.userPFPView.frame.size.width / 2;
               self.userPFPView.clipsToBounds = true;
           }
       }];
    }
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
            [URLString appendString:[APIManager returnAuthToken]];

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

- (IBAction)editProfilePicture:(id)sender {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    
    // The Xcode simulator does not support taking pictures, so let's first check that the camera is indeed supported on the device before trying to present it.
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // Need to present an alert to let users choose which method they use
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        NSLog(@"Camera 🚫 available so we will use photo library instead");
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    
    self.userPFPView.image = [self resizeImage:editedImage withSize: CGSizeMake(100, 100)];
    PFUser.currentUser[@"pfp"] = [self getPFFileFromImage:self.userPFPView.image];
    [PFUser.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Did not save correctly");
        }
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
    
    if (!image) {
        return nil;
    }
    
    NSData *imageData = UIImagePNGRepresentation(image);
    if (!imageData) {
        return nil;
    }
    
    return [PFFileObject fileObjectWithData:imageData];
}

- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (IBAction)onTapBackButton:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
