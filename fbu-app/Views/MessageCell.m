//
//  MessageCell.m
//  fbu-app
//
//  Created by mwen on 7/15/21.
//

#import "MessageCell.h"
#import "Parse/Parse.h"
#import "Platform.h"

@implementation MessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onTapStatusButton:(id)sender {
    if (self.statusButton.selected) {
        NSLog(@"Button is not selected!");
        self.statusButton.selected = NO;
    // Let change the CSS of the selection criteria
        
    } else {
        NSLog(@"Button is selected!");
        self.statusButton.selected = YES;
        
//        This is for specific case when the user leaves the person, on read, not when they reply
        Platform *currPlatform = PFUser.currentUser[@"GroupMe"];
        [currPlatform fetchIfNeeded];
       
        
//        Conversation *updateConversation = [Conversation updateConversation:self.group.groupID withTimeStamp: self.group.lastUpdated withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
//            if (succeeded) {
//                NSLog(@"Conversation created");
//            }
//        }];
        
        NSMutableDictionary *pastConversations = currPlatform[@"onReadConversations"][0];
        
        pastConversations[self.group.groupID] = self.group.lastUpdated;
        
//        if ([pastConversations objectForKey:self.group.groupID]){
//            pastConversations[self.group]
//        }
        
        currPlatform[@"onReadConversations"][0] = pastConversations;
        
        [currPlatform saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                NSLog(@"Saved conversation ID with associated timestamp%@", currPlatform[@"onReadConversations"]);
            }
        }];
    }
}


@end
