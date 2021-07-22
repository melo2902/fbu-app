//
//  SelectionConversationCell.m
//  fbu-app
//
//  Created by mwen on 7/22/21.
//

#import "SelectionConversationCell.h"
#import "Parse/Parse.h"
#import "Platform.h"
#import "Conversation.h"

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
   
    } else {
        NSLog(@"Button is selected!");
        self.selectConversationButton.selected = YES;
        
        Platform *currPlatform = PFUser.currentUser[@"GroupMe"];
        [currPlatform fetchIfNeeded];
        
        NSMutableArray *conversations = currPlatform[@"onReadConversations"];
        
        Conversation *updateConversation = [Conversation updateConversation:self.group.groupID withTimeStamp: self.group.lastUpdated withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                NSLog(@"Conversation created");
            }
        }];
        
        [conversations addObject: updateConversation];
        
        currPlatform[@"onReadConversations"] = conversations;
        
        [currPlatform saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                NSLog(@"Saved conversation ID with associated timestamp%@", currPlatform[@"onReadConversations"]);
            }
        }];
    }
}



@end
