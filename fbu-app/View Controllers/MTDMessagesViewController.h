//
//  MTDMessagesViewController.h
//  fbu-app
//
//  Created by mwen on 7/26/21.
//

#import "JSQMessagesViewController.h"
#import <JSQMessagesViewController/JSQMessages.h>
#import "MTDGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTDMessagesViewController : JSQMessagesViewController
@property (strong, nonatomic) MTDGroup *group;
@end

NS_ASSUME_NONNULL_END
