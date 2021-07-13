//
//  ListViewController.m
//  fbu-app
//
//  Created by mwen on 7/12/21.
//

#import "ListViewController.h"
#import "Parse/Parse.h"
#import "List.h"
#import "Task.h"
#import "TaskCell.h"

@interface ListViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *listNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *workingTimeLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *addedTaskBar;
@property (nonatomic, strong) NSMutableArray *arrayOfTasks;
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
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:PFUser.currentUser.username];
    [query includeKey:@"lists"];
    
//    [query whereKey:@"lists.name" equalTo: self.list[@"name"]];
//    NSLog(@"%@", self.list[@"name"]);
//    [query includeKey:@"lists.arrayOfItems"];
//    [query includeKey:@"lists.name"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            //You found the user!
            PFUser *queriedUser = (PFUser *)object;
            NSArray *userLists = queriedUser[@"lists"];
            
            for (List *object in userLists) {
                NSString *name = object[@"name"];
                if ([name isEqual: self.list[@"name"]]){
                    NSLog(@"object %@", object);
                    NSLog(@"why is this empty%@", object[@"arrayOfItems"]);
                    
                    self.currentList = object;
                    self.arrayOfTasks = object[@"arrayOfItems"];
                    NSLog(@"%@", self.arrayOfTasks);
                    [self.tableView reloadData];
//                    self.arrayOfTasks = [[NSMutableArray alloc] init];
                }
                // do something with object
            }
            
        }
        
    }];
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

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TaskCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskCell" forIndexPath:indexPath];
    
    Task *task = self.arrayOfTasks[indexPath.row];
    cell.taskItemLabel.text = task[@"taskTitle"];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfTasks.count;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
