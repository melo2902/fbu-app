//
//  SelectionConversationCell.h
//  fbu-app
//
//  Created by mwen on 7/22/21.
//

#import <UIKit/UIKit.h>
#import "Group.h"

NS_ASSUME_NONNULL_BEGIN

@interface SelectionConversationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectConversationButton;
@property (strong, nonatomic) Group *group;

@end

NS_ASSUME_NONNULL_END
