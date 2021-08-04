//
//  MTDTaskViewController.m
//  fbu-app
//
//  Created by mwen on 7/21/21.
//

#import "MTDTaskViewController.h"
#import "MTDListViewController.h"
#import "XLForm.h"
#import "MTDTask.h"
#import "TaskHeaderView.h"

@interface MTDTaskViewController ()
@property (nonatomic) NSNumber *oldTaskTime;
@end

@implementation MTDTaskViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TaskHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"TaskHeaderView"];
    
    self.oldTaskTime = self.task.workingTime;
    
    [self initializeForm];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    if (section == 0) {
        TaskHeaderView *header = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"TaskHeaderView"];

        header.taskLabel.text = self.task.taskTitle;
        header.statusButton.selected = self.task.completed;
                
        return header;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 50;
    }
    
    return 20;
}

- (void)initializeForm {
    XLFormDescriptor * form;
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;

    form = [XLFormDescriptor formDescriptorWithTitle:@"Add Event"];
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    // Due Date
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"dueDate" rowType:XLFormRowDescriptorTypeDate title:@"Due Date"];
    row.value = self.task.dueDate;
    [row.cellConfig setObject:[UIFont fontWithName:@"Avenir Book" size:16] forKey:@"textLabel.font"];
    [section addFormRow:row];
    
    // Estimated work hours
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"workHours" rowType:XLFormRowDescriptorTypeDecimal title:@"Est. Working Hours"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    row.value = self.task.workingTime;
    [row.cellConfig setObject:[UIFont fontWithName:@"Avenir Book" size:16] forKey:@"textLabel.font"];
    [section addFormRow:row];
    
    XLFormRowDescriptor * buttonLeftAlignedRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"buttonLeftAligned" rowType:XLFormRowDescriptorTypeButton title:@"Add to My Day"];
    [buttonLeftAlignedRow.cellConfig setObject:@(NSTextAlignmentNatural) forKey:@"textLabel.textAlignment"];
    [buttonLeftAlignedRow.cellConfig setObject:[UIFont fontWithName:@"Avenir Book" size:16] forKey:@"textLabel.font"];
    buttonLeftAlignedRow.action.formSelector = @selector(connectToGroupMe:);
    [section addFormRow:buttonLeftAlignedRow];
    // Notes
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"notes" rowType:XLFormRowDescriptorTypeTextView];
    [row.cellConfigAtConfigure setObject:@"Notes" forKey:@"textView.placeholder"];
    row.value = self.task.notes;
    [row.cellConfig setObject:[UIFont fontWithName:@"Avenir Book" size:16] forKey:@"textLabel.font"];
    [section addFormRow:row];
    
    NSDateFormatter* day = [[NSDateFormatter alloc] init];
    [day setDateFormat: @"EEEE, LLLL d, yyyy"];
    NSString *date = [day stringFromDate:[NSDate date]];
    section.footerTitle = [NSString stringWithFormat:@"Created on %@", date];
    
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
        self.task.workingTime = newValue;
    } else if ([rowDescriptor.tag isEqualToString:@"notes"]) {
        self.task.notes = newValue;
    } else if ([rowDescriptor.tag isEqualToString:@"dueDate"]) {
        self.task.dueDate = newValue;
    } else if ([rowDescriptor.tag isEqualToString:@"taskTitle"]) {
        self.task.taskTitle = newValue;
    }
}

- (IBAction)onTapSave:(id)sender {
    if (self.task.taskTitle) {
        [self.task saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                float updatedWorkingTime = [self.task.workingTime floatValue] - [self.oldTaskTime floatValue];
                
                NSNumber* deltaTimeChange = [NSNumber numberWithFloat:updatedWorkingTime];
                
                [self.delegate ListViewController:self withTimeChange:deltaTimeChange];
            }
        }];
        
        [super.navigationController popViewControllerAnimated:YES];
    } else {
        NSLog(@"Please add a task title");
    }
}

@end
