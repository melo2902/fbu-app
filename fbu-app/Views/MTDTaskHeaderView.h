//
//  MTDTaskHeaderView.h
//  fbu-app
//
//  Created by mwen on 8/4/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTDTaskHeaderView : UITableViewHeaderFooterView
@property (weak, nonatomic) IBOutlet UIButton *statusButton;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (nonatomic, copy) void(^statusButtonTapHandler)(void);
@end

NS_ASSUME_NONNULL_END
