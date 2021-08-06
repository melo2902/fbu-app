//
//  MTDGroup.h
//  fbu-app
//
//  Created by mwen on 7/16/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTDGroup : NSObject
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, strong) NSString *groupID;
@property (nonatomic, strong) NSString *lastSender;
@property (nonatomic, strong) NSString *lastMessage;
@property (nonatomic, strong) NSString *lastUpdated;
@property (nonatomic) BOOL onRead;
@property (strong) NSMutableDictionary *members;
-(instancetype)initWithJSONData:(NSDictionary*)data;
@end

NS_ASSUME_NONNULL_END
