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
#import "XLFTaskViewController.h"
#import "Task.h"
#import "TaskCell.h"
#import "DateTools.h"

@interface ListViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *listNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *workingTimeLabel;
@property (weak, nonatomic) IBOutlet UITableView *tasksTableView;
@property (weak, nonatomic) IBOutlet UITableView *completedTableView;
@property (weak, nonatomic) IBOutlet UITextField *addedTaskBar;
@property (nonatomic, strong) NSMutableArray *arrayOfTasks;
@property (nonatomic, strong) NSMutableArray *arrayOfCompletedTasks;
@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tasksTableView.dataSource = self;
    self.tasksTableView.delegate = self;
    self.addedTaskBar.delegate = self;
    self.completedTableView.dataSource = self;
    self.completedTableView.delegate = self;
    
    self.listNameLabel.text = self.list[@"name"];
    NSString *workingTime = [self.list[@"totalWorkingTime"] stringValue];
    self.workingTimeLabel.text = [NSString stringWithFormat:@"%@ hrs", workingTime];

    if ([self.list[@"name"] isEqual:@"My Day"] || [self.list[@"name"] isEqual:@"My Tomorrow"]) {
        [self checkMyDayMyTomorrowTasks];
    }
    
    [self getTasks];
    
    // Add an image background programatically for list
    // [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"iPhonePoolBackground.png"]]];
}

- (void) checkMyDayMyTomorrowTasks {
    PFQuery *query = [PFQuery queryWithClassName:@"Task"];
    [query whereKey:@"author" equalTo: PFUser.currentUser];
    [query whereKey:@"inLists" equalTo: self.list[@"name"]];
    [query orderByAscending:@"dueDate"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *tasks, NSError *error) {
        NSDate *currentDate = [NSDate date];
        
        if ([self.list[@"name"] isEqual:@"My Day"]) {
            for (Task *task in tasks) {
                if ([task.createdAt isSameDay:currentDate]) {
                    continue;
                } else {
                    NSMutableArray *currentLists = task[@"inLists"];
                    [currentLists removeObject:@"My Day"];
                    task[@"inLists"] = currentLists;
                    [task saveInBackground];
                }
            }
        } else {
            for (Task *task in tasks) {
                NSDate *nextDate = [task.createdAt dateByAddingDays:1];
                
                if ([nextDate isSameDay:currentDate]) {
                    // Move task from My Tomorrow to My Day
                    NSMutableArray *currentLists = task[@"inLists"];
                    [currentLists removeObject:@"My Tomorrow"];
                    [currentLists addObject:@"My Day"];
                    task[@"inLists"] = currentLists;
                    [task saveInBackground];;
                } else if ([task.createdAt isSameDay:currentDate]) {
                    // Task created today for tomorrow
                    continue;
                } else {
                    NSMutableArray *currentLists = task[@"inLists"];
                    [currentLists removeObject:@"My Tomorrow"];
                    task[@"inLists"] = currentLists;
                    [task saveInBackground];
                }
            }
        }
        
    }];
}

- (void) getTasks {
    PFQuery *query = [PFQuery queryWithClassName:@"Task"];
    [query whereKey:@"author" equalTo: PFUser.currentUser];
    [query whereKey:@"inLists" equalTo: self.list[@"name"]];
    [query orderByAscending:@"dueDate"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *tasks, NSError *error) {
        
        self.arrayOfTasks = [[NSMutableArray alloc] init];
        self.arrayOfCompletedTasks = [[NSMutableArray alloc] init];
        
        if (tasks != nil) {
            for (Task *task in tasks) {
                if ([task[@"completed"] isEqual:@0]) {
                    [self.arrayOfTasks addObject:task];
                } else {
                    [self.arrayOfCompletedTasks addObject:task];
                }
            }
            
            [self.tasksTableView reloadData];
            [self.completedTableView reloadData];
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

// Quick task add
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
        
    Task *newTask = [Task createTask:self.addedTaskBar.text inList: self.list[@"name"] withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
    }];
    
    [newTask saveInBackground];
    
    [List addTask:newTask toList:self.list withCompletion:
     ^(BOOL succeeded, NSError * _Nullable error) {
    }];
    
    [self.arrayOfTasks addObject:newTask];
    
    NSString *workingTime = [self.list[@"totalWorkingTime"] stringValue];
    self.workingTimeLabel.text = [NSString stringWithFormat:@"%@ hrs", workingTime];
    
    self.addedTaskBar.text = @"";
    [self.tasksTableView reloadData];
    
    return YES;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.tasksTableView) {
        Task *task = self.arrayOfTasks[indexPath.row];
        
        UIContextualAction *notif1 = [self createNotification:(NSString *) @"30 second notification" inStringTime:@"30s" inSeconds:30 withIdentifier: task[@"taskTitle"]];
        
        UIContextualAction *notif2 = [self createNotification:(NSString *) @"60 second notification" inStringTime:@"60s" inSeconds:60 withIdentifier: task[@"taskTitle"]];
        
        UIContextualAction *notif3 = [self createNotification:(NSString *) @"90 second notification" inStringTime:@"90s" inSeconds:90 withIdentifier: task[@"taskTitle"]];
        
        UISwipeActionsConfiguration *SwipeActions = [UISwipeActionsConfiguration configurationWithActions:@[notif1,notif2, notif3]];
        SwipeActions.performsFirstActionWithFullSwipe=false;
        return SwipeActions;
    }
    
    return nil;
    
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
        
        Task *task;
        if (tableView == self.tasksTableView) {
            task = self.arrayOfTasks[indexPath.row];
        } else {
            task = self.arrayOfCompletedTasks[indexPath.row];
        }
        
        
        // Tasks aren't pulled from the list
        [List deleteTask:task toList:self.list withCompletion:
         ^(BOOL succeeded, NSError * _Nullable error) {
        }];
        
        PFQuery *query = [PFQuery queryWithClassName:@"Task"];
        [query getObjectInBackgroundWithId:task.objectId block:^(PFObject *taskObject, NSError *error) {
          [taskObject deleteInBackground];
        }];
        
        [self.arrayOfTasks removeObject: task];
        
        NSString *workingTime = [self.list[@"totalWorkingTime"] stringValue];
        self.workingTimeLabel.text = [NSString stringWithFormat:@"%@ hrs", workingTime];
        
        [self.tasksTableView reloadData];
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
    
    Task *task;
    if (tableView == self.tasksTableView) {
        task = self.arrayOfTasks[indexPath.row];
        
        NSDate *dateString = task[@"dueDate"];
        cell.dueDateLabel.text =  dateString.shortTimeAgoSinceNow;
        
    } else {
        task = self.arrayOfCompletedTasks[indexPath.row];
    }
   
    cell.task = task;
    cell.taskItemLabel.text = task[@"taskTitle"];
    
    if ([cell.task[@"completed"] isEqual: @0]){
        [cell.completionButton setSelected:NO];
    } else {
        [cell.completionButton setSelected:YES];
    }
    
    cell.completionButtonTapHandler = ^{
        if ([task[@"completed"]  isEqual: @0]){
            [self.arrayOfTasks addObject:task];
            [self.arrayOfCompletedTasks removeObject:task];
            
            [List updateTask:task toList:self.list changeCompletion:NO withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    NSLog(@"Update list time");
                }
            }];
            
        } else {
            [self.arrayOfCompletedTasks addObject:task];
            [self.arrayOfTasks removeObject:task];
            
            [List updateTask:task toList:self.list changeCompletion:YES withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    NSLog(@"Update list time");
                }
            }];
        }
        
        NSString *workingTime = [self.list[@"totalWorkingTime"] stringValue];
        self.workingTimeLabel.text = [NSString stringWithFormat:@"%@ hrs", workingTime];
        
        [self.tasksTableView reloadData];
        [self.completedTableView reloadData];
    };
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.tasksTableView) {
        return self.arrayOfTasks.count;
    } else {
        return self.arrayOfCompletedTasks.count;
    }
    
}

- (IBAction)onTapBackButton:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // Need a delegate to prepare segue
    if ([segue.identifier isEqual:@"showTaskDetailsSegue"]|| [segue.identifier isEqual:@"showCompletedTaskDetailsSegue"]) {
        TaskCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tasksTableView indexPathForCell:tappedCell];
        Task *task = self.arrayOfTasks[indexPath.row];
        
        XLFTaskViewController *taskViewController = [segue destinationViewController];
        taskViewController.task = task;
    } else if ([segue.identifier isEqual:@"addNewTaskSegue"]) {
        XLFTaskViewController *taskViewController = [segue destinationViewController];
        taskViewController.listName = self.list[@"name"];
    }
}

@end
