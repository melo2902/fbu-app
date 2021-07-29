//
//  XLFTaskViewController.h
//  fbu-app
//
//  Created by mwen on 7/21/21.
//

#import "XLFormViewController.h"
#import "MTDTask.h"

NS_ASSUME_NONNULL_BEGIN

@class XLFTaskViewController;

@protocol XLFTaskViewControllerDelegate <NSObject>
- (void)ListViewController:(XLFTaskViewController *)controller finishedUpdating:(MTDTask *)task;
@end

@interface XLFTaskViewController : XLFormViewController
@property (nonatomic, weak) id <XLFTaskViewControllerDelegate> delegate;
@property (strong, nonatomic) MTDTask *task;
@property (strong, nonatomic) NSString *listName;
@end

NS_ASSUME_NONNULL_END
