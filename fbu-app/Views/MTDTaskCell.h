//
//  MTDTaskCell.h
//  fbu-app
//
//  Created by mwen on 7/13/21.
//

#import <UIKit/UIKit.h>
#import "MTDTask.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTDTaskCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *taskItemLabel;
@property (strong, nonatomic) MTDTask* task;
@property (weak, nonatomic) IBOutlet UIButton *completionButton;
@property (weak, nonatomic) IBOutlet UILabel *dueDateLabel;
@property (nonatomic, copy) void(^completionButtonTapHandler)(void);
@end

NS_ASSUME_NONNULL_END
