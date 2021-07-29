//
//  MTDAPIManager.h
//  fbu-app
//
//  Created by mwen on 7/13/21.
//

#import <Foundation/Foundation.h>
#import <SafariServices/SafariServices.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTDAPIManager : NSObject
+ (void)setAuthToken: (NSString *) authToken;
+ (NSString *)returnAuthToken;
+ (void) sendTextMessage: (NSString *) text inGroup: (NSString *) groupID;
@end

NS_ASSUME_NONNULL_END
