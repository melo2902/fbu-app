//
//  InitialFilterViewController.m
//  fbu-app
//
//  Created by mwen on 7/22/21.
//

#import "InitialFilterViewController.h"
#import "Parse/Parse.h"
#import "SelectionConversationCell.h"
#import "Group.h"
#import "APIManager.h"
#import "Platform.h"
#import "ConversationViewController.h"
#import "Conversation.h"

@interface InitialFilterViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *arrayOfConversations;
@property (assign, nonatomic) BOOL isMoreDataLoading;
@property (assign, nonatomic) BOOL endLoading;
@property (nonatomic, strong) NSMutableArray *pageNumbers;
@property (assign, nonatomic) NSNumber *pageCount;
@end

@implementation InitialFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.pageCount = @1;
    self.arrayOfConversations = [[NSMutableArray alloc]init];
    self.pageNumbers = [[NSMutableArray alloc]init];
    
    [self getConversationsAPI];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    SelectionConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectionConversationCell" forIndexPath:indexPath];
    
    Group *group = self.arrayOfConversations[indexPath.row];
    cell.group = group;
    cell.groupNameLabel.text = group.groupName;
    cell.lastMessageLabel.text = group.lastMessage;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfConversations.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row + 1 == [self.arrayOfConversations count]){
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
            
            // Page stating that we've already pre-filtered out the read texts
            for(NSDictionary *eachGroup in arrayFromServer){
                Group *group = [[Group alloc] initWithJSONData:eachGroup];
                
                if (![group.lastSender isEqual:currPlatform[@"userName"]]) {
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
    Platform *currPlatform = PFUser.currentUser[@"GroupMe"];
    [currPlatform fetchIfNeeded];
    NSMutableArray *conversations = currPlatform[@"onReadConversations"];
    
    for (Group *group in self.arrayOfConversations) {
        if (group.onRead) {
            Conversation *updateConversation = [Conversation updateConversation:group.groupID withTimeStamp: group.lastUpdated withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    NSLog(@"Leave conversation out: %@", group.groupName);
                }
            }];
            
            [conversations addObject: updateConversation];
        } else {
            NSLog(@"This group should be left in: %@", group.groupName);
        }
    }
    
    currPlatform[@"onReadConversations"] = conversations;
    
    [currPlatform saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"onRead Conversations filtered out%@", currPlatform[@"onReadConversations"]);
        }
    }];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
