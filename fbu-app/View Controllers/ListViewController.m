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
#import "XLFTaskViewController.h"
#import "Task.h"
#import "TaskCell.h"

@interface ListViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *listNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *workingTimeLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *addedTaskBar;
@property (nonatomic, strong) NSMutableArray *arrayOfTasks;
@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    [query whereKey:@"inLists" equalTo: self.list[@"name"]];
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *tasks, NSError *error) {
        if (tasks != nil) {
            self.arrayOfTasks = (NSMutableArray *) tasks;
            [self.tableView reloadData];
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

// Quick task add
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    Task *newTask = [Task createTask:self.addedTaskBar.text inList: self.list[@"name"] withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
    }];
    
    [List addTask:newTask toList:self.list withCompletion:
     ^(BOOL succeeded, NSError * _Nullable error) {
    }];
    
    [self.arrayOfTasks addObject:newTask];
    
    self.addedTaskBar.text = @"";
    [self.tableView reloadData];
    
    return YES;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Task *task = self.arrayOfTasks[indexPath.row];
    
    UIContextualAction *notif1 = [self createNotification:(NSString *) @"30 second notification" inStringTime:@"30s" inSeconds:30 withIdentifier: task[@"taskTitle"]];
    
    UIContextualAction *notif2 = [self createNotification:(NSString *) @"60 second notification" inStringTime:@"60s" inSeconds:60 withIdentifier: task[@"taskTitle"]];
    
    UIContextualAction *notif3 = [self createNotification:(NSString *) @"90 second notification" inStringTime:@"90s" inSeconds:90 withIdentifier: task[@"taskTitle"]];
    
    UISwipeActionsConfiguration *SwipeActions = [UISwipeActionsConfiguration configurationWithActions:@[notif1,notif2, notif3]];
    SwipeActions.performsFirstActionWithFullSwipe=false;
    return SwipeActions;
}

- (UIContextualAction*) createNotification:(NSString *) respondant inStringTime: (NSString *) time inSeconds: (NSTimeInterval) seconds withIdentifier: (NSString *) message {
    UIContextualAction *notification = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:time handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        UNMutableNotificationContent *content = [UNMutableNotificationContent new];
        content.body = [NSString stringWithFormat:@"Reply to %@'s message!", respondant];
        content.sound = [UNNotificationSound defaultSound];
        
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger
            triggerWithTimeInterval:seconds repeats:NO];
        
        NSString *identifier = [NSString stringWithFormat:@"%@:%@", respondant, message];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier
            content:content trigger:trigger];
        
        // Add a custom action later though will have to use delegate
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Unable to set notification, error: %@",error);
            }
        }];
        
        completionHandler(YES);
    }];
    
    // Need to add a different color
    notification.backgroundColor = [UIColor colorWithRed:(245/255.0) green:(78/255.0) blue:(70/255.0) alpha:1];
    
    return notification;
    
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"Delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        Task *task = self.arrayOfTasks[indexPath.row];
        
        // Tasks aren't pulled from the list
        [List deleteTask:task toList:self.list withCompletion:
         ^(BOOL succeeded, NSError * _Nullable error) {
        }];
        
        PFQuery *query = [PFQuery queryWithClassName:@"Task"];
        [query getObjectInBackgroundWithId:task.objectId block:^(PFObject *taskObject, NSError *error) {
          [taskObject deleteInBackground];
        }];
        
        [self.arrayOfTasks removeObject: task];
        
        [self.tableView reloadData];
        completionHandler(YES);
    }];
    
    deleteAction.backgroundColor = [UIColor colorWithRed:(245/255.0) green:(78/255.0) blue:(70/255.0) alpha:1];
    
    UISwipeActionsConfiguration *SwipeActions = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
    SwipeActions.performsFirstActionWithFullSwipe= YES;
    return SwipeActions;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TaskCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskCell" forIndexPath:indexPath];
    
    Task *task = self.arrayOfTasks[indexPath.row];
    cell.task = task;
    cell.taskItemLabel.text = task[@"taskTitle"];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfTasks.count;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // Need a delegate to prepare segue
    if ([segue.identifier isEqual:@"showTaskDetailsSegue"]) {
        TaskCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        Task *task = self.arrayOfTasks[indexPath.row];
        
        XLFTaskViewController *taskViewController = [segue destinationViewController];
        taskViewController.task = task;
    }
}

@end
