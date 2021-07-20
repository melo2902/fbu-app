//
//  ConversationViewController.m
//  fbu-app
//
//  Created by mwen on 7/15/21.
//

#import "ConversationViewController.h"
#import "APIManager.h"
#import "MessageCell.h"

@interface ConversationViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *arrayOfMessages;
@property (nonatomic, strong) NSString *latestMessageID;
@property (assign, nonatomic) BOOL isMoreDataLoading;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (assign, nonatomic) NSNumber *refreshBegin;
@end

@implementation ConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.groupNameLabel.text = self.group.lastMessage;
    self.arrayOfMessages = [[NSMutableArray alloc]init];
    self.refreshBegin = @0;

    [self getMessages];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(getMessages) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void) getMessages {
    NSMutableString *URLString = [[NSMutableString alloc] init];
    [URLString appendString:@"https://api.groupme.com/v3/groups/"];
    [URLString appendString:self.group.groupID];
    [URLString appendString:@"/messages?token="];
    [URLString appendString:[APIManager getAuthToken]];
    
    if ([self.latestMessageID length] != 0) {
        [URLString appendString:[NSString stringWithFormat:@"&before_id=%@", self.latestMessageID]];
    }
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session  = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:URLString] completionHandler:^(NSData *data, NSURLResponse *response, NSError *requestError) {
        if (requestError != nil) {
            NSLog(@"Trouble requesting page");
        } else {
            self.isMoreDataLoading = false;
            [self setupMessages:data];
            [self.tableView reloadData];
        }
    }];
    [task resume];
    [self.refreshControl endRefreshing];
}

- (void) setupMessages: (NSData*)data{
    self.refreshBegin = [NSNumber numberWithInt:[self.refreshBegin intValue] + 1];
    
    NSDictionary *arrayFromServer = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSDictionary *responseFromServer = [arrayFromServer objectForKey:@"response"];
    NSDictionary *messageFromServer = [responseFromServer objectForKey:@"messages"];
    
    for(NSDictionary *eachGroup in messageFromServer){
        [self.arrayOfMessages insertObject:eachGroup[@"text"] atIndex:0];
        self.latestMessageID = eachGroup[@"id"];
    
        [self.tableView reloadData];
    }
    
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];
    
    NSString *message = self.arrayOfMessages[indexPath.row];
    
    if ([message isKindOfClass:[NSNull class]]){
        cell.lastMessageLabel.text = @"";
    } else {
        cell.lastMessageLabel.text = message;
    }
    
    cell.groupNameLabel.text = [NSString stringWithFormat:@"%@:%li", self.refreshBegin, (long)indexPath.row];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfMessages.count;
}

@end
