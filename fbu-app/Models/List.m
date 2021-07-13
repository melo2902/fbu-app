//
//  List.m
//  fbu-app
//
//  Created by mwen on 7/12/21.
//

#import "List.h"

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
    newList.arrayOfItems = [NSMutableArray new];
    newList.totalWorkingTime = @(0);
    newList.author = PFUser.currentUser;
    
    [newList saveInBackgroundWithBlock: completion];
    
    return newList;
}

@end
