//
//  MTDXLSettingsViewController.m
//  fbu-app
//
//  Created by mwen on 8/4/21.
//

#import "MTDXLSettingsViewController.h"
#import "MTDUser.h"
#import "XLForm.h"
#import "SettingsHeaderView.h"
#import "SceneDelegate.h"
#import "MTDLoginViewController.h"
#import "MTDAPIManager.h"

@interface MTDXLSettingsViewController ()

@end

@implementation MTDXLSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont fontWithName:@"Avenir Book" size:17], NSFontAttributeName, nil];
    
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"SettingsHeaderView"];
    
    [self initializeForm];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    if (section == 0) {
        SettingsHeaderView *header = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"SettingsHeaderView"];

        MTDUser *user = [MTDUser currentUser];
        header.nameLabel.text = user.username;
        header.emailLabel.text = user.email;
        
        if (user.pfp) {
            PFFileObject *pfp = user.pfp;
           
           [pfp getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
               if (!error) {
                   UIImage *originalImage = [UIImage imageWithData:imageData];
                   header.userPFPView.image = originalImage;
                   header.userPFPView.layer.cornerRadius = header.userPFPView.frame.size.width / 2;
                   header.userPFPView.clipsToBounds = true;
               }
           }];
        }
        
        return header;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 170;
    } else if (section == 5) {
        return 10;
    }
    
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)initializeForm {
    XLFormDescriptor * form;
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;

    form = [XLFormDescriptor formDescriptorWithTitle:@"Add Event"];

    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];

    section = [XLFormSectionDescriptor formSection];
    section.title = @"MESSENGING PLATFORMS";
    [form addFormSection:section];
    
    if (![MTDAPIManager returnAuthToken]) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"version" rowType:XLFormRowDescriptorTypeSelectorPush title:@"GroupMe"];
        [row.cellConfig setObject:[UIFont fontWithName:@"Avenir Book" size:16] forKey:@"textLabel.font"];
        row.action.viewControllerStoryboardId = @"InitialFilterViewController";
        [section addFormRow:row];
    } else {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"version" rowType:XLFormRowDescriptorTypeSelectorPush title:@"GroupMe"];
        [row.cellConfig setObject:[UIFont fontWithName:@"Avenir Book" size:16] forKey:@"textLabel.font"];
        row.value = @"Connected";
        [section addFormRow:row];
    }
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"version" rowType:XLFormRowDescriptorTypeSelectorPush title:@"Slack"];
    [row.cellConfig setObject:[UIFont fontWithName:@"Avenir Book" size:16] forKey:@"textLabel.font"];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"version" rowType:XLFormRowDescriptorTypeSelectorPush title:@"Instagram Business"];
    [row.cellConfig setObject:[UIFont fontWithName:@"Avenir Book" size:16] forKey:@"textLabel.font"];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSection];
    section.title = @"GENERAL";
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"version" rowType:XLFormRowDescriptorTypeInfo title:@"Manage Account"];
    [row.cellConfig setObject:[UIFont fontWithName:@"Avenir Book" size:16] forKey:@"textLabel.font"];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"version" rowType:XLFormRowDescriptorTypeAccount title:@"Edit Profile Picture"];
    [row.cellConfig setObject:[UIFont fontWithName:@"Avenir Book" size:16] forKey:@"textLabel.font"];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"version" rowType:XLFormRowDescriptorTypeSelectorPush title:@"Update Notification Defaults"];
    [row.cellConfig setObject:[UIFont fontWithName:@"Avenir Book" size:16] forKey:@"textLabel.font"];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor  formSection];
    section.title = @"HELP & FEEDBACK";
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"version" rowType:XLFormRowDescriptorTypeSelectorPush title:@"Get Support"];
    [row.cellConfig setObject:[UIFont fontWithName:@"Avenir Book" size:16] forKey:@"textLabel.font"];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"privacyCookies" rowType:XLFormRowDescriptorTypeInfo title:@"Suggest a Platform"];
    [row.cellConfig setObject:[UIFont fontWithName:@"Avenir Book" size:16] forKey:@"textLabel.font"];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"exportYourInfo" rowType:XLFormRowDescriptorTypeInfo title:@"Copy Session and User ID"];
    [row.cellConfig setObject:[UIFont fontWithName:@"Avenir Book" size:16] forKey:@"textLabel.font"];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"exportYourInfo" rowType:XLFormRowDescriptorTypeInfo title:@"Sync"];
    [row.cellConfig setObject:[UIFont fontWithName:@"Avenir Book" size:16] forKey:@"textLabel.font"];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSection];
    section.title = @"ABOUT";
    
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"version" rowType:XLFormRowDescriptorTypeSelectorPush title:@"Version"];
    [row.cellConfig setObject:[UIFont fontWithName:@"Avenir Book" size:16] forKey:@"textLabel.font"];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"privacyCookies" rowType:XLFormRowDescriptorTypeSelectorPush title:@"Privacy and Cookies"];
    [row.cellConfig setObject:[UIFont fontWithName:@"Avenir Book" size:16] forKey:@"textLabel.font"];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"exportYourInfo" rowType:XLFormRowDescriptorTypeInfo title:@"Export Your Info"];
    [row.cellConfig setObject:[UIFont fontWithName:@"Avenir Book" size:16] forKey:@"textLabel.font"];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    XLFormRowDescriptor * buttonRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"button" rowType:XLFormRowDescriptorTypeButton title:@"Sign Out"];
    [buttonRow.cellConfig setObject:[UIFont fontWithName:@"Avenir Book" size:16] forKey:@"textLabel.font"];
    buttonRow.action.formSelector = @selector(signOut:);
    [section addFormRow:buttonRow];
    
    self.form = form;
}

- (IBAction)closeModule:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void) signOut:(id) sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
    }];
    
    SceneDelegate *sceneDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MTDLoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    sceneDelegate.window.rootViewController = loginViewController;
}

@end
