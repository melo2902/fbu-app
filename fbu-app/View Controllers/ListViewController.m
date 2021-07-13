//
//  ListViewController.m
//  fbu-app
//
//  Created by mwen on 7/12/21.
//

#import "ListViewController.h"
#import "Task.h"

@interface ListViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *listNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *workingTimeLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *addedTaskBar;
@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.addedTaskBar.delegate = self;
    
    self.listNameLabel.text = self.list[@"name"];
//    self.workingTimeLabel.text = self.list[@"totalWorkingTime"];
}

// Also, want to be able to add a long version of it
// This is the short term quick add
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"%@", self.addedTaskBar.text);
    
    [Task createTask:self.addedTaskBar.text withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
    }];
    
    self.addedTaskBar.text = @"";
    [self.tableView reloadData];

    return YES;
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
