//
//  Group.m
//  fbu-app
//
//  Created by mwen on 7/16/21.
//

#import "Group.h"

@implementation Group

-(instancetype)initWithJSONData:(NSDictionary*)data{
    self = [super init];
    
    if(self){
        self.groupName =  [data objectForKey:@"name"];
        self.groupID = [data objectForKey:@"group_id"];
        NSDictionary *lastSenderData = [[data objectForKey:@"messages"] objectForKey:@"preview"];
        self.lastSender = [lastSenderData objectForKey:@"nickname"];
        
        if ([lastSenderData objectForKey:@"text"] != [NSNull null]) {
            self.lastMessage = [lastSenderData objectForKey:@"text"];
        } else {
            self.lastMessage = @"";
        }
        
//        NSLog(@"data%@", [data objectForKey:@"updated_at"]);
        self.lastUpdated = [data objectForKey:@"updated_at"];
    }
//        self.groupDescription = [data objectForKey:@"description"];
//        self.members = [data objectForKey:@"members"];
//        self.groupLastUpdated = [data objectForKey:@"updated_at"];
//        if ([data objectForKey:@"image_url"] != [NSNull null]){
//            self.groupImageURL = [NSURL URLWithString:[data objectForKey:@"image_url"]];
//            NSData *groupImageData = [NSData dataWithContentsOfURL:self.groupImageURL];
//            self.groupImage = [UIImage imageWithData:groupImageData];
//        } else {
//            NSMutableString * firstCharacters = [NSMutableString string];
//            NSArray * words = [self.groupName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//            for (NSString * word in words) {
//                if ([word length] > 0) {
//                    NSString * firstLetter = [word substringToIndex:1];
//                    [firstCharacters appendString:[firstLetter uppercaseString]];
//                }
//            }
//            self.groupImageURL = nil;
//            self.groupImage = [[JSQMessagesAvatarImageFactory avatarImageWithUserInitials:firstCharacters backgroundColor:[UIColor groupMeLightBlue] textColor:[UIColor groupMeGray] font:[UIFont systemFontOfSize:18] diameter:50] avatarImage];
//        }
//
//    }
    return self;
}

@end
