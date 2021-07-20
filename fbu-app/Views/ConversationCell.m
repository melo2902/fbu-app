//
//  ConversationCell.m
//  fbu-app
//
//  Created by mwen on 7/19/21.
//

#import "ConversationCell.h"
#import "Parse/Parse.h"
#import "Platform.h"
#import "Conversation.h"

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
        
        NSMutableArray *conversations = currPlatform[@"onReadConversations"];
        
        for (Conversation *conversationItem in conversations) {
            if ([conversationItem.conversationID isEqual:self.group.groupID]) {
                [conversations removeObject:conversationItem];
            }
        }
        
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
