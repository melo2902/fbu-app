//
//  TaskCell.m
//  fbu-app
//
//  Created by mwen on 7/13/21.
//

#import "TaskCell.h"
#import "Parse/Parse.h"

@implementation TaskCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onTapStatus:(id)sender {
    if (self.completionButton.selected) {
        NSLog(@"Button is not selected!");
        self.completionButton.selected = NO;
    // Let change the CSS of the selection criteria
        
        self.task[@"completed"] = @NO;
        
    } else {
        NSLog(@"Button is selected!");
        self.completionButton.selected = YES;
        self.task[@"completed"] = @YES;
    }
    
    [self.task saveInBackground];
}

@end
