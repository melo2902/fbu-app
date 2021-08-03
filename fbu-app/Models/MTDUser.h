//
//  MTDUser.h
//  fbu-app
//
//  Created by mwen on 8/3/21.
//

#import "PFUser.h"
#import <Parse/Parse.h>
#import "MTDPlatform.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTDUser : PFUser <PFSubclassing>
// email, username, password already implemented
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) PFFileObject * _Nullable pfp;
@property (nonatomic, strong) NSMutableArray *lists;
@property (nonatomic, strong) MTDPlatform *GroupMe;
@property (nonatomic) NSString *authToken;
@end

NS_ASSUME_NONNULL_END
