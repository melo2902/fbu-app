//
//  MessagesViewController.h
//  fbu-app
//
//  Created by mwen on 7/26/21.
//

#import "JSQMessagesViewController.h"
#import <JSQMessagesViewController/JSQMessages.h>
#import "Group.h"

NS_ASSUME_NONNULL_BEGIN

@interface MessagesViewController : JSQMessagesViewController
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (strong, nonatomic) Group *group;
@end

NS_ASSUME_NONNULL_END
