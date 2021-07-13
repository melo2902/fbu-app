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

@interface MainFeedViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *userPFPView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *arrayOfLists;
@end

@implementation MainFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // Do any additional setup after loading the view.
    self.usernameLabel.text = [NSString stringWithFormat:@"Hi, %@!", PFUser.currentUser.username];

//    Set up array with initial lists
    [self getLists];
}

- (void) getLists {
    PFQuery *query = [PFUser query];
//    [query whereKey:@"author" equalTo:PFUser.currentUser];
    [query whereKey:@"username" equalTo:PFUser.currentUser.username];
    NSLog(@"%@", PFUser.currentUser.username);
    [query includeKey:@"lists.name"];
    [query includeKey:@"lists.totalWorkingTime"];
    [query includeKey:@"lists.author"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
           //You found the user!
           PFUser *queriedUser = (PFUser *)object;
            NSLog(@"%@", queriedUser[@"lists"]);
            self.arrayOfLists = queriedUser[@"lists"];
            [self.tableView reloadData];
        }

    }];
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqual:@"openListSegue"]) {
        ListCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        List *list = self.arrayOfLists[indexPath.row];
        
        ListViewController *listViewController = [segue destinationViewController];
        listViewController.list = list;
    }
}

@end
