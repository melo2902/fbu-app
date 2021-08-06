//
//  MTDConversation.m
//  fbu-app
//
//  Created by mwen on 7/20/21.
//

#import "MTDConversation.h"

@implementation MTDConversation
@dynamic conversationID;
@dynamic latestTimeStamp;

+ (nonnull NSString *)parseClassName {
    return @"Conversation";
}

+ (MTDConversation*) updateConversation: ( NSString *)conversationID withTimeStamp: (NSString *) timeStamp withCompletion: (PFBooleanResultBlock  _Nullable)completion {

    MTDConversation *newConversation = [[MTDConversation alloc] initWithClassName:@"Conversation"];
    newConversation.conversationID = conversationID;
    newConversation.latestTimeStamp = timeStamp;

    [newConversation saveInBackgroundWithBlock: completion];

    return newConversation;
}

@end
