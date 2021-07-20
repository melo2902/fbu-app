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

    Platform *newPlatform = [[Platform alloc] initWithClassName:@"Platform"];
    
    if (newPlatform) {
        newPlatform.platformName = platform;
        
        NSDictionary *response = [data objectForKey:@"response"];
        newPlatform.userName = [response objectForKey:@"name"];
        newPlatform.onReadConversations = [[NSMutableArray alloc]init];
    }
    
    [newPlatform saveInBackground];
    
    return newPlatform;
}

@end
