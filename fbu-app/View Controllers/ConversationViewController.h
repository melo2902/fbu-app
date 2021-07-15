//
//  ConversationViewController.h
//  fbu-app
//
//  Created by mwen on 7/15/21.
//

#import <UIKit/UIKit.h>
#import "Group.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConversationViewController : UIViewController
@property (strong, nonatomic) Group *group;

@end

NS_ASSUME_NONNULL_END
