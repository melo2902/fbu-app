//
//  MTDListViewController.m
//  fbu-app
//
//  Created by mwen on 7/12/21.
//

#import "MTDListViewController.h"
#import <UserNotifications/UserNotifications.h>
#import "Parse/Parse.h"
#import "MTDList.h"
#import "MTDTaskViewController.h"
#import "MTDTask.h"
#import "MTDTaskCell.h"
#import "DateTools.h"
#import "MTDList.h"
#import "MTDListHeaderView.h"

@interface MTDListViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, XLFTaskViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *allTasksArray;
@property (nonatomic, strong) NSMutableArray *arrayOfTasks;
@property (nonatomic, strong) NSMutableArray *arrayOfCompletedTasks;
@end

@implementation MTDListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    //    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
    //                                 forBarMetrics:UIBarMetricsDefault];
    //    self.navigationController.navigationBar.shadowImage = [UIImage new];
    //    self.navigationController.navigationBar.translucent = YES;
    //    self.navigationController.view.backgroundColor = [UIColor clearColor];
    //    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];

    if ([self.list[@"name"] isEqual:@"My Day"] || [self.list[@"name"] isEqual:@"My Tomorrow"]) {
        [self checkMyDayMyTomorrowTasks];
    }
    
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"TableViewHeaderView"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ListHeaderHeaderFooterView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"ListHeaderHeaderFooterView"];
    
    [self getTasks];
    
    // Add an image background programatically for list
    // [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"iPhonePoolBackground.png"]]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.allTasksArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.allTasksArray[section] lastObject] count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return [self initializeListHeader];
        
    } else {
        NSArray *tasksInSection = [self.allTasksArray[section] lastObject];
        
        if ([tasksInSection count] == 0) {
            return nil;
        } else {
            UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"TableViewHeaderView"];
            
            header.textLabel.text = [self.allTasksArray[section] firstObject];
            return header;
        }
    }
}

- (MTDListHeaderView *) initializeListHeader {
    MTDListHeaderView *header = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ListHeaderHeaderFooterView"];

    header.titleLabelTitle.text = self.list[@"name"];

    NSString *workingTime = [self.list[@"totalWorkingTime"] stringValue];
    if ([workingTime isEqual: @"1"]) {
        header.workingTimeLabel.text = [NSString stringWithFormat:@"%@ hr", workingTime];
    } else {
        header.workingTimeLabel.text = [NSString stringWithFormat:@"%@ hrs", workingTime];
    }
    
    header.addedTaskBar.delegate = self;
    
    __weak MTDListHeaderView *weakHeader = header;
    weakHeader.taskButtonTapHandler = ^ {
        [self performSegueWithIdentifier:@"addNewTaskSegue" sender:nil];
    };
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 100;
    } else {
        return 30;
    }
}

- (void) checkMyDayMyTomorrowTasks {
    PFQuery *query = [PFQuery queryWithClassName:@"Task"];
    [query whereKey:@"author" equalTo: PFUser.currentUser];
    [query whereKey:@"inLists" equalTo: self.list[@"name"]];
    [query orderByAscending:@"dueDate"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *tasks, NSError *error) {
        NSDate *currentDate = [NSDate date];
        
        if ([self.list[@"name"] isEqual:@"My Day"]) {
            for (MTDTask *task in tasks) {
                NSDate *nextDate = [task.createdAt dateByAddingDays:1];
                
                if ([task.createdAt isSameDay:currentDate]) {
                    // Task made day of
                    continue;
                } else if (([nextDate isSameDay:currentDate])) {
                    // Task pulled from the "My Tomorrow" list
                    continue;
                } else {
                    NSMutableArray *currentLists = task[@"inLists"];
                    [currentLists removeObject:@"My Day"];
                    task[@"inLists"] = currentLists;
                    [task saveInBackground];
                }
            }
        } else {
            for (MTDTask *task in tasks) {
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
        if (tasks != nil) {
            [self updateTaskArray:tasks];
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

- (void) updateTaskArray: (NSArray *) tasks {
    self.arrayOfTasks = [[NSMutableArray alloc] init];
    self.arrayOfCompletedTasks = [[NSMutableArray alloc] init];
    self.allTasksArray = [[NSMutableArray alloc] init];
    
    NSMutableArray* temporaryTasks = [[NSMutableArray alloc] init];
    NSMutableArray* temporaryCompletedTasks = [[NSMutableArray alloc] init];
    [temporaryTasks addObject:self.list[@"name"]];
    [temporaryCompletedTasks addObject:@"Completed"];
    
    NSMutableArray *emptyDueDateTasks = [[NSMutableArray alloc] init];
    for (MTDTask *task in tasks) {
        if ([task[@"completed"] isEqual:@0]) {
            if (task[@"dueDate"]) {
                [self.arrayOfTasks addObject:task];
            } else {
                [emptyDueDateTasks addObject:task];
            }
        } else {
            [self.arrayOfCompletedTasks addObject:task];
        }
    }
    
    [self.arrayOfTasks addObjectsFromArray:emptyDueDateTasks];
    [temporaryTasks addObject: self.arrayOfTasks];
    [self.allTasksArray addObject:temporaryTasks];
    
    [temporaryCompletedTasks addObject: self.arrayOfCompletedTasks];
    [self.allTasksArray addObject:temporaryCompletedTasks];
    
    [self.tableView reloadData];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    MTDTask *newTask = [MTDTask createTask:textField.text inList: self.list[@"name"] withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
    }];

    [newTask saveInBackground];

    [MTDList addTask:newTask toList:self.list withCompletion:
     ^(BOOL succeeded, NSError * _Nullable error) {
    }];
    
    [[self.allTasksArray[0] lastObject] insertObject:newTask atIndex:0];
    // [self updateListWorkingTime];
    
    textField.text = @"";
    [self.tableView reloadData];

    return YES;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSArray *tasksInSection = [self.allTasksArray[indexPath.section] lastObject];
    MTDTask *task = tasksInSection[indexPath.row];

    UIContextualAction *notif1 = [self createNotification:(NSString *) task[@"taskTitle"] inStringTime:@"30s" inSeconds:30];
    
    UIContextualAction *notif2 = [self createNotification:(NSString *) task[@"taskTitle"] inStringTime:@"60s" inSeconds:60];

    UIContextualAction *notif3 = [self createNotification:(NSString *) task[@"taskTitle"] inStringTime:@"90s" inSeconds:90];

    UISwipeActionsConfiguration *SwipeActions = [UISwipeActionsConfiguration configurationWithActions:@[notif1,notif2, notif3]];
    SwipeActions.performsFirstActionWithFullSwipe=false;
    return SwipeActions;

    return nil;

}

- (UIContextualAction*) createNotification:(NSString *) taskTitle inStringTime: (NSString *) time inSeconds: (NSTimeInterval) seconds {

    UIContextualAction *notification = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:time handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {

        UNMutableNotificationContent *content;
        content = [UNMutableNotificationContent new];
        content.body = [NSString stringWithFormat:@"Reminder: Complete task '%@'!", taskTitle];
        
        content.sound = [UNNotificationSound defaultSound];

        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger
            triggerWithTimeInterval:seconds repeats:NO];

        NSString *identifier = [NSString stringWithFormat:@"%@:%@:%@", PFUser.currentUser, taskTitle, time];
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

        NSArray *tasksInSection = [self.allTasksArray[indexPath.section] lastObject];

        MTDTask *task;
        task = tasksInSection[indexPath.row];
        
        // Tasks aren't pulled from the list
        [MTDList deleteTask:task toList:self.list withCompletion:
         ^(BOOL succeeded, NSError * _Nullable error) {
        }];

        PFQuery *query = [PFQuery queryWithClassName:@"Task"];
        [query getObjectInBackgroundWithId:task.objectId block:^(PFObject *taskObject, NSError *error) {
          [taskObject deleteInBackground];
        }];


        [[self.allTasksArray[indexPath.section] lastObject] removeObject:task];
        // [self updateListWorkingTime];

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
    
    MTDTaskCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MTDTaskCell" forIndexPath:indexPath];
    NSArray *tasksInSection = [self.allTasksArray[indexPath.section] lastObject];

    MTDTask *task;
    task = tasksInSection[indexPath.row];
    
    NSDate *currentDate = [NSDate new];
    NSDate *taskDueDate = task[@"dueDate"];

    if (taskDueDate && ![currentDate isEarlierThanOrEqualTo:taskDueDate]) {
        cell.dueDateLabel.attributedText = [self colorStringRed:taskDueDate];
    } else {
        cell.dueDateLabel.text = taskDueDate.shortTimeAgoSinceNow;
    }
   
    cell.task = task;
    
    cell.taskItemLabel.attributedText = nil;
    if ([cell.task[@"completed"] isEqual: @0]){
        [cell.completionButton setSelected:NO];
        cell.taskItemLabel.text = task[@"taskTitle"];
    } else {
        [cell.completionButton setSelected:YES];
        cell.taskItemLabel.attributedText = [self strikeOutText:task[@"taskTitle"]];
    }
    
    __weak MTDTaskCell *weakCell = cell;
    weakCell.completionButtonTapHandler = ^{
        if ([task[@"completed"]  isEqual: @0]){
            [[self.allTasksArray[0] lastObject] addObject:task];
            [[self.allTasksArray[1] lastObject] removeObject:task];

            [MTDList updateTime: task[@"workingTime"] toList:self.list withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    NSLog(@"Update list time");
                }
            }];

        } else {
            [[self.allTasksArray[1] lastObject] addObject:task];
            [[self.allTasksArray[0] lastObject] removeObject:task];
            
            float updatedWorkingTime = -1 * [task[@"workingTime"] floatValue];
            [MTDList updateTime:[NSNumber numberWithFloat:updatedWorkingTime] toList:self.list withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    NSLog(@"Update list time");
                }
            }];
        }

        // [self updateListWorkingTime];
        [self.tableView reloadData];
    };
    
    return cell;
}

//- (void) updateListWorkingTime {
//    NSString *workingTime = [self.list[@"totalWorkingTime"] stringValue];
//    if ([workingTime isEqual: @"1"]) {
//        self.workingTimeLabel.text = [NSString stringWithFormat:@"%@ hr", workingTime];
//    } else {
//        self.workingTimeLabel.text = [NSString stringWithFormat:@"%@ hrs", workingTime];
//    }
//}

- (NSAttributedString *) strikeOutText: (NSString *) text {
    NSDictionary* attributes = @{
      NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]
    };

    NSAttributedString* attrText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    return attrText;
}

- (NSAttributedString *) colorStringRed: (NSDate *) dueDate {
    UIColor *color = [UIColor redColor];
    NSString *string = [NSString stringWithFormat:@"-%@", dueDate.shortTimeAgoSinceNow];
    NSDictionary *attrs = @{ NSForegroundColorAttributeName : color };
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:string attributes:attrs];
    
    return attrStr;
}

- (IBAction)onTapBackButton:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

-(void)ListViewController:(MTDTaskViewController *)controller withTimeChange:(NSNumber *)timeChange {
    
    [MTDList updateTime:timeChange toList:self.list withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            // [self updateListWorkingTime];
            [self getTasks];
        }
    }];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqual:@"showTaskDetailsSegue"]|| [segue.identifier isEqual:@"showCompletedTaskDetailsSegue"]) {
        MTDTaskCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        MTDTask *task = self.arrayOfTasks[indexPath.row];

        MTDTaskViewController *vc = segue.destinationViewController;
        vc.delegate = self;
        vc.task = task;

    } else if ([segue.identifier isEqual:@"addNewTaskSegue"]) {
        MTDTaskViewController *vc = segue.destinationViewController;
        vc.delegate = self;
        vc.listName = self.list[@"name"];
    }
}

@end
