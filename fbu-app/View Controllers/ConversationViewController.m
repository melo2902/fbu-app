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
@property (assign, nonatomic) BOOL isMoreDataLoading;
@property (assign, nonatomic) BOOL endLoading;
@property (assign, nonatomic) NSNumber *pageCount;
@end

@implementation ConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.groupNameLabel.text = self.group.lastMessage;
    self.arrayOfMessages = [[NSMutableArray alloc]init];
    
    [self getMessages];
}

// Have it work before add the asethetic
- (void) getMessages {
    NSMutableString *URLString = [[NSMutableString alloc] init];
    [URLString appendString:@"https://api.groupme.com/v3/groups/"];
    [URLString appendString:self.group.groupID];
    [URLString appendString:@"/messages?token="];
    [URLString appendString:[APIManager getAuthToken]];
//    [URLString appendString:[NSString stringWithFormat:@"&page=%@", @1]];
    //        [URLString appendString:[NSString stringWithFormat:@"&page=%@", self.pageCount]];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session  = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:URLString] completionHandler:^(NSData *data, NSURLResponse *response, NSError *requestError) {
        if (requestError != nil) {
            NSLog(@"Trouble requesting page");
        } else {
            // Update flag
            self.isMoreDataLoading = false;
            
            // ... Use the new data to update the data source ...
//            [self setupGroupsFromJSONArray:data];
            [self setupMessages:data];
            
//            NSLog(@"Convesationarray%@", messageFromServer);
//            self.arrayOfMessages = arrayFromServer;
            
            self.pageCount = [NSNumber numberWithInt:[self.pageCount intValue] + 1];
            
            // Reload the tableView now that there is new data
            [self.tableView reloadData];
        }
    }];
    [task resume];
}

- (void) setupMessages: (NSData*)data{
    NSDictionary *arrayFromServer = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSDictionary *responseFromServer = [arrayFromServer objectForKey:@"response"];
    NSDictionary *messageFromServer = [responseFromServer objectForKey:@"messages"];
    
    for(NSDictionary *eachGroup in messageFromServer){
//        Group *group = [[Group alloc] initWithJSONData:eachGroup];
        [self.arrayOfMessages addObject:eachGroup[@"text"]];
        NSLog(@"self.arrayOfMessages%@", self.arrayOfMessages);
        [self.tableView reloadData];
    }
    
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    if (!self.isMoreDataLoading) {
        // Calculate the position of one screen length before the bottom of the results
        int scrollViewContentHeight = self.tableView.contentSize.height;
        int scrollOffsetThreshold = scrollViewContentHeight - self.tableView.bounds.size.height;
        
        // When the user has scrolled past the threshold, start requesting
        if(scrollView.contentOffset.y < scrollOffsetThreshold && self.tableView.isDragging) {
            self.isMoreDataLoading = true;
            
            [self getMessages];
        }
        
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];
    
//    Group *group = self.arrayOfMessages[indexPath.row];
    //    cell.group = group;
//    cell.groupNameLabel.text = group.groupName;
//    cell.lastMessageLabel.text = group.lastMessage;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfMessages.count;
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
