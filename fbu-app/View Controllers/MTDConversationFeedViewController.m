//
//  MTDConversationFeedViewController.m
//  fbu-app
//
//  Created by mwen on 7/15/21.
//

#import "MTDConversationFeedViewController.h"
#import <UserNotifications/UserNotifications.h>
#import "Parse/Parse.h"
#import "MTDConversationCell.h"
#import "MTDGroup.h"
#import "MTDAPIManager.h"
#import "MTDPlatform.h"
#import "MTDConversation.h"
#import "DateTools.h"
#import "MTDMessagesViewController.h"

@interface MTDConversationFeedViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *arrayOfMessages;
@property (assign, nonatomic) BOOL isMoreDataLoading;
@property (assign, nonatomic) BOOL endLoading;
@property (nonatomic, strong) NSMutableArray *pageNumbers;
@property (assign, nonatomic) NSNumber *pageCount;
@end

@implementation MTDConversationFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([MTDAPIManager returnAuthToken]) {
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        
        self.pageCount = @1;
        self.arrayOfMessages = [[NSMutableArray alloc]init];
        self.pageNumbers = [[NSMutableArray alloc]init];
        
        [self getConversationsAPI];
    } else {
        NSLog(@"User has not logged into their linked account yet");
    }
    
    CGRect frame = CGRectZero;
    frame.size.height = CGFLOAT_MIN;
    [self.tableView setTableHeaderView:[[UIView alloc] initWithFrame:frame]];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MTDConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConversationCell" forIndexPath:indexPath];
    
    MTDGroup *group = self.arrayOfMessages[indexPath.row];
    cell.group = group;
    cell.groupNameLabel.text = group.groupName;
    
    cell.lastMessageLabel.numberOfLines = 2;
    if (![group.lastSender isEqual: [NSNull null]]) {
        cell.lastMessageLabel.attributedText = [self modifyMessage:group.lastMessage withSender: group.lastSender];
    } else {
        cell.lastMessageLabel.text = group.lastMessage;
    }
    
    double unixTimeStamp =[group.lastUpdated doubleValue];
    NSTimeInterval _interval=unixTimeStamp;
    NSDate *dateString = [NSDate dateWithTimeIntervalSince1970:_interval];
    cell.dataAgoLabel.text = dateString.shortTimeAgoSinceNow;
    
    cell.completionButtonTapHandler = ^{
        [self.arrayOfMessages removeObject:group];
        [self.tableView reloadData];
    };
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfMessages.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row + 1 == [self.arrayOfMessages count]){
        if (!self.endLoading){
            [self getConversationsAPI];
        } else {
            NSLog(@"Stop loading conversations");
        }
    }
}

-(void) getConversationsAPI {
    if (!self.endLoading && ![self.pageNumbers containsObject:self.pageCount])  {
        
        [self.pageNumbers addObject:self.pageCount];
        
        NSMutableString *URLString = [[NSMutableString alloc] init];
        [URLString appendString:@"https://api.groupme.com/v3/groups?limit=6&token="];
        [URLString appendString:[MTDAPIManager returnAuthToken]];
        [URLString appendString:[NSString stringWithFormat:@"&page=%@", self.pageCount]];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        NSURLSession *session  = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
        
        NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:URLString] completionHandler:^(NSData *data, NSURLResponse *response, NSError *requestError) {
            if (requestError != nil) {
                NSLog(@"Trouble requesting page");
            } else {
                
                self.isMoreDataLoading = false;
                [self setupGroupsFromJSONArray:data];
                self.pageCount = [NSNumber numberWithInt:[self.pageCount intValue] + 1];
            }
        }];
        [task resume];
    } else {
        NSLog(@"All conversations already loaded");
    }
}

-(void)setupGroupsFromJSONArray:(NSData*)dataFromServerArray{
    NSError *error;
    NSDictionary *arrayFromServer = [NSJSONSerialization JSONObjectWithData:dataFromServerArray options:0 error:nil];
    arrayFromServer = [arrayFromServer objectForKey:@"response"];
    
    NSInteger numOfNewGroups = [arrayFromServer count];
    NSInteger empty = 0;
    NSInteger aboutToBeEmpty = 10;
    
    if (numOfNewGroups == empty) {
        self.endLoading = YES;
    } else {
        if (numOfNewGroups < aboutToBeEmpty) {
            self.endLoading = YES;
        }
        
        if (error){
            NSLog(@"error parsing the json data from server with error description - %@", [error localizedDescription]);
        } else {
            MTDPlatform *currPlatform = PFUser.currentUser[@"GroupMe"];
            [currPlatform fetchIfNeeded];
            NSMutableArray *savedConversations = currPlatform[@"onReadConversations"];
            NSMutableDictionary *onReadDictionary = [[NSMutableDictionary alloc] init];
            
            for (MTDConversation *conversationItem in savedConversations) {
                [conversationItem fetchIfNeeded];
                
                onReadDictionary[conversationItem[@"conversationID"]] = conversationItem[@"latestTimeStamp"];
            }
            
            for(NSDictionary *eachGroup in arrayFromServer){
                MTDGroup *group = [[MTDGroup alloc] initWithJSONData:eachGroup];
                
                if (![group.lastSender isEqual:currPlatform[@"username"]]) {
                    // Don't want to list any to-do items that has the user as the last sent
                    if ([onReadDictionary objectForKey:group.groupID]) {
                        if (group.lastUpdated > onReadDictionary[group.groupID]) {
                            [onReadDictionary removeObjectForKey:group.groupID];
                            [self.arrayOfMessages addObject:group];
                        }
                    } else {
                        [self.arrayOfMessages addObject:group];
                    }
                }
            }

            NSMutableArray* newSavedConversations = [[NSMutableArray alloc] init];
            for (MTDConversation *conversationItem in savedConversations) {
                if ([onReadDictionary objectForKey:conversationItem[@"conversationID"]]) {
                    [newSavedConversations addObject:conversationItem];
                }
            }
            
            currPlatform[@"onReadConversations"] = savedConversations;
            [currPlatform saveInBackground];
            
            [self.tableView reloadData];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.isMoreDataLoading) {
        int scrollViewContentHeight = self.tableView.contentSize.height;
        int scrollOffsetThreshold = scrollViewContentHeight - self.tableView.bounds.size.height;
        
        if(scrollView.contentOffset.y > scrollOffsetThreshold && self.tableView.isDragging) {
            self.isMoreDataLoading = true;
            
            [self getConversationsAPI];
        }
        
    }
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MTDGroup *group = self.arrayOfMessages[indexPath.row];
    
    //    Need to change the identifiers later later
    UIContextualAction *notif1 = [self createNotification:(NSString *) @"30 second notification" inStringTime:@"30s" inSeconds:30 withIdentifier: @"groupID"];
    
    UIContextualAction *notif2 = [self createNotification:(NSString *) @"60 second notification" inStringTime:@"60s" inSeconds:60 withIdentifier: @"groupID"];
    
    UIContextualAction *notif3 = [self createNotification:(NSString *) @"90 second notification" inStringTime:@"90s" inSeconds:90 withIdentifier: @"groupID"];
    
    UISwipeActionsConfiguration *SwipeActions = [UISwipeActionsConfiguration configurationWithActions:@[notif1,notif2, notif3]];
    SwipeActions.performsFirstActionWithFullSwipe=false;
    return SwipeActions;
}

- (UIContextualAction*) createNotification:(NSString *) respondant inStringTime: (NSString *) time inSeconds: (NSTimeInterval) seconds withIdentifier: (NSString *) message {
    
    UIContextualAction *notification = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:time handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        UNMutableNotificationContent *content = [UNMutableNotificationContent new];
        content.body = [NSString stringWithFormat:@"Reply to %@'s message!", respondant];
        content.sound = [UNNotificationSound defaultSound];
        
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger
                                                      triggerWithTimeInterval:seconds repeats:NO];
        
        NSString *identifier = [NSString stringWithFormat:@"%@:%@", respondant, message];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier
                                                                              content:content trigger:trigger];
        
        // Add a custom action later though will have to use delegate
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Unable to set notification, error: %@",error);
            }
        }];
        
        completionHandler(YES);
    }];
    
    // Need to add a different color
    notification.backgroundColor = [UIColor colorWithRed:(245/255.0) green:(78/255.0) blue:(70/255.0) alpha:1];
    
    return notification;
    
}

-(NSMutableAttributedString *)modifyMessage:(NSString *)message withSender:(NSString *)sender {
    NSUInteger usernameLength = [sender length];
    
    NSMutableAttributedString *lastMessage = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: %@", sender, message]];
    NSRange selectedRange = NSMakeRange(0, usernameLength + 1);
    
    [lastMessage beginEditing];
    
    [lastMessage addAttribute:NSFontAttributeName
                        value:[UIFont fontWithName:@"Helvetica-Bold" size:17.0]
                        range:selectedRange];
    
    [lastMessage endEditing];
    
    return lastMessage;
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"showDetailSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

        MTDGroup *group = self.arrayOfMessages[indexPath.row];
        UINavigationController *navigationController = [segue destinationViewController];
        MTDMessagesViewController *messagesViewController = (MTDMessagesViewController *)[navigationController topViewController];
        messagesViewController.group = group;
    }
}

@end
