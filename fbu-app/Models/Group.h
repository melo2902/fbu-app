//
//  Group.h
//  fbu-app
//
//  Created by mwen on 7/16/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Group : NSObject
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, strong) NSString *groupID;
@property (nonatomic, strong) NSString *lastSender;
@property (nonatomic, strong) NSString *lastMessage;

-(instancetype)initWithJSONData:(NSDictionary*)data;

@end

NS_ASSUME_NONNULL_END
