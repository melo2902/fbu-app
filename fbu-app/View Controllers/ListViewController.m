//
//  ListViewController.m
//  fbu-app
//
//  Created by mwen on 7/12/21.
//

#import "ListViewController.h"
#import <UserNotifications/UserNotifications.h>
#import "Parse/Parse.h"
#import "List.h"
#import "TaskViewController.h"
#import "Task.h"
#import "TaskCell.h"

@interface ListViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *listNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *workingTimeLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *addedTaskBar;
@property (nonatomic, strong) NSMutableArray *arrayOfTasks;
@property (nonatomic, strong) NSMutableArray *completedTasks;
@property (nonatomic, strong) List *currentList;
@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.addedTaskBar.delegate = self;
    
    self.listNameLabel.text = self.list[@"name"];
    NSString *workingTime = [self.list[@"totalWorkingTime"] stringValue];
    self.workingTimeLabel.text = [NSString stringWithFormat:@"%@ hrs", workingTime];
    
    [self getTasks];
}

- (void) getTasks {
    PFQuery *query = [PFQuery queryWithClassName:@"Task"];
    [query whereKey:@"author" equalTo: PFUser.currentUser];
    [query whereKey:@"listTitle" equalTo: self.list[@"name"]];
    [query whereKey:@"author" equalTo: PFUser.currentUser];
    
    [query orderByDescending:@"createdAt"];
   
    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *tasks, NSError *error) {
        if (tasks != nil) {
            self.arrayOfTasks = (NSMutableArray *) tasks;
            
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    
//    PFQuery *query = [PFUser query];
//    [query whereKey:@"username" equalTo:PFUser.currentUser.username];
//    [query includeKey:@"lists"];
//
////    [query whereKey:@"lists.name" equalTo: self.list[@"name"]];
////    NSLog(@"%@", self.list[@"name"]);
////    [query includeKey:@"lists.arrayOfItems"];
////    [query includeKey:@"lists.name"];
//    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//        if (!error) {
//            //You found the user!
//            PFUser *queriedUser = (PFUser *)object;
//            NSArray *userLists = queriedUser[@"lists"];
//
//            for (List *object in userLists) {
//                NSString *name = object[@"name"];
//                if ([name isEqual: self.list[@"name"]]){
//                    NSLog(@"object %@", object);
//                    NSLog(@"why is this empty%@", object[@"arrayOfItems"]);
//
//                    self.currentList = object;
//                    self.arrayOfTasks = object[@"arrayOfItems"];
//                    NSLog(@"%@", self.arrayOfTasks);
//                    [self.tableView reloadData];
////                    self.arrayOfTasks = [[NSMutableArray alloc] init];
//                }
//                // do something with object
//            }
//
//        }
//
//    }];
}

// Also, want to be able to add a long version of it
// This is the short term quick add
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"%@", self.addedTaskBar.text);
    
    Task *newTask = [Task createTask:self.addedTaskBar.text inList: self.list[@"name"] withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
    }];
    
    [List addTask:newTask toList:self.list withCompletion:
     ^(BOOL succeeded, NSError * _Nullable error) {
    }];
    
    [self.arrayOfTasks addObject:newTask];
    
    NSLog(@"tasks%@", self.arrayOfTasks);
    
    self.addedTaskBar.text = @"";
    [self.tableView reloadData];
    
    return YES;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    Pull this out to a seeprate functions
    UIContextualAction *notif1Action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"10m" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {

        UNMutableNotificationContent *content = [UNMutableNotificationContent new];
//        content.title = @"Don't forget";
        content.body = @"Reply to message!";
        content.sound = [UNNotificationSound defaultSound];

//        This is in seconds
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger
          triggerWithTimeInterval:30 repeats:NO];
        
        NSString *identifier = @"UYLLocalNotification";
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier
            content:content trigger:trigger];

//        Add a custom action later though will have to use delegate
        
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
//         *center = currentNotificationCenter;
        
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
          if (error != nil) {
            NSLog(@"Something went wrong: %@",error);
          }
        }];
        
    }];

    UIContextualAction *notif2Action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"1hr" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {

        //...

        completionHandler(YES);
    }];
    
    UIContextualAction *notif3Action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"EOD" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {

        //...

        completionHandler(YES);
    }];

    notif1Action.backgroundColor = [UIColor colorWithRed:(245/255.0) green:(78/255.0) blue:(70/255.0) alpha:1];
    notif2Action.backgroundColor = [UIColor colorNamed:@"CL_LightGray_2"];
    notif3Action.backgroundColor = [UIColor colorNamed:@"CL_LightGray_2"];

    UISwipeActionsConfiguration *SwipeActions = [UISwipeActionsConfiguration configurationWithActions:@[notif1Action,notif2Action, notif3Action]];
    SwipeActions.performsFirstActionWithFullSwipe=false;
    return SwipeActions;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"Delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {

       //...

    }];

    deleteAction.backgroundColor = [UIColor colorWithRed:(245/255.0) green:(78/255.0) blue:(70/255.0) alpha:1];

    UISwipeActionsConfiguration *SwipeActions = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
    SwipeActions.performsFirstActionWithFullSwipe= YES;
    return SwipeActions;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TaskCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskCell" forIndexPath:indexPath];
    
    Task *task = self.arrayOfTasks[indexPath.row];
    cell.taskItemLabel.text = task[@"taskTitle"];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfTasks.count;
}

 #pragma mark - Navigation
 
// In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//  Get the new view controller using [segue destinationViewController].
//  Pass the selected object to the new view controller.

//     Will probably need to be a delegate (update later)
     if ([segue.identifier isEqual:@"showTaskDetailSegue"]) {
         TaskCell *tappedCell = sender;
         NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
         Task *task = self.arrayOfTasks[indexPath.row];
         
         TaskViewController *taskViewController = [segue destinationViewController];
         taskViewController.task = task;
     }
 }

@end
