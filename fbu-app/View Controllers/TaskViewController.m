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
    
    self.taskTitleLabel.text = self.task[@"taskTitle"];
    self.notesLabel.text = self.task[@"notes"];
}

@end
