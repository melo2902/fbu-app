//
//  MTDListCell.h
//  fbu-app
//
//  Created by mwen on 7/12/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTDListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *listNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *listIcon;
@property (weak, nonatomic) IBOutlet UILabel *numTasksLabel;
@end

NS_ASSUME_NONNULL_END
