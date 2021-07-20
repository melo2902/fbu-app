//
//  MessageCell.h
//  fbu-app
//
//  Created by mwen on 7/15/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MessageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageLabel;
@end

NS_ASSUME_NONNULL_END
