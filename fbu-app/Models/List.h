//
//  List.h
//  fbu-app
//
//  Created by mwen on 7/12/21.
//

#import "PFObject.h"
#import "Parse/Parse.h"
#import "Task.h"

NS_ASSUME_NONNULL_BEGIN

@interface List : PFObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *arrayOfItems;
@property (nonatomic, strong) NSNumber *totalWorkingTime;
@property (nonatomic, strong) PFUser *author;

+ (List *) createList: ( NSString *)name withCompletion: (PFBooleanResultBlock  _Nullable)completion;

+ (void) addTask: ( Task *)task toList: (List *) list withCompletion: (PFBooleanResultBlock  _Nullable)completion;

+ (void) deleteTask: ( Task *)task toList: (List *) list withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
