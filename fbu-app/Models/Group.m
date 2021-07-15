//
//  Group.m
//  fbu-app
//
//  Created by mwen on 7/15/21.
//

#import "Group.h"

@implementation Group
@dynamic groupName;
@dynamic groupID;
@dynamic lastSender;
@dynamic lastMessage;

+ (nonnull NSString *)parseClassName {
    return @"Group";
}

-(instancetype)initWithJSONData:(NSDictionary*)data{
    Group *newGroup = [[Group alloc] initWithClassName:@"Group"];
    
    if(newGroup){
        newGroup.groupName =  [data objectForKey:@"name"];
        newGroup.groupID = [data objectForKey:@"group_id"];
        NSDictionary *lastSenderData = [[data objectForKey:@"messages"] objectForKey:@"preview"];
        newGroup.lastSender = [lastSenderData objectForKey:@"nickname"];
        newGroup.lastMessage = [lastSenderData objectForKey:@"text"];

        NSLog(@"%@", newGroup.groupID);
    }
//        self.groupName =  [data objectForKey:@"name"];
//        self.groupDescription = [data objectForKey:@"description"];
//        NSDictionary *lastSenderData = [[data objectForKey:@"messages"] objectForKey:@"preview"];
//        self.lastSender = [lastSenderData objectForKey:@"nickname"];
//        self.lastMessage = [lastSenderData objectForKey:@"text"];
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
    return newGroup;
}


@end
