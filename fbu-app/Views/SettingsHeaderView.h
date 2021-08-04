//
//  SettingsHeaderView.h
//  fbu-app
//
//  Created by mwen on 8/4/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SettingsHeaderView : UITableViewHeaderFooterView
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userPFPView;

@end

NS_ASSUME_NONNULL_END
