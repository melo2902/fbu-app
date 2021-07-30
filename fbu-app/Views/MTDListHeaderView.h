//
//  MTDListHeaderView.h
//  fbu-app
//
//  Created by mwen on 7/30/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTDListHeaderView : UITableViewHeaderFooterView
@property (weak, nonatomic) IBOutlet UILabel *titleLabelTitle;
@property (weak, nonatomic) IBOutlet UILabel *workingTimeLabel;
@property (weak, nonatomic) IBOutlet UITextField *addedTaskBar;
@property (weak, nonatomic) IBOutlet UIButton *addTaskButton;
@property (nonatomic, copy) void(^taskButtonTapHandler)(void);
@end

NS_ASSUME_NONNULL_END
