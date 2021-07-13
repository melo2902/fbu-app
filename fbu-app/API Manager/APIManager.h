//
//  APIManager.h
//  fbu-app
//
//  Created by mwen on 7/13/21.
//

#import <Foundation/Foundation.h>
#import <SafariServices/SafariServices.h>

NS_ASSUME_NONNULL_BEGIN

@interface APIManager : NSObject
+ (void)signInUser;
//+ (BOOL)isLoggedIn;
+ (NSString *)getAuthToken;
+ (NSDictionary *)getUserData;
@end

NS_ASSUME_NONNULL_END
