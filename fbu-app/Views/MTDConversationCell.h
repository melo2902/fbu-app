//
//  MTDConversationCell.h
//  fbu-app
//
//  Created by mwen on 7/19/21.
//

#import <UIKit/UIKit.h>
#import "MTDGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTDConversationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageLabel;
@property (strong, nonatomic) MTDGroup *group;
@property (weak, nonatomic) IBOutlet UILabel *dataAgoLabel;
@property (weak, nonatomic) IBOutlet UIButton *statusButton;
@property (nonatomic, copy) void(^completionButtonTapHandler)(void);
@end

NS_ASSUME_NONNULL_END
