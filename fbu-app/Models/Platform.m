//
//  Platform.m
//  fbu-app
//
//  Created by mwen on 7/16/21.
//

#import "Platform.h"

@implementation Platform
@dynamic user;
@dynamic platformName;
@dynamic userName;
@dynamic onReadConversations;

+ (nonnull NSString *)parseClassName {
    return @"Platform";
}

-(instancetype)initWithJSONData:(NSDictionary*)data onPlatform: (NSString*) platform{
    
//+ (void) createPlatform: ( NSString *)platformName fromUser: (NSString *) userName withCompletion: (PFBooleanResultBlock  _Nullable) completion {
    Platform *newPlatform = [[Platform alloc] initWithClassName:@"Platform"];
    
    if (newPlatform) {
//        newPlatform.user = PFUser.currentUser;
        newPlatform.platformName = platform;
        newPlatform.userName = [data objectForKey:@"name"];
        newPlatform.onReadConversations = [[NSDictionary alloc]init];
    }
    
    [newPlatform saveInBackground];
    
    return newPlatform;
}

@end
