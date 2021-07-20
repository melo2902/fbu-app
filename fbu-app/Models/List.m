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

+ (nonnull NSString *)parseClassName {
    return @"List";
}

+ (List *) createList: ( NSString *)name withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    List *newList = [[List alloc] initWithClassName:@"List"];
    newList.name = name;
    newList.arrayOfItems = [[NSMutableArray alloc] init];
    newList.totalWorkingTime = @(0);
    
    [newList saveInBackgroundWithBlock: completion];
    
    return newList;
}

+ (void) addTask: ( Task *)task toList: (List*) list withCompletion: (PFBooleanResultBlock  _Nullable)completion {

    [list[@"arrayOfItems"] addObject:task];
    [list saveInBackgroundWithBlock: completion];
}

+ (void) deleteTask: ( Task *)task toList: (List*) list withCompletion: (PFBooleanResultBlock  _Nullable)completion {

    [list[@"arrayOfItems"] removeObject:task];
    [list saveInBackgroundWithBlock: completion];
}

@end
