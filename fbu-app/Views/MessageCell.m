//
//  MessageCell.m
//  fbu-app
//
//  Created by mwen on 7/15/21.
//

#import "MessageCell.h"
#import "Parse/Parse.h"

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
    PFUser *user = PFUser.currentUser;
    
    if (self.statusButton.selected) {
        NSLog(@"Button is not selected!");
        self.statusButton.selected = NO;
    // Let change the CSS of the selection criteria
        
//        self.group[@"completed"] = @NO;
        
    } else {
        NSLog(@"Button is selected!");
        self.statusButton.selected = YES;
        
//        This is for specific case when the user leaves the person, on read, not when they reply
        [user[@"GroupMe"][@"readConversations"] addObject:self.group.groupID];
        
        NSLog(@"update%@", user[@"GroupMe"][@"readConversations"]);
//        self.group[@"completed"] = @YES;
    }
    
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"saved conversation ID");
        }
    }];
//    [self.task saveInBackground];
}


@end
