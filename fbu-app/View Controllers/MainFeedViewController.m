//
//  MainFeedViewController.m
//  fbu-app
//
//  Created by mwen on 7/12/21.
//

#import "MainFeedViewController.h"
#import "Parse/Parse.h"
#import "ListViewController.h"
#import "List.h"
#import "ListCell.h"

@interface MainFeedViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *userPFPView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UITableView *defaultTableView;
@property (weak, nonatomic) IBOutlet UITableView *userListTableView;
@property (weak, nonatomic) IBOutlet UITextField *addNewListField;
@property (nonatomic, strong) NSMutableArray *arrayOfDefaultLists;
@property (nonatomic, strong) NSMutableArray *arrayOfUserLists;
@end

@implementation MainFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.defaultTableView.dataSource = self;
    self.defaultTableView.delegate = self;
    self.userListTableView.dataSource = self;
    self.userListTableView.delegate = self;
    
    self.addNewListField.delegate = self;
    
    self.usernameLabel.text = [NSString stringWithFormat:@"Hi, %@!", PFUser.currentUser.username];

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
    
    [self getLists];
}

- (void) getLists {
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:PFUser.currentUser.username];
    [query includeKey:@"lists.name"];
    [query includeKey:@"lists.totalWorkingTime"];
    [query includeKey:@"lists.author"];
    [query includeKey:@"lists.defaultList"];

    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            PFUser *queriedUser = (PFUser *)object;
            NSMutableArray *userLists = queriedUser[@"lists"];
            
            self.arrayOfUserLists = [[NSMutableArray alloc] init];
            self.arrayOfDefaultLists = [[NSMutableArray alloc] init];
            
            for (List *list in userLists) {
                if ([list[@"defaultList"]  isEqual: @1]) {
                    [self.arrayOfDefaultLists addObject:list];
                } else {
                    [self.arrayOfUserLists addObject:list];
                }
            }
            
            [self.defaultTableView reloadData];
            [self.userListTableView reloadData];
        }

    }];
}

// Quick list return
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    List *newList =[List createList:self.addNewListField.text ifDefault: NO withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"New list created");
        }
    }];
    
    [List addList:newList withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"Added list to user");
        }
    }];
    
    [self.arrayOfUserLists addObject:newList];
    self.addNewListField.text = @"";
    
    [self.userListTableView reloadData];
    
    return YES;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.userListTableView){
        UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"Delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            
            List *list = self.arrayOfUserLists[indexPath.row];
            
            PFQuery *query = [PFQuery queryWithClassName:@"List"];
            [query getObjectInBackgroundWithId:list.objectId block:^(PFObject *listObject, NSError *error) {
              [listObject deleteInBackground];
            }];
            
            [self.arrayOfUserLists removeObject: list];
            
            [self.userListTableView reloadData];
            completionHandler(YES);
        }];
        
        deleteAction.backgroundColor = [UIColor colorWithRed:(245/255.0) green:(78/255.0) blue:(70/255.0) alpha:1];
        
        UISwipeActionsConfiguration *SwipeActions = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
        SwipeActions.performsFirstActionWithFullSwipe= YES;
        return SwipeActions;
    }
    
    return nil;

}


- (UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListCell" forIndexPath:indexPath];
    
    List *list;
    if (tableView == self.defaultTableView) {
        list = self.arrayOfDefaultLists[indexPath.row];
    } else if (tableView == self.userListTableView) {
        list = self.arrayOfUserLists[indexPath.row];
    }
    
    cell.listNameLabel.text = list[@"name"];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.defaultTableView) {
        return self.arrayOfDefaultLists.count;
    } else if (tableView == self.userListTableView) {
        return self.arrayOfUserLists.count;
    }
    
    return 0;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"openListSegue"]) {
        ListCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.defaultTableView indexPathForCell:tappedCell];
        List *list = self.arrayOfDefaultLists[indexPath.row];
        
        ListViewController *listViewController = [segue destinationViewController];
        listViewController.list = list;
    } else if ([segue.identifier isEqual:@"openUserListSegue"]) {
        ListCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.userListTableView indexPathForCell:tappedCell];
        List *list = self.arrayOfUserLists[indexPath.row];
        
        ListViewController *listViewController = [segue destinationViewController];
        listViewController.list = list;
    }
}

@end
