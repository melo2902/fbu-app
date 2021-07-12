//
//  Task.h
//  fbu-app
//
//  Created by mwen on 7/12/21.
//

#import "PFObject.h"
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface Task : PFObject
@property (nonatomic, strong) NSString *taskTitle;
@property (nonatomic, strong) NSNumber *workingTime;
@property (nonatomic, strong) NSDate *dueDate;
@property (nonatomic, strong) NSString *notes;
@property (nonatomic) BOOL completed;

+ (void) createTask: ( NSString *)name withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
