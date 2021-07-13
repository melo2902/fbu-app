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
//    PFQuery *query = [PFUser query];
//    [query whereKey:@"username" equalTo:PFUser.currentUser.username];
//    [query includeKey:@"lists"];
//
//    [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * _Nullable error) {
//           if (error) {
//               NSLog(@"error: %@",error);
//           } else {
//               NSLog(@"%@object", objects);
//               NSLog(@"object%@", [objects firstObject]);
////               self.profileToSet = [objects firstObject];
//           // Do the rest of the setup with the profileToSet PFUser PFObject.
//           }
//       }];
    
    PFQuery *query = [PFQuery queryWithClassName:@"List"];
    [query includeKey:@"author"];
    [query whereKey:@"author" equalTo: PFUser.currentUser];
    NSLog(@"%@", PFUser.currentUser);
    [query findObjectsInBackgroundWithBlock:^(NSArray *lists, NSError *error) {
        if (lists != nil) {
//            if (!lists.count) {
            NSLog(@"Lists%@", lists);
            self.arrayOfLists = (NSMutableArray *) lists;
            NSLog(@"%@arrayOfLists", self.arrayOfLists);
            [self.tableView reloadData];
//            } else {
//                self.arrayOfLists = PFUser.currentUser[@"lists"];
//                [self.tableView reloadData];
//            }
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    
//    NSMutableArray *lists = (NSMutableArray *)[query findObjects];
//    self.arrayOfLists = (NSMutableArray *) lists;
//
//    [currentUser]
//    PFQuery *query = [PFUser query];
//    [query whereKey:@"email" equalTo:@"email@example.com"];
//    NSArray *users = [query findObjects];
    
//    PFQuery *query = [PFQuery queryWithClassName:@"User"];
//    [query whereKey:@"];
//    [query orderByDescending:@"createdAt"];
   
    // fetch data asynchronously
//    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
//        if (posts != nil) {
//            self.posts = posts;
//
//            [self.tableView reloadData];
//        } else {
//            NSLog(@"%@", error.localizedDescription);
//        }
//    }];
    
//    PFUser *user = [PFUser currentUser];
//    self.arrayOfLists = PFUser.currentUser[@"lists"];
//
//    NSLog(@"%@", PFUser.currentUser);
//    NSLog(@"%@", self.arrayOfLists);
    
//    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSLog(@"do we hit here");
    ListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListCell" forIndexPath:indexPath];
    
    List *list = self.arrayOfLists[indexPath.row];
//    cell.listNameLabel.text = list.name;
    NSLog(@"name%@", list[@"name"]);
    cell.listNameLabel.text = list[@"name"];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 1;
//
    NSLog(@"%lu", (unsigned long)self.arrayOfLists.count);
    NSLog(@"%@ARRAY", self.arrayOfLists);
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
