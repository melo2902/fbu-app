//
//  MTDListViewController.h
//  fbu-app
//
//  Created by mwen on 7/12/21.
//

#import <UIKit/UIKit.h>
#import "MTDList.h"

NS_ASSUME_NONNULL_BEGIN

@class MTDListViewController;

@protocol MTDListViewControllerDelegate <NSObject>
- (void)MTDMainFeedViewController:(MTDListViewController *)controller;
@end

@interface MTDListViewController : UIViewController
@property (nonatomic, weak) id <MTDListViewControllerDelegate> delegate;
@property (strong, nonatomic) MTDList *list;
@end

NS_ASSUME_NONNULL_END
