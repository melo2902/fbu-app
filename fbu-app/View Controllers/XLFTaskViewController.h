//
//  XLFTaskViewController.h
//  fbu-app
//
//  Created by mwen on 7/21/21.
//

#import "XLFormViewController.h"
#import "Task.h"

NS_ASSUME_NONNULL_BEGIN

@interface XLFTaskViewController : XLFormViewController
@property (strong, nonatomic) Task *task;
@end

NS_ASSUME_NONNULL_END
