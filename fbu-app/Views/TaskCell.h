//
//  TaskCell.h
//  fbu-app
//
//  Created by mwen on 7/13/21.
//

#import <UIKit/UIKit.h>
#import "Task.h"

NS_ASSUME_NONNULL_BEGIN

//@protocol TaskCellDelegate <NSObject>
//- (void)ListViewController:(TaskCell *)cell updateCompletion:(NSString *)description;
//@end

@interface TaskCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *taskItemLabel;
@property (strong, nonatomic) Task* task;
@property (weak, nonatomic) IBOutlet UIButton *completionButton;
@property (nonatomic, copy) void(^completionButtonTapHandler)(void);
@end

NS_ASSUME_NONNULL_END
