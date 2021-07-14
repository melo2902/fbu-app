//
//  TaskViewController.m
//  fbu-app
//
//  Created by mwen on 7/12/21.
//

#import "TaskViewController.h"

@interface TaskViewController ()
@property (weak, nonatomic) IBOutlet UILabel *taskTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *notesLabel;
@end

@implementation TaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.taskTitleLabel.text = self.task[@"taskTitle"];
    self.notesLabel.text = self.task[@"notes"];
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
