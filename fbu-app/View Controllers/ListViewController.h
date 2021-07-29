//
//  ListViewController.h
//  fbu-app
//
//  Created by mwen on 7/12/21.
//

#import <UIKit/UIKit.h>
#import "MTDList.h"

NS_ASSUME_NONNULL_BEGIN

@interface ListViewController : UIViewController
@property (strong, nonatomic) MTDList *list;
@end

NS_ASSUME_NONNULL_END
