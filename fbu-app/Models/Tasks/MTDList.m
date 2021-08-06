//
//  MTDList.m
//  fbu-app
//
//  Created by mwen on 7/12/21.
//

#import "MTDList.h"
#import "Parse/Parse.h"
#import "MTDUser.h"
#import "MTDList.h"

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

+ (void) updateTime: ( NSNumber *) time toList: (MTDList*) list withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    [list fetchIfNeeded];
    float updatedWorkingTime = [list.totalWorkingTime floatValue] + [time floatValue];
    list.totalWorkingTime = [NSNumber numberWithFloat:updatedWorkingTime];
    [list saveInBackgroundWithBlock: completion];
    
    if (![list.name isEqual:@"All"]) {
        [self updateAllListTime:time];
    }
}

+ (void) updateAllListTime: (NSNumber *) time {
    MTDUser *user = [MTDUser currentUser];

    PFQuery *query = [MTDUser query];
    [query whereKey:@"username" equalTo:user.username];
    [query includeKey:@"lists.name"];

    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            MTDUser *queriedUser = (MTDUser *)object;
            NSMutableArray *userLists = queriedUser.lists;
            for (MTDList *list in userLists) {
                if ([list.name isEqual:@"All"]) {
                    float updatedWorkingTime = [list.totalWorkingTime floatValue] + [time floatValue];
                    list.totalWorkingTime = [NSNumber numberWithFloat:updatedWorkingTime];
                    [list saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if (succeeded) {
                            NSLog(@"Save updated All List: %@", list);
                        }
                    }];
                }
            }
        }
    }];
}

@end
