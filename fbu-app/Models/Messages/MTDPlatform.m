//
//  MTDPlatform.m
//  fbu-app
//
//  Created by mwen on 7/16/21.
//

#import "MTDPlatform.h"

@implementation MTDPlatform
@dynamic user;
@dynamic userID;
@dynamic platformName;
@dynamic username;
@dynamic onReadConversations;

+ (nonnull NSString *)parseClassName {
    return @"Platform";
}

-(instancetype)initWithJSONData:(NSDictionary*)data onPlatform: (NSString*) platform{

    MTDPlatform *newPlatform = [[MTDPlatform alloc] initWithClassName:@"Platform"];
    
    if (newPlatform) {
        newPlatform.platformName = platform;
        
        NSDictionary *response = [data objectForKey:@"response"];
        newPlatform.username = [response objectForKey:@"name"];
        newPlatform.userID = [response objectForKey:@"id"];
        newPlatform.onReadConversations = [[NSMutableArray alloc]init];
    }
    
    [newPlatform saveInBackground];
    
    return newPlatform;
}

@end
