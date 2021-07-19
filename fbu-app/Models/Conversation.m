//
//  Conversation.m
//  fbu-app
//
//  Created by mwen on 7/19/21.
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
    
//    newTask.author = PFUser.currentUser;
//    newTask.listTitle = list;
//    newTask.taskTitle = name;
//    newTask.workingTime = @(0);
    
//    NSDate *today = [NSDate date];
//    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setDateFormat:@"MM/dd/yyyy"];
//    NSString *dateString = [dateFormat stringFromDate:today];
//    newTask.dueDate = [NSDate date];
//
//    newTask.notes = @"";
//    newTask.completed = NO;
    
    [newConversation saveInBackgroundWithBlock: completion];
    
    return newConversation;
}

@end
