//
//  MTDList.h
//  fbu-app
//
//  Created by mwen on 7/12/21.
//

#import "PFObject.h"
#import "Parse/Parse.h"
#import "MTDTask.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTDList : PFObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *arrayOfItems;
@property (nonatomic, strong) NSNumber *totalWorkingTime;
@property (nonatomic, strong) PFUser *author;
@property (nonatomic) BOOL defaultList;

+ (MTDList *) createList: ( NSString *)name ifDefault: (BOOL) userDefined withCompletion: (PFBooleanResultBlock  _Nullable)completion;

+ (void) addList: ( MTDList *)list withCompletion: (PFBooleanResultBlock  _Nullable)completion;

+ (void) addTask: ( MTDTask *)task toList: (MTDList *) list withCompletion: (PFBooleanResultBlock  _Nullable)completion;

+ (void) deleteTask: ( MTDTask *)task toList: (MTDList *) list withCompletion: (PFBooleanResultBlock  _Nullable)completion;

+ (void) updateTime: ( NSNumber *) time toList: (MTDList*) list withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
