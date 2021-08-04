//
//  TaskHeaderView.h
//  fbu-app
//
//  Created by mwen on 8/4/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TaskHeaderView : UITableViewHeaderFooterView
@property (weak, nonatomic) IBOutlet UILabel *taskLabel;
@property (weak, nonatomic) IBOutlet UIButton *statusButton;

@end

NS_ASSUME_NONNULL_END
