//
//  APIManager.m
//  fbu-app
//
//  Created by mwen on 7/13/21.
//

#import "APIManager.h"

@implementation APIManager
#pragma mark - Auth

+ (NSString *)getAuthToken {
    return @"KPap1zhC20J3k7gL2baYtAF1p4SelSZRAYfgNBVK";
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
    [request setValue:[self getAuthToken] forHTTPHeaderField:@"X-Access-Token"];
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
