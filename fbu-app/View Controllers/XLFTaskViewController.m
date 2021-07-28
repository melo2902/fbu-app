//
//  XLFTaskViewController.m
//  fbu-app
//
//  Created by mwen on 7/21/21.
//

#import "XLFTaskViewController.h"
#import "ListViewController.h"
#import "XLForm.h"
#import "Task.h"

@interface XLFTaskViewController ()

@end

@implementation XLFTaskViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    if (!self.task) {
        self.task = [Task createTask:@"" inList:self.listName withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                NSLog(@"Task created but not saved yet");
            }
        }];
    }
    
    [self initializeForm];
}

- (void)initializeForm {
    XLFormDescriptor * form;
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;

    form = [XLFormDescriptor formDescriptorWithTitle:@"Add Event"];

    // First section
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];

    // Title
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"taskTitle" rowType:XLFormRowDescriptorTypeText];
    row.value = self.task[@"taskTitle"];
    [section addFormRow:row];

    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    // Due Date
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"dueDate" rowType:XLFormRowDescriptorTypeDate title:@"Due Date"];
    row.value = self.task[@"dueDate"];
    [section addFormRow:row];
    
    // Estimated work hours
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"workHours" rowType:XLFormRowDescriptorTypeDecimal title:@"Work Hours"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    row.value = self.task[@"workingTime"];
    [section addFormRow:row];
    
    // Repeat due date
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"repeat" rowType:XLFormRowDescriptorTypeSelectorPush title:@"Repeat"];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Never"];
    row.selectorTitle = @"Repeat";
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Never"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Every Day"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Every Week"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Every 2 Weeks"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Every Month"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"Every Year"],
                            ];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"NOTES"];
    [form addFormSection:section];
    
    // Notes
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"notes" rowType:XLFormRowDescriptorTypeTextView];
    [row.cellConfigAtConfigure setObject:@"Notes" forKey:@"textView.placeholder"];
    row.value = self.task[@"notes"];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    XLFormRowDescriptor * buttonRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"button" rowType:XLFormRowDescriptorTypeButton title:@"Add to My Day"];
    buttonRow.action.formSelector = @selector(addToMyDay:);
    [section addFormRow:buttonRow];
    
    self.form = form;
}

-(void)addToMyDay:(XLFormRowDescriptor *)sender{
    if ([[sender.sectionDescriptor.formDescriptor formRowWithTag:@"button"].value boolValue]){
        NSLog(@"Button clicked");
    } else {
        NSLog(@"Button unclicked?");
    }
    [self deselectFormRow:sender];
}

#pragma mark - XLFormDescriptorDelegate
-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)rowDescriptor oldValue:(id)oldValue newValue:(id)newValue {
    [super formRowDescriptorValueHasChanged:rowDescriptor oldValue:oldValue newValue:newValue];
    if ([rowDescriptor.tag isEqualToString:@"workHours"]){
        self.task[@"workingTime"] = newValue;
    } else if ([rowDescriptor.tag isEqualToString:@"notes"]) {
        self.task[@"notes"] = newValue;
    } else if ([rowDescriptor.tag isEqualToString:@"dueDate"]) {
        self.task[@"dueDate"] = newValue;
    } else if ([rowDescriptor.tag isEqualToString:@"taskTitle"]) {
        self.task[@"taskTitle"] = newValue;
    }
}

- (IBAction)onTapSave:(id)sender {
    [self.task saveInBackground];
    [self.delegate ListViewController:self finishedUpdating:self.task];
    
    [super.navigationController popViewControllerAnimated:YES];
}

@end
