//
//  XLFTaskViewController.m
//  fbu-app
//
//  Created by mwen on 7/21/21.
//

#import "XLFTaskViewController.h"
#import "XLForm.h"

NSString *const kDateTimeInline = @"dateTimeInline";

@interface XLFTaskViewController ()

@end

@implementation XLFTaskViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        [self initializeForm];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self){
        [self initializeForm];
    }
    return self;
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
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"tagLine" rowType:XLFormRowDescriptorTypeText];
    [row.cellConfigAtConfigure setObject:@"Tag Line" forKey:@"textField.placeholder"];
    [section addFormRow:row];

    // Due Date
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDateTimeInline rowType:XLFormRowDescriptorTypeDateTimeInline title:@"Due Date"];
    row.value = [NSDate new];
    [section addFormRow:row];
    
    // Estimated work hours
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"workHours" rowType:XLFormRowDescriptorTypeDecimal title:@"Work Hours"];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
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
    
    // Notes
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"notes" rowType:XLFormRowDescriptorTypeTextView];
    [row.cellConfigAtConfigure setObject:@"Notes" forKey:@"textView.placeholder"];
    [section addFormRow:row];
    
    self.form = form;
}

#pragma mark - XLFormDescriptorDelegate
-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)rowDescriptor oldValue:(id)oldValue newValue:(id)newValue {
    [super formRowDescriptorValueHasChanged:rowDescriptor oldValue:oldValue newValue:newValue];
    if ([rowDescriptor.tag isEqualToString:@"workHours"]){
        if ([[rowDescriptor.value valueData] isEqualToNumber:@(0)] == NO && [[oldValue valueData] isEqualToNumber:@(0)]){
        
            XLFormRowDescriptor * newRow = [rowDescriptor copy];
            newRow.tag = @"secondAlert";
            newRow.title = @"Second Alert";
            [self.form addFormRow:newRow afterRow:rowDescriptor];
        }
        else if ([[oldValue valueData] isEqualToNumber:@(0)] == NO && [[newValue valueData] isEqualToNumber:@(0)]){
            [self.form removeFormRowWithTag:@"secondAlert"];
        }
    }
}

@end
