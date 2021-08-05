//
//  MTDAddTaskViewController.m
//  fbu-app
//
//  Created by mwen on 8/3/21.
//

#import "MTDAddTaskViewController.h"
#import "MTDTask.h"
#import <STPopup/STPopup.h>
#import "DateTools.h"
#import "MTDList.h"

@interface MTDAddTaskViewController ()
@property (strong, nonatomic) UITextField *dateTextField;
@property (nonatomic, strong) NSDate *dueDate;
@end

@implementation MTDAddTaskViewController{
    UITextField *_textField;
    UITextField *_workingHoursTextField;
    UITextField *_notesTextField;
    UITextField *_dateTextField;
}

- (instancetype)init {
    if (self = [super init]) {
        self.title = @"New task";
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"pencil"] style:UIBarButtonItemStylePlain target:self action:@selector(saveTask)];
        self.contentSizeInPopup = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height / 6);
        self.view.layer.cornerRadius = 20;
        self.landscapeContentSizeInPopup = CGSizeMake(400, 200);
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    _textField = [UITextField new];
    _textField.placeholder = @"Add a new task";
    _textField.font = [UIFont fontWithName:@"Avenir Book" size:16];
    _textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
    _textField.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:_textField];
    
    _workingHoursTextField = [UITextField new];
    _workingHoursTextField.placeholder = @"Est. working hours";
    _workingHoursTextField.font = [UIFont fontWithName:@"Avenir Book" size:14];
    _workingHoursTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
    _workingHoursTextField.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:_workingHoursTextField];
    
    self.dateTextField = [UITextField new];
    self.dateTextField.placeholder = @"Due Date";
    self.dateTextField.font = [UIFont fontWithName:@"Avenir Book" size:14];
    self.dateTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
    self.dateTextField.leftViewMode = UITextFieldViewModeAlways;
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    [datePicker addTarget:self action:@selector(onDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.dateTextField.inputView = datePicker;
    
    [self.view addSubview:self.dateTextField];
    
    _notesTextField = [UITextField new];
    _notesTextField.placeholder = @"Notes";
    _notesTextField.font = [UIFont fontWithName:@"Avenir Book" size:14];
    _notesTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
    _notesTextField.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:_notesTextField];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _textField.frame = CGRectMake(10, 10, self.view.frame.size.width - 20, 20);
    _workingHoursTextField.frame = CGRectMake(10, 40, self.view.frame.size.width / 3, 20);
    self.dateTextField.frame = CGRectMake(self.view.frame.size.width / 3 + 20, 40, self.view.frame.size.width / 3 + 20, 20);
    _notesTextField.frame = CGRectMake(10, 70, self.view.frame.size.width - 20, 60);
}

- (void) saveTask {
    if (_textField.text) {
        MTDTask *task = [MTDTask createTask:_textField.text inList:self.list.name withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                NSLog(@"Task created but not saved yet");
            }
        }];
        
        task.workingTime = @( [_workingHoursTextField.text floatValue]);
        task.notes = _notesTextField.text;
        
        if (![self.dateTextField.text isEqual:@""]) {
            task.dueDate = self.dueDate;
        }
        
        [task saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [self updateListTime: task];
            }
        }];
        
    } else {
        NSLog(@"Please add a task title");
    }
}

- (void)onDatePickerValueChanged:(UIDatePicker *)datePicker {
    self.dateTextField.text = [datePicker.date formattedDateWithFormat:@"M/d/yy"];
    self.dueDate = datePicker.date;
}

- (void) updateListTime: (MTDTask *) task {
    
    [MTDList updateTime: @([_workingHoursTextField.text floatValue]) toList:self.list  withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [self.popupController dismiss];
        }
    }];
}

@end
