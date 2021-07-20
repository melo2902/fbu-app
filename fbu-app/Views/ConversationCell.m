//
//  ConversationCell.m
//  fbu-app
//
//  Created by mwen on 7/19/21.
//

#import "ConversationCell.h"
#import "Parse/Parse.h"
#import "Platform.h"

@implementation ConversationCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)onTapStatusButton:(id)sender {
    if (self.statusButton.selected) {
        NSLog(@"Button is not selected!");
        self.statusButton.selected = NO;
   
    } else {
        NSLog(@"Button is selected!");
        self.statusButton.selected = YES;
        
        Platform *currPlatform = PFUser.currentUser[@"GroupMe"];
        [currPlatform fetchIfNeeded];
        
        NSMutableDictionary *pastConversations = currPlatform[@"onReadConversations"][0];
        pastConversations[self.group.groupID] = self.group.lastUpdated;
        currPlatform[@"onReadConversations"][0] = pastConversations;
        
        [currPlatform saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                NSLog(@"Saved conversation ID with associated timestamp%@", currPlatform[@"onReadConversations"]);
            }
        }];
    }
}


@end
