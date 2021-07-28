//
//  Task.m
//  fbu-app
//
//  Created by mwen on 7/12/21.
//

#import "Task.h"
#import "List.h"

@implementation Task
@dynamic author;
@dynamic inLists;
@dynamic taskTitle;
@dynamic workingTime;
@dynamic dueDate;
@dynamic notes;
@dynamic completed;

+ (nonnull NSString *)parseClassName {
    return @"Task";
}

+ (Task*) createTask: ( NSString *)name inList: ( NSString *)list withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    Task *newTask = [[Task alloc] initWithClassName:@"Task"];
    
    newTask.author = PFUser.currentUser;
    
    NSMutableArray *lists = [[NSMutableArray alloc] init];
    [lists addObject: list];
    if (![list isEqual:@"All"]){
        [lists addObject:@"All"];
    }
    
    newTask.inLists = lists;
    
    newTask.taskTitle = name;
    newTask.workingTime = @(1); // Allow the user to change the default working time
    newTask.notes = @"";
    newTask.completed = NO;
    
    return newTask;
}

@end
