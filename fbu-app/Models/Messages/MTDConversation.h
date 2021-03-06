//
//  MTDConversation.h
//  fbu-app
//
//  Created by mwen on 7/20/21.
//

#import "PFObject.h"
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTDConversation : PFObject <PFSubclassing>
@property (nonatomic, strong) NSString *conversationID;
@property (nonatomic, strong) NSString *latestTimeStamp;
+ (MTDConversation*) updateConversation: ( NSString *)conversationID withTimeStamp: (NSString *) timeStamp withCompletion: (PFBooleanResultBlock  _Nullable)completion;
@end

NS_ASSUME_NONNULL_END
