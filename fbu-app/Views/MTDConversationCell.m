//
//  MTDConversationCell.m
//  fbu-app
//
//  Created by mwen on 7/19/21.
//

#import "MTDConversationCell.h"
#import "Parse/Parse.h"
#import "MTDPlatform.h"
#import "MTDUser.h"
#import "MTDConversation.h"
#import "DateTools.h"

@implementation MTDConversationCell

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
        self.group.onRead = NO;
        
        MTDUser *user = [MTDUser currentUser];
        MTDPlatform *currPlatform = user.GroupMe;
        [currPlatform fetchIfNeeded];
        
        NSMutableArray *conversations = currPlatform.onReadConversations;
        
        for (MTDConversation *conversationItem in conversations) {
            if ([conversationItem.conversationID isEqual:self.group.groupID]) {
                [conversations removeObject:conversationItem];
                break;
            }
        }
        
        currPlatform.onReadConversations = conversations;
        
        [currPlatform saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                NSLog(@"Saved conversation ID with associated timestamp%@", currPlatform.onReadConversations);
                
                self.completionButtonTapHandler();
                
                self.statusButton.selected = NO;
            }
        }];
   
    } else {
        NSLog(@"Button is selected!");
        self.statusButton.selected = YES;
        self.group.onRead = YES;
        
        MTDUser *user = [MTDUser currentUser];
        MTDPlatform *currPlatform = user.GroupMe;
        [currPlatform fetchIfNeeded];
        
        NSMutableArray *conversations = currPlatform.onReadConversations;
        
        for (MTDConversation *conversationItem in conversations) {
            if ([conversationItem.conversationID isEqual:self.group.groupID]) {
                [conversations removeObject:conversationItem];
                
                break;
            }
        }
        
        MTDConversation *updateConversation = [MTDConversation updateConversation:self.group.groupID withTimeStamp: self.group.lastUpdated withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                NSLog(@"Conversation created");
            }
        }];
        
        [conversations addObject: updateConversation];
        currPlatform.onReadConversations = conversations;
        
        [currPlatform saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                NSLog(@"Saved conversation ID with associated timestamp%@", currPlatform.onReadConversations);
                
                self.completionButtonTapHandler();
                
                self.statusButton.selected = NO;
            }
        }];
    }
}


@end
