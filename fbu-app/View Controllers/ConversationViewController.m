//
//  ConversationViewController.m
//  fbu-app
//
//  Created by mwen on 7/15/21.
//

#import "ConversationViewController.h"
#import "APIManager.h"
#import "MessageCell.h"

// Not sure if I actually want scroll
@interface ConversationViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *arrayOfMessages;
@property (assign, nonatomic) BOOL isMoreDataLoading;
@property (assign, nonatomic) BOOL endLoading;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (assign, nonatomic) NSNumber *refreshBegin;
@end

@implementation ConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

// Have it work before add the asethetic
- (void) getMessages {
    NSMutableString *URLString = [[NSMutableString alloc] init];
    [URLString appendString:@"https://api.groupme.com/v3/groups/"];
    [URLString appendString:self.group.groupID];
    [URLString appendString:@"/messages?token="];
    [URLString appendString:[APIManager getAuthToken]];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session  = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:URLString] completionHandler:^(NSData *data, NSURLResponse *response, NSError *requestError) {
        if (requestError != nil) {
            NSLog(@"Trouble requesting page");
        } else {
            // Update flag
            self.isMoreDataLoading = false;
            
            // ... Use the new data to update the data source ...
            [self setupMessages:data];
            
            // Reload the tableView now that there is new data
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
        [self.tableView reloadData];
    }
    
}

//- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
//    if (!self.isMoreDataLoading) {
//        // Calculate the position of one screen length before the bottom of the results
//        int scrollViewContentHeight = self.tableView.contentSize.height;
//        int scrollOffsetThreshold = scrollViewContentHeight - self.tableView.bounds.size.height;
//
//        // When the user has scrolled past the threshold, start requesting
//        if(scrollView.contentOffset.y < 0) {
////        if(scrollView.contentOffset.y < scrollOffsetThreshold && self.tableView.isDragging) {
//            self.isMoreDataLoading = true;
//
//            [self getMessages];
//        }
//
//    }
//}

// null error has to be associated wtih a particlar message
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];
    
    NSString *message = self.arrayOfMessages[indexPath.row];
    NSLog(@"%@", message);
    cell.lastMessageLabel.text = message;
    cell.groupNameLabel.text = [NSString stringWithFormat:@"%@:%li", self.refreshBegin, (long)indexPath.row];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfMessages.count;
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    if(indexPath.row + 1 == [self.arrayOfMessages count]){
//        [self getMessages];
//    }
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
