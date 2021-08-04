//
//  MTDInitialFilterViewController.h
//  fbu-app
//
//  Created by mwen on 7/22/21.
//

#import <UIKit/UIKit.h>
#import "XLForm.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTDInitialFilterViewController : UIViewController <XLFormRowDescriptorViewController>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *filterConversationButton;
@end

NS_ASSUME_NONNULL_END
