//
//  Platform.h
//  fbu-app
//
//  Created by mwen on 7/16/21.
//

#import "PFObject.h"
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface Platform : PFObject
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) NSString *platformName;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSMutableArray *onReadConversations;

-(instancetype)initWithJSONData:(NSDictionary*)data onPlatform: (NSString*) platform;

@end

NS_ASSUME_NONNULL_END
