//
//  MTDMainFeedViewController.m
//  fbu-app
//
//  Created by mwen on 7/12/21.
//

#import "MTDMainFeedViewController.h"
#import "Parse/Parse.h"
#import "MTDListViewController.h"
#import "MTDList.h"
#import "MTDListCell.h"
#import "MTDMainFeedHeaderView.h"
#import "MTDAddListHeaderView.h"
#import "MTDUser.h"

@interface MTDMainFeedViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *allListsArray;
@end

@implementation MTDMainFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                 forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    [self registerCustomViews];
    [self getLists];
}

- (void) registerCustomViews {
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"TableViewHeaderView"];
    [self.tableView registerNib:[UINib nibWithNibName:@"MainFeedHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"MainFeedHeaderView"];
    [self.tableView registerNib:[UINib nibWithNibName:@"AddListHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"AddListHeaderView"];
}

# pragma mark - List data

- (void) getLists {
    MTDUser *user = [MTDUser currentUser];
    
    PFQuery *query = [MTDUser query];
    [query whereKey:@"username" equalTo:user.username];
    [query includeKey:@"lists.name"];
    [query includeKey:@"lists.totalWorkingTime"];
    [query includeKey:@"lists.author"];
    [query includeKey:@"lists.defaultList"];

    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            MTDUser *queriedUser = (MTDUser *)object;
            NSMutableArray *userLists = queriedUser.lists;
            [self updateArrayData:userLists];
        }

    }];
}

- (void) updateArrayData:(NSMutableArray*) userLists {
    NSMutableArray *arrayOfUserLists = [[NSMutableArray alloc] init];
    NSMutableArray *arrayOfDefaultLists = [[NSMutableArray alloc] init];
    self.allListsArray = [[NSMutableArray alloc] init];
    
    NSMutableArray* tmpDefaultList = [[NSMutableArray alloc] init];
    [tmpDefaultList addObject:@"Default Lists"];
    NSMutableArray* tmpUserList = [[NSMutableArray alloc] init];
    [tmpUserList addObject:@"User Lists"];
    
    for (MTDList *list in userLists) {
        if (list.defaultList) {
            [arrayOfDefaultLists addObject:list];
        } else {
            [arrayOfUserLists addObject:list];
        }
    }
    
    [tmpDefaultList addObject: arrayOfDefaultLists];
    [self.allListsArray addObject:tmpDefaultList];
    
    [tmpUserList addObject: arrayOfUserLists];
    [self.allListsArray addObject:tmpUserList];
    
    [self.tableView reloadData];
}

# pragma mark - initiate table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.allListsArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        MTDMainFeedHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"MainFeedHeaderView"];
        
        __weak MTDMainFeedHeaderView *weakHeader = header;
        weakHeader.settingsButtonTapHandler = ^{
            [self performSegueWithIdentifier:@"showSettingsSegue" sender:nil];
        };
        
        return [self setUpMainFeedHeader: header];
        
    } else if (section == 1) {
        MTDAddListHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"AddListHeaderView"];
        NSAttributedString *blackText = [[NSAttributedString alloc] initWithString:@"New List" attributes:@{ NSForegroundColorAttributeName : [UIColor blackColor] }];
        header.placeHolderField.attributedPlaceholder = blackText;

        header.addListBarField.delegate = self;
        
        return header;
        
    } else {
        UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"TableViewHeaderView"];
        header.textLabel.text = [self.allListsArray[section] firstObject];
        
        return header;
    }
}

- (MTDMainFeedHeaderView *) setUpMainFeedHeader: (MTDMainFeedHeaderView *) header {
    
    MTDUser *user = [MTDUser currentUser];
    header.usernameLabel.text = [NSString stringWithFormat:@"Hi, %@!", user.firstName];
    
    NSDateFormatter* day = [[NSDateFormatter alloc] init];
    [day setDateFormat: @"EEEE, LLLL d"];
     header.dateLabel.text = [day stringFromDate:[NSDate date]];
    
    if (user.pfp) {
        PFFileObject *pfp = user.pfp;

       [pfp getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
           if (!error) {
               UIImage *originalImage = [UIImage imageWithData:imageData];
               header.pfpView.image = originalImage;
               header.pfpView.layer.cornerRadius = header.pfpView.frame.size.width / 2;
               header.pfpView.clipsToBounds = true;
           }
       }];
    }
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 137;
    } else {
        return 40;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.allListsArray[section] lastObject] count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MTDListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListCell" forIndexPath:indexPath];
    
    NSArray *listsInSection = [self.allListsArray[indexPath.section] lastObject];
    MTDList *list = listsInSection[indexPath.row];
    cell.listNameLabel.text = list.name;
    cell.numTasksLabel.text = [NSString stringWithFormat: @"%@ hrs", [list.totalWorkingTime stringValue]];
    
    if ([list.name isEqual: @"My Day"]) {
        cell.listIcon.image = [[UIImage systemImageNamed:@"sun.min"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    } else if ([list.name isEqual: @"My Tomorrow"]) {
        cell.listIcon.image = [[UIImage systemImageNamed:@"scribble.variable"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    } else if ([list.name isEqual: @"All"]) {
        cell.listIcon.image = [[UIImage systemImageNamed:@"tray"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    } else {
        cell.listIcon.image = [[UIImage systemImageNamed:@"pencil"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
   
    
    return cell;
}

# pragma mark - Add a new list functionality

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    MTDList *newList =[MTDList createList:textField.text ifDefault: NO withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"New list created");
        }
    }];

    [MTDList addList:newList withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"Added list to user");
        }
    }];

    textField.text = @"";
    
    [[self.allListsArray[1] lastObject] addObject:newList];
    [self.tableView reloadData];

    return YES;
}

# pragma mark - Swipe cell configuration

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *listsInSection = [self.allListsArray[indexPath.section] lastObject];
    MTDList *list = listsInSection[indexPath.row];
    
    
    if (!list.defaultList){
        UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title: nil handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            
            [self deleteActions:list];
            [self.tableView reloadData];
            
            completionHandler(YES);
        }];

        deleteAction.image = [UIImage systemImageNamed:@"trash"];
        deleteAction.backgroundColor = [UIColor colorWithRed:(245/255.0) green:(78/255.0) blue:(70/255.0) alpha:1];
        
        UISwipeActionsConfiguration *SwipeActions = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
        SwipeActions.performsFirstActionWithFullSwipe= YES;
        return SwipeActions;
    }
    
    return nil;

}

- (void) deleteActions: (MTDList *) list {
    PFQuery *query = [PFQuery queryWithClassName:@"List"];
    [query getObjectInBackgroundWithId:list.objectId block:^(PFObject *listObject, NSError *error) {
      [listObject deleteInBackground];
    }];
    
    [[self.allListsArray[1] lastObject] removeObject:list];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"openListSegue"]) {
        MTDListCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        
        NSArray *listsInSection = [self.allListsArray[indexPath.section] lastObject];
        MTDList *list = listsInSection[indexPath.row];
        
        UINavigationController *navigationController = [segue destinationViewController];
        MTDListViewController *listViewController = (MTDListViewController*) [navigationController topViewController];
        listViewController.list = list;
    }
}

@end
