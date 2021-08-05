//
//  MTDInitialFilterViewController.m
//  fbu-app
//
//  Created by mwen on 7/22/21.
//

#import "MTDInitialFilterViewController.h"
#import "Parse/Parse.h"
#import "MTDSelectionConversationCell.h"
#import "MTDMessagesViewController.h"
#import "MTDGroup.h"
#import "MTDAPIManager.h"
#import "MTDPlatform.h"
#import "MTDConversation.h"
#import "MTDUser.h"

@interface MTDInitialFilterViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *arrayOfConversations;
@property (assign, nonatomic) BOOL isMoreDataLoading;
@property (assign, nonatomic) BOOL endLoading;
@property (nonatomic, strong) NSMutableArray *pageNumbers;
@property (assign, nonatomic) NSNumber *pageCount;
@end

@implementation MTDInitialFilterViewController
@synthesize rowDescriptor = _rowDescriptor;

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.pageCount = @1;
    self.arrayOfConversations = [[NSMutableArray alloc]init];
    self.pageNumbers = [[NSMutableArray alloc]init];
    [self.filterConversationButton setEnabled:NO];
    [self.filterConversationButton setTintColor: [UIColor clearColor]];
    
    [self getConversationsAPI];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MTDSelectionConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectionConversationCell" forIndexPath:indexPath];
    
    MTDGroup *group = self.arrayOfConversations[indexPath.row];
    cell.group = group;
    cell.groupNameLabel.text = group.groupName;
    [cell.selectConversationButton setSelected: !group.onRead];
    
    if (![group.lastSender isEqual: [NSNull null]]) {
        cell.lastMessageLabel.attributedText = [self modifyMessage:group.lastMessage withSender: group.lastSender];
    } else {
        cell.lastMessageLabel.text = group.lastMessage;
    }
    return cell;
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

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfConversations.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row + 1 == [self.arrayOfConversations count]){
        if (!self.endLoading){
            [self getConversationsAPI];
        } else {
            [self.filterConversationButton setEnabled:YES];
            [self.filterConversationButton setTintColor: nil];
            
            NSLog(@"Stop loading conversations");
        }
    }
}

-(void) getConversationsAPI {
    if (!self.endLoading && ![self.pageNumbers containsObject:self.pageCount])  {
        
        [self.pageNumbers addObject:self.pageCount];
        
        NSMutableString *URLString = [[NSMutableString alloc] init];
        [URLString appendString:@"https://api.groupme.com/v3/groups?token="];
        MTDUser *user = [MTDUser currentUser];
        [URLString appendString:user.authToken];
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
        
        if(error){
            NSLog(@"error parsing the json data from server with error description - %@", [error localizedDescription]);
        } else {
            MTDUser *user = [MTDUser currentUser];
            MTDPlatform *currPlatform = user.GroupMe;
            [currPlatform fetchIfNeeded];
            
            // Page stating that we've already pre-filtered out the read texts
            for(NSDictionary *eachGroup in arrayFromServer){
                MTDGroup *group = [[MTDGroup alloc] initWithJSONData:eachGroup];
                
                if (![group.lastSender isEqual:currPlatform.username]) {
                    [self.arrayOfConversations addObject:group];
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
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

- (IBAction)onSelectConversations:(id)sender {
    MTDUser *user = [MTDUser currentUser];
    MTDPlatform *currPlatform = user.GroupMe;
    [currPlatform fetchIfNeeded];
    NSMutableArray *conversations = currPlatform.onReadConversations;
    
    for (MTDGroup *group in self.arrayOfConversations) {
        if (group.onRead) {
            MTDConversation *updateConversation = [MTDConversation updateConversation:group.groupID withTimeStamp: group.lastUpdated withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    NSLog(@"Leave conversation out: %@", group.groupName);
                }
            }];
            
            [conversations addObject: updateConversation];
        } else {
            NSLog(@"This group should be left in: %@", group.groupName);
        }
    }
    
    currPlatform.onReadConversations = conversations;
    
    [currPlatform saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"onRead Conversations filtered out%@", currPlatform.onReadConversations);
            
            [self dismissViewControllerAnimated:YES completion:^{
                NSLog(@"Dismiss View Controller");
            }];
        }
    }];
}

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if ([segue.identifier isEqual:@"filterConversationDetailSegue"]) {
         NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

         MTDGroup *group = self.arrayOfConversations[indexPath.row];
         UINavigationController *navigationController = [segue destinationViewController];
         MTDMessagesViewController *messagesViewController = (MTDMessagesViewController *)[navigationController topViewController];
         messagesViewController.group = group;
     }
 }


@end
