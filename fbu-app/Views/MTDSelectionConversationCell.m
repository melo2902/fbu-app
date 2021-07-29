//
//  MTDSelectionConversationCell.m
//  fbu-app
//
//  Created by mwen on 7/22/21.
//

#import "MTDSelectionConversationCell.h"
#import "Parse/Parse.h"
#import "MTDPlatform.h"
#import "MTDConversation.h"

@implementation MTDSelectionConversationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
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
