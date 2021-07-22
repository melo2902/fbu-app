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
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITableView *userListTableView;
@property (weak, nonatomic) IBOutlet UITextField *addNewListField;
@property (nonatomic, strong) NSMutableArray *arrayOfLists;
@end

@implementation MainFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.addNewListField.delegate = self;
    
    self.usernameLabel.text = [NSString stringWithFormat:@"Hi, %@!", PFUser.currentUser.username];

    [self getLists];
}

- (void) getLists {
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:PFUser.currentUser.username];
    [query includeKey:@"lists.name"];
    [query includeKey:@"lists.totalWorkingTime"];
    [query includeKey:@"lists.author"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            PFUser *queriedUser = (PFUser *)object;
            self.arrayOfLists = queriedUser[@"lists"];
            [self.tableView reloadData];
        }

    }];
}

// Quick list return
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    List *newList =[List createList:self.addNewListField.text withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"New list created");
        }
    }];
    
    [self.arrayOfLists addObject:newList];
    
    self.addNewListField.text = @"";
    [self.tableView reloadData];
    
    return YES;
}

- (UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListCell" forIndexPath:indexPath];
    
    List *list = self.arrayOfLists[indexPath.row];
    cell.listNameLabel.text = list[@"name"];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfLists.count;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"openListSegue"]) {
        ListCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        List *list = self.arrayOfLists[indexPath.row];
        
        ListViewController *listViewController = [segue destinationViewController];
        listViewController.list = list;
    }
}

@end
