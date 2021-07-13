//
//  Task.m
//  fbu-app
//
//  Created by mwen on 7/12/21.
//

#import "Task.h"

@implementation Task
@dynamic author;
@dynamic taskTitle;
@dynamic workingTime;
@dynamic dueDate;
@dynamic notes;
@dynamic completed;

+ (void) createTask: ( NSString *)name withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    Task *newTask = [[Task alloc] initWithClassName:@"Task"];
    newTask.author = PFUser.currentUser;
    newTask.taskTitle = name;
    newTask.workingTime = @(0);
    
//    NSDate *today = [NSDate date];
//    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setDateFormat:@"MM/dd/yyyy"];
//    NSString *dateString = [dateFormat stringFromDate:today];
    newTask.dueDate = [NSDate date];
    
    newTask.notes = @"";
    newTask.completed = NO;
    
    [newTask saveInBackgroundWithBlock: completion];
}

@end
