//
//  MTDTaskViewController.h
//  fbu-app
//
//  Created by mwen on 7/21/21.
//

#import "XLFormViewController.h"
#import "MTDTask.h"

NS_ASSUME_NONNULL_BEGIN

@class MTDTaskViewController;

@protocol XLFTaskViewControllerDelegate <NSObject>
- (void)ListViewController:(MTDTaskViewController *)controller finishedUpdating:(MTDTask *)task;
@end

@interface MTDTaskViewController : XLFormViewController
@property (nonatomic, weak) id <XLFTaskViewControllerDelegate> delegate;
@property (strong, nonatomic) MTDTask *task;
@property (strong, nonatomic) NSString *listName;
@end

NS_ASSUME_NONNULL_END
