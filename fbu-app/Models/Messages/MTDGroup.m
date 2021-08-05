//
//  MTDGroup.m
//  fbu-app
//
//  Created by mwen on 7/16/21.
//

#import "MTDGroup.h"

@implementation MTDGroup

-(instancetype)initWithJSONData:(NSDictionary*)data{
    self = [super init];
    
    if(self){
        self.groupName =  [data objectForKey:@"name"];
        self.groupID = [data objectForKey:@"group_id"];
        NSDictionary *lastSenderData = [[data objectForKey:@"messages"] objectForKey:@"preview"];
        self.lastSender = [lastSenderData objectForKey:@"nickname"];
        self.lastUpdated = [data objectForKey:@"updated_at"];
        self.members = [data objectForKey:@"members"];
        
        if ([lastSenderData objectForKey:@"text"] != [NSNull null]) {
            self.lastMessage = [lastSenderData objectForKey:@"text"];
        } else {
            self.lastMessage = @"Sent a photo";
        }
        
        self.onRead = YES;
    }
    
    return self;
}

@end
