//
//  MTDList.m
//  fbu-app
//
//  Created by mwen on 7/12/21.
//

#import "MTDList.h"
#import "Parse/Parse.h"
#import "MTDUser.h"

@implementation MTDList
@dynamic name;
@dynamic arrayOfItems;
@dynamic totalWorkingTime;
@dynamic author;
@dynamic defaultList;

+ (nonnull NSString *)parseClassName {
    return @"List";
}

+ (MTDList *) createList: ( NSString *)name ifDefault: (BOOL) userDefined withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    MTDList *newList = [[MTDList alloc] initWithClassName:@"List"];
    newList.name = name;
    newList.arrayOfItems = [[NSMutableArray alloc] init];
    newList.totalWorkingTime = @(0);
    newList.defaultList = userDefined;
    
    [newList saveInBackgroundWithBlock: completion];
    
    return newList;
}

+ (void) addList: ( MTDList *)list withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    MTDUser *user = [MTDUser currentUser];
    
    NSMutableArray *currentLists = user.lists;
    [currentLists addObject:list];
    user.lists = currentLists;
    [user saveInBackground];
}

+ (void) addTask: ( MTDTask *)task toList: (MTDList*) list withCompletion: (PFBooleanResultBlock  _Nullable)completion {

    [list.arrayOfItems addObject:task];
  
    float updatedWorkingTime = [list.totalWorkingTime floatValue] + [task.workingTime floatValue];
    
    list.totalWorkingTime = [NSNumber numberWithFloat:updatedWorkingTime];
    
    [list saveInBackgroundWithBlock: completion];
}

+ (void) deleteTask: ( MTDTask *)task toList: (MTDList*) list withCompletion: (PFBooleanResultBlock  _Nullable)completion {

    [list.arrayOfItems removeObject:task];
    
    if (!task.completed) {
        float updatedWorkingTime = [list.totalWorkingTime floatValue] - [task.workingTime floatValue];
        list.totalWorkingTime = [NSNumber numberWithFloat:updatedWorkingTime];
    }
    
    [list saveInBackgroundWithBlock: completion];
}

+ (void) updateTime: ( NSNumber *) time toList: (MTDList*) list withCompletion: (PFBooleanResultBlock  _Nullable)completion {

    float updatedWorkingTime = [list.totalWorkingTime floatValue] + [time floatValue];
    
    list.totalWorkingTime = [NSNumber numberWithFloat:updatedWorkingTime];
    
    [list saveInBackgroundWithBlock: completion];
}

@end
