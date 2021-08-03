//
//  MTDAPIManager.m
//  fbu-app
//
//  Created by mwen on 7/13/21.
//

#import "MTDAPIManager.h"
#import "Parse/Parse.h"
#import "MTDUser.h"

@implementation MTDAPIManager
#pragma mark - Auth

+ (void) setAuthToken: (NSString *) givenAuthToken {
    MTDUser *user = [MTDUser currentUser];
    
    user.authToken = givenAuthToken;
    [user saveInBackground];
}

+ (NSString *)returnAuthToken {
    MTDUser *user = [MTDUser currentUser];
    
    if (user.authToken) {
        return user.authToken;
    }
    
    return nil;
}

+ (void) sendTextMessage: (NSString *) text inGroup: (NSString *) groupID {
    NSMutableString *URLString = [[NSMutableString alloc] init];
    [URLString appendString:[NSString stringWithFormat:@"https://api.groupme.com/v3/groups/%@/messages", groupID]];
    
    NSURL *URLRequest = [NSURL URLWithString:URLString];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URLRequest];
    
    NSDictionary *params =  @{@"message": @{
                                      @"source_guid":[[NSUUID UUID] UUIDString],
                                      @"text":text,
                                      @"attachments":@[]}
    };
    
    NSError *err = nil;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&err];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    MTDUser *user = [MTDUser currentUser];
    [request setValue:user.authToken forHTTPHeaderField:@"X-Access-Token"];
    [request setHTTPBody:requestData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error:%@", error);
        } else {
            NSLog(@"The response is %@",response);
        }
    }];
    [dataTask resume];
}

@end
