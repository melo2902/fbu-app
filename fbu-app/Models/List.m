//
//  List.m
//  fbu-app
//
//  Created by mwen on 7/12/21.
//

#import "List.h"
#import "Parse/Parse.h"

@implementation List
@dynamic name;
@dynamic arrayOfItems;
@dynamic totalWorkingTime;
@dynamic author;
@dynamic defaultList;

+ (nonnull NSString *)parseClassName {
    return @"List";
}

+ (List *) createList: ( NSString *)name ifDefault: (BOOL) userDefined withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    List *newList = [[List alloc] initWithClassName:@"List"];
    newList.name = name;
    newList.arrayOfItems = [[NSMutableArray alloc] init];
    newList.totalWorkingTime = @(0);
    newList.defaultList = userDefined;
    
    [newList saveInBackgroundWithBlock: completion];
    
    return newList;
}

+ (void) addList: ( List *)list withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    PFUser *currentUser = [PFUser currentUser];
    NSMutableArray *currentLists = currentUser[@"lists"];
    [currentLists addObject:list];
    currentUser[@"lists"] = currentLists;
    [currentUser saveInBackground];
}

+ (void) addTask: ( Task *)task toList: (List*) list withCompletion: (PFBooleanResultBlock  _Nullable)completion {

    [list[@"arrayOfItems"] addObject:task];
  
    float updatedWorkingTime = [list[@"totalWorkingTime"] floatValue] + [task[@"workingTime"] floatValue];
    
    list[@"totalWorkingTime"] = [NSNumber numberWithFloat:updatedWorkingTime];
    
    [list saveInBackgroundWithBlock: completion];
}

+ (void) deleteTask: ( Task *)task toList: (List*) list withCompletion: (PFBooleanResultBlock  _Nullable)completion {

    [list[@"arrayOfItems"] removeObject:task];
    float updatedWorkingTime = [list[@"totalWorkingTime"] floatValue] - [task[@"workingTime"] floatValue];
    
    list[@"totalWorkingTime"] = [NSNumber numberWithFloat:updatedWorkingTime];
    
    [list saveInBackgroundWithBlock: completion];
}

+ (void) updateTask: ( Task *)task toList: (List*) list changeCompletion: (BOOL) completed withCompletion: (PFBooleanResultBlock  _Nullable)completion {

    if (completed) {
        float updatedWorkingTime = [list[@"totalWorkingTime"] floatValue] - [task[@"workingTime"] floatValue];
        
        list[@"totalWorkingTime"] = [NSNumber numberWithFloat:updatedWorkingTime];
    } else {
        float updatedWorkingTime = [list[@"totalWorkingTime"] floatValue] + [task[@"workingTime"] floatValue];
        
        list[@"totalWorkingTime"] = [NSNumber numberWithFloat:updatedWorkingTime];
    }
    
    [list saveInBackgroundWithBlock: completion];
}
@end
