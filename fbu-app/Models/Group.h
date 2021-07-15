//
//  Group.h
//  fbu-app
//
//  Created by mwen on 7/15/21.
//

#import "PFObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface Group : PFObject
//@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, strong) NSString *groupID;
@property (nonatomic, strong) NSString *lastMessage;

-(instancetype)initWithJSONData:(NSDictionary*)data;
@end

NS_ASSUME_NONNULL_END
