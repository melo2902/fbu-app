//
//  MTDMainFeedHeaderView.h
//  fbu-app
//
//  Created by mwen on 7/30/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTDMainFeedHeaderView : UITableViewHeaderFooterView
@property (weak, nonatomic) IBOutlet UIImageView *pfpView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@end

NS_ASSUME_NONNULL_END
