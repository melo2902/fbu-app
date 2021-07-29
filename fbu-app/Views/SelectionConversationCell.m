//
//  SelectionConversationCell.m
//  fbu-app
//
//  Created by mwen on 7/22/21.
//

#import "SelectionConversationCell.h"
#import "Parse/Parse.h"
#import "MTDPlatform.h"
#import "MTDConversation.h"

@implementation SelectionConversationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onSelectConversation:(id)sender {
    if (self.selectConversationButton.selected) {
        NSLog(@"Button is not selected!");
        self.selectConversationButton.selected = NO;
        self.group.onRead = YES;

    } else {
        NSLog(@"Button is selected!");
        self.selectConversationButton.selected = YES;
        self.group.onRead = NO;
    }
}



@end
