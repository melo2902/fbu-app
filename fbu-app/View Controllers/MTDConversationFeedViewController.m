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
#import "MaterialActivityIndicator.h"
#import "MTDUser.h"
#import "CompletedListView.h"

@interface MTDConversationFeedViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, MTDMessagesViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *allMessagesArray;
@property (nonatomic, strong) NSMutableArray *tempMessagesArray;
@property (nonatomic, strong) NSMutableArray *tempCompletedMessages;
@property (nonatomic, strong) NSMutableArray *arrayOfMessages;
@property (nonatomic, strong) NSMutableArray *arrayOfCompletedMessages;
@property (assign, nonatomic) BOOL isMoreDataLoading;
@property (assign, nonatomic) BOOL endLoading;
@property (nonatomic, strong) NSMutableArray *pageNumbers;
@property (assign, nonatomic) NSNumber *pageCount;
@property(nonatomic) MDCActivityIndicator *activityIndicator;
@end

@implementation MTDConversationFeedViewController {
    UILabel *addBackgroundLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont fontWithName:@"Avenir Book" size:17], NSFontAttributeName, nil];
    
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.pageCount = @1;
    
    addBackgroundLabel = [UILabel new];
    
    self.arrayOfMessages = [[NSMutableArray alloc]init];
    self.arrayOfCompletedMessages = [[NSMutableArray alloc]init];
    
    self.pageNumbers = [[NSMutableArray alloc]init];
    
    self.activityIndicator = [[MDCActivityIndicator alloc] init];
    [self.activityIndicator sizeToFit];
    [self.tableView addSubview:self.activityIndicator];
    self.activityIndicator.center = self.view.center;
    
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"TableViewHeaderView"];
    [self.tableView registerNib:[UINib nibWithNibName:@"CompletedListView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"CompletedListView"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
           selector:@selector(updateConversationFilters:)
           name:@"updatedConversationFeed"
           object:nil];
    
    if ([MTDAPIManager returnAuthToken]) {
        [self getConversationsAPI];
    } else {
        [self checkForBackgroundText];
        NSLog(@"User has not logged into their linked account yet");
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MTDConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConversationCell" forIndexPath:indexPath];
    
    NSArray *groupsInSection = [self.allMessagesArray[indexPath.section] lastObject];
    MTDGroup *group = groupsInSection[indexPath.row];
    
    cell.group = group;
    cell.groupNameLabel.text = group.groupName;
    
    cell.lastMessageLabel.numberOfLines = 2;
    if (![group.lastSender isEqual: [NSNull null]]) {
        cell.lastMessageLabel.attributedText = [self modifyMessage:group.lastMessage withSender: group.lastSender];
    } else {
        cell.lastMessageLabel.text = group.lastMessage;
    }
    
    if (!cell.group.onRead){
        [cell.statusButton setSelected:NO];
    } else {
        [cell.statusButton setSelected:YES];
    }
    
    double unixTimeStamp =[group.lastUpdated doubleValue];
    NSTimeInterval _interval=unixTimeStamp;
    NSDate *dateString = [NSDate dateWithTimeIntervalSince1970:_interval];
    cell.dataAgoLabel.text = dateString.shortTimeAgoSinceNow;

    __weak MTDConversationCell *weakCell = cell;
    weakCell.completionButtonTapHandler = ^{
        if (group.onRead) {
            [self.arrayOfMessages removeObject:group];
            [self.arrayOfCompletedMessages insertObject:group atIndex:0];
        } else {
            [self.arrayOfMessages addObject:group];
            [self.arrayOfCompletedMessages removeObject:group];
        }
        
        [self.tableView reloadData];
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        if ([[self.allMessagesArray[1] lastObject] count] == 0) {
            return nil;
        }
        
        CompletedListView *header = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"CompletedListView"];

        NSUInteger completedTasks = [[self.allMessagesArray[0] lastObject] count];
        header.completedLabel.text = [NSString stringWithFormat:@"TO REPLY - %lu", completedTasks];
        header.completedLabel.font =  [UIFont fontWithName:@"Avenir Book" size:14];
        
        return header;
        
    } else if (section == 1) {
        if ([[self.allMessagesArray[1] lastObject] count] == 0) {
            return nil;
        }
        
        CompletedListView *header = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"CompletedListView"];

        NSUInteger completedTasks = [[self.allMessagesArray[1] lastObject] count];
        header.completedLabel.text = [NSString stringWithFormat:@"COMPLETED - %lu", completedTasks];
        header.completedLabel.font =  [UIFont fontWithName:@"Avenir Book" size:14];
        
        return header;
    } else {
        UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"TableViewHeaderView"];
        
        header.textLabel.text = [self.allMessagesArray[section] firstObject];
        return header;
    }
}

- (void) checkForBackgroundText {
    addBackgroundLabel.text = @"No Platforms Connected";
    addBackgroundLabel.font = [UIFont fontWithName:@"Avenir Light" size:16];
    addBackgroundLabel.textColor = [UIColor systemGrayColor];
    addBackgroundLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:addBackgroundLabel];
    [self.view bringSubviewToFront:addBackgroundLabel];
}

- (void) removeBackgroundText {
    addBackgroundLabel.text = @"";
    [self.view addSubview:addBackgroundLabel];
    [self.view bringSubviewToFront:addBackgroundLabel];
}

- (void)viewWillLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    addBackgroundLabel.frame = CGRectMake(0, self.view.frame.size.height / 2, self.view.frame.size.width, 20);
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
        [self.activityIndicator startAnimating];
        [self.pageNumbers addObject:self.pageCount];
        
        self.tempMessagesArray = [[NSMutableArray alloc] init];
        self.tempCompletedMessages = [[NSMutableArray alloc] init];
        [self.tempMessagesArray addObject:@"TO REPLY"];
        [self.tempCompletedMessages addObject:@"COMPLETED"];
        
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
            MTDUser *user = [MTDUser currentUser];
            
            MTDPlatform *currPlatform = user.GroupMe;
            [currPlatform fetchIfNeeded];
            NSMutableArray *savedConversations = currPlatform.onReadConversations;
            NSMutableDictionary *onReadDictionary = [[NSMutableDictionary alloc] init];
            
            for (MTDConversation *conversationItem in savedConversations) {
                [conversationItem fetchIfNeeded];
                
                onReadDictionary[conversationItem.conversationID] = conversationItem.latestTimeStamp;
            }
            
            for(NSDictionary *eachGroup in arrayFromServer){
                MTDGroup *group = [[MTDGroup alloc] initWithJSONData:eachGroup];
                
                if (![group.lastSender isEqual:currPlatform.username]) {
                    // Don't want to list any to-do items that has the user as the last sent
                    if ([onReadDictionary objectForKey:group.groupID]) {
                        if (group.lastUpdated > onReadDictionary[group.groupID]) {
                            [onReadDictionary removeObjectForKey:group.groupID];
                            group.onRead = NO;
                            [self.arrayOfMessages addObject:group];
                        } else {
                            group.onRead = YES;
                            [self.arrayOfCompletedMessages addObject:group];
                        }
                    } else {
                        group.onRead = NO;
                        [self.arrayOfMessages addObject:group];
                    }
                } else {
                    group.onRead = YES;
                    [self.arrayOfCompletedMessages addObject:group];
                }
            }

            NSMutableArray* newSavedConversations = [[NSMutableArray alloc] init];
            for (MTDConversation *conversationItem in savedConversations) {
                if ([onReadDictionary objectForKey:conversationItem.conversationID]) {
                    [newSavedConversations addObject:conversationItem];
                }
            }
            
            currPlatform.onReadConversations = savedConversations;
            [currPlatform saveInBackground];
            
            self.allMessagesArray = [[NSMutableArray alloc] init];
            [self.tempMessagesArray addObject: self.arrayOfMessages];
            [self.allMessagesArray addObject:self.tempMessagesArray];
            
            [self.tempCompletedMessages addObject: self.arrayOfCompletedMessages];
            [self.allMessagesArray addObject:self.tempCompletedMessages];
            
            [self.activityIndicator stopAnimating];
            [self.tableView reloadData];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.allMessagesArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.allMessagesArray[section] lastObject] count];
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
    
    if (indexPath.section == 0) {
        NSArray *groupsInSection = [self.allMessagesArray[indexPath.section] lastObject];
        MTDGroup *group = groupsInSection[indexPath.row];
        
        UIContextualAction *notif = [self createNotification: group inStringTime:@"3600s" inSeconds:3600];
        
        UISwipeActionsConfiguration *SwipeActions = [UISwipeActionsConfiguration configurationWithActions:@[notif]];
        SwipeActions.performsFirstActionWithFullSwipe=false;
        return SwipeActions;
    }
    
    return nil;
}

- (UIContextualAction*) createNotification:(MTDGroup *) group inStringTime: (NSString *) time inSeconds: (NSTimeInterval) seconds {
    
    UIContextualAction *notification = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:time handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        UNMutableNotificationContent *content = [UNMutableNotificationContent new];
        content.body = [NSString stringWithFormat:@"Remember to reply to %@'s message in %@!", group.lastSender, group.groupName];
        content.sound = [UNNotificationSound defaultSound];
        
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger
                                                      triggerWithTimeInterval:seconds repeats:NO];
        
        NSString *identifier = [NSString stringWithFormat:@"%@: %@", group.groupID, time];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier
                                                                              content:content trigger:trigger];
        
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Unable to set notification, error: %@",error);
            }
        }];
        
        completionHandler(YES);
    }];
    
    notification.image = [UIImage systemImageNamed:@"bell.badge"];
    notification.backgroundColor = [UIColor systemBlueColor];
    
    return notification;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88;
}

-(NSMutableAttributedString *)modifyMessage:(NSString *)message withSender:(NSString *)sender {
    NSUInteger usernameLength = [sender length];
    
    NSMutableAttributedString *lastMessage = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: %@", sender, message]];
    NSRange selectedRange = NSMakeRange(0, usernameLength + 1);
    
    [lastMessage beginEditing];
    
    [lastMessage addAttribute:NSFontAttributeName
                        value:[UIFont fontWithName:@"Avenir Book" size:14.0]
                        range:selectedRange];
    
    [lastMessage endEditing];
    
    return lastMessage;
    
}

- (NSAttributedString *) strikeOutText: (NSString *) text {
    NSDictionary* attributes = @{
      NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]
    };

    NSAttributedString* attrText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    return attrText;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) reloadViews {
    self.pageCount = @1;
    self.endLoading = NO;
    
    self.allMessagesArray = [[NSMutableArray alloc] init];
    self.arrayOfMessages = [[NSMutableArray alloc]init];
    self.arrayOfCompletedMessages = [[NSMutableArray alloc]init];
    
    self.activityIndicator = [[MDCActivityIndicator alloc] init];
    [self.activityIndicator sizeToFit];
    [self.tableView addSubview:self.activityIndicator];
    self.activityIndicator.center = self.view.center;
    
    self.pageNumbers = [[NSMutableArray alloc]init];
    
    if ([MTDAPIManager returnAuthToken]) {
        [self getConversationsAPI];
    } else {
        [self checkForBackgroundText];
        NSLog(@"User has not logged into their linked account yet");
    }
}

- (void)MTDConversationFeedViewController:(nonnull MTDMessagesViewController *)controller {
    [self reloadViews];
}

- (void) updateConversationFilters:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"updatedConversationFeed"]) {
        [self removeBackgroundText];
        [self reloadViews];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"showDetailSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

        NSArray *groupsInSection = [self.allMessagesArray[indexPath.section] lastObject];
        MTDGroup *group = groupsInSection[indexPath.row];
        
        UINavigationController *navigationController = [segue destinationViewController];
        MTDMessagesViewController *messagesViewController = (MTDMessagesViewController *)[navigationController topViewController];
        messagesViewController.group = group;
        messagesViewController.delegate = self;
    }
}

@end
