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

+ (nonnull NSString *)parseClassName {
    return @"List";
}

+ (void) createList: ( NSString *)name withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    List *newList = [[List alloc] initWithClassName:@"List"];
    newList.name = name;
    newList.arrayOfItems = [NSMutableArray new];
    newList.totalWorkingTime = @(0);
    
    [newList saveInBackgroundWithBlock: completion];
}

@end
