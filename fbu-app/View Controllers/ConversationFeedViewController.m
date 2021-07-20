//
//  ConversationFeedViewController.m
//  fbu-app
//
//  Created by mwen on 7/15/21.
//

#import "ConversationFeedViewController.h"
#import "Parse/Parse.h"
#import "ConversationCell.h"
#import "Group.h"
#import "APIManager.h"
#import "Platform.h"
#import "ConversationViewController.h"

@interface ConversationFeedViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *arrayOfMessages;
@property (assign, nonatomic) BOOL isMoreDataLoading;
@property (assign, nonatomic) BOOL endLoading;
@property (nonatomic, strong) NSMutableArray *pageNumbers;
@property (assign, nonatomic) NSNumber *pageCount;
@end

@implementation ConversationFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.pageCount = @1;
    self.arrayOfMessages = [[NSMutableArray alloc]init];
    self.pageNumbers = [[NSMutableArray alloc]init];
    
    [self getConversationsAPI];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConversationCell" forIndexPath:indexPath];
    
    Group *group = self.arrayOfMessages[indexPath.row];
    cell.group = group;
    cell.groupNameLabel.text = group.groupName;
    cell.lastMessageLabel.text = group.lastMessage;
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
        [URLString appendString:@"https://api.groupme.com/v3/groups?token="];
        [URLString appendString:[APIManager getAuthToken]];
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
            Platform *currPlatform = PFUser.currentUser[@"GroupMe"];
            [currPlatform fetchIfNeeded];
            
            for(NSDictionary *eachGroup in arrayFromServer){
                Group *group = [[Group alloc] initWithJSONData:eachGroup];
                if (![group.lastSender isEqual:currPlatform[@"userName"]]) {
                    [self.arrayOfMessages addObject:group];
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"showConversationSegue"]) {
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        Group *group = self.arrayOfMessages[indexPath.row];
        
        ConversationViewController *conversationViewController = [segue destinationViewController];
        conversationViewController.group = group;
    }
}

@end
