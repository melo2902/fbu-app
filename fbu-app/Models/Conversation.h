//
//  Conversation.h
//  fbu-app
//
//  Created by mwen on 7/19/21.
//

#import "PFObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface Conversation : PFObject
@property (nonatomic, strong) NSString *conversationID;
@property (nonatomic, strong) NSString *latestTimeStamp;

+ (Conversation*) updateConversation: ( NSString *)conversationID withTimeStamp: (NSString *) timeStamp withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
