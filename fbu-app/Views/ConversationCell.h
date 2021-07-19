//
//  ConversationCell.h
//  fbu-app
//
//  Created by mwen on 7/19/21.
//

#import <UIKit/UIKit.h>
#import "Group.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConversationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageLabel;
@property (strong, nonatomic) Group *group;
@property (weak, nonatomic) IBOutlet UIButton *statusButton;
@end

NS_ASSUME_NONNULL_END
