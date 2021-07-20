//
//  Conversation.m
//  fbu-app
//
//  Created by mwen on 7/20/21.
//

#import "Conversation.h"

@implementation Conversation
@dynamic conversationID;
@dynamic latestTimeStamp;

+ (nonnull NSString *)parseClassName {
    return @"Conversation";
}

+ (Conversation*) updateConversation: ( NSString *)conversationID withTimeStamp: (NSString *) timeStamp withCompletion: (PFBooleanResultBlock  _Nullable)completion {

    Conversation *newConversation = [[Conversation alloc] initWithClassName:@"Conversation"];
    newConversation.conversationID = conversationID;
    newConversation.latestTimeStamp = timeStamp;

    [newConversation saveInBackgroundWithBlock: completion];

    return newConversation;
}
@end
