//
//  ConversationFeedViewController.m
//  fbu-app
//
//  Created by mwen on 7/15/21.
//

#import "ConversationFeedViewController.h"
#import "Parse/Parse.h"
#import "MessageCell.h"
#import "Group.h"
#import "APIManager.h"
#import "Platform.h"

@interface ConversationFeedViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *arrayOfMessages;
@property (assign, nonatomic) BOOL isMoreDataLoading;
@property (assign, nonatomic) BOOL endLoading;
@property (assign, nonatomic) NSNumber *pageCount;
@property (assign, nonatomic) NSNumber *lastPage;
@end

@implementation ConversationFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.pageCount = @2;
    self.lastPage = @1000;
    self.arrayOfMessages = [[NSMutableArray alloc]init];
    
    [self getConversationsAPI];
}

//-(void) getConversations {
////    grab conversations - need to save more information
//
////    Do I really want to save the groups? no, i don't thnk so?
//    PFQuery *query = [PFQuery queryWithClassName:@"Group"];
////    [query whereKey:@"author" equalTo: PFUser.currentUser];
////    [query whereKey:@"listTitle" equalTo: self.list[@"name"]];
////    [query whereKey:@"author" equalTo: PFUser.currentUser];
//
////    [query orderByDescending:@"createdAt"];
//
//    // fetch data asynchronously
//    [query findObjectsInBackgroundWithBlock:^(NSArray *groups, NSError *error) {
//        if (groups != nil) {
//            self.arrayOfMessages = (NSMutableArray *) groups;
//
//            NSLog(@"hit here%@", self.arrayOfMessages);
////            for(NSDictionary *eachGroup in arrayFromServer){
////                NSLog(@"each Group %@", eachGroup);
////    //            Not sure if this is right but we rolling with it for now
////                Group *group = [[Group alloc] initWithJSONData:eachGroup];
////                [groups addObject:group];
////            }
//
//            [self.tableView reloadData];
//        } else {
//            NSLog(@"%@", error.localizedDescription);
//        }
//    }];
//
//}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];
    
    Group *group = self.arrayOfMessages[indexPath.row];
    cell.group = group;
    //        Hmm...
    cell.groupNameLabel.text = group.groupName;
    cell.lastMessageLabel.text = group.lastMessage;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfMessages.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row + 1 == [self.arrayOfMessages count]){
        //        Don't want to save the groups
        
        //        we are not hitting this
        if (!self.endLoading){
            [self getConversationsAPI];
        } else {
            NSLog(@"where do we end%@", self.pageCount);
        }
        //        [self getConversations:[self.arrayOfMessages count] + 10];
    }
}

-(void) getConversationsAPI {
    
    //    NSLog(@")
    if ([self.pageCount intValue] <= [self.lastPage intValue])  {
        // Configure session so that completion handler is executed on main UI thread
        
        NSMutableString *URLString = [[NSMutableString alloc] init];
        [URLString appendString:@"https://api.groupme.com/v3/groups?token="];
        [URLString appendString:[APIManager getAuthToken]];
        [URLString appendString:[NSString stringWithFormat:@"&page=%@", @1]];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        NSURLSession *session  = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
        
        NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:URLString] completionHandler:^(NSData *data, NSURLResponse *response, NSError *requestError) {
            if (requestError != nil) {
                NSLog(@"Trouble requesting page");
            } else {
                // Update flag
                self.isMoreDataLoading = false;
                
                // ... Use the new data to update the data source ...
                [self setupGroupsFromJSONArray:data];
                //                    self.pageCount = [NSNumber numberWithInt:[self.pageCount intValue] + 1];
                
                // Reload the tableView now that there is new data
                [self.tableView reloadData];
            }
        }];
        [task resume];
    }
}

-(void)setupGroupsFromJSONArray:(NSData*)dataFromServerArray{
    NSError *error;
    //    NSMutableArray *groups = [[NSMutableArray alloc] init];
    NSDictionary *arrayFromServer = [NSJSONSerialization JSONObjectWithData:dataFromServerArray options:0 error:nil];
    arrayFromServer = [arrayFromServer objectForKey:@"response"];
    
    NSLog(@"good?");
    if ([arrayFromServer count] == 0) {
        NSLog(@"bad");
        self.endLoading = YES;
    } else {
        NSLog(@"array %@", arrayFromServer);
        if ([arrayFromServer count] < 10) {
            NSLog(@"bad");
            self.lastPage = self.pageCount;
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
                
                //                [self.arrayOfMessages addObject:group];
                
                
                //                if (![PFUser.currentUser[@"GroupMe"][@"readConversations"] containsObject:group.groupID]) {
                //                        [self.arrayOfMessages addObject:group];
                //                }
                
                [self.tableView reloadData];
            }
            
            //        PFUser.currentUser[@"GroupME"] = groups;
            //        [PFUser.currentUser saveInBackground];
        }
        //    dispatch_async(dispatch_get_main_queue(), ^{
        //        [self.tableView reloadData];
        //    });
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.isMoreDataLoading) {
        // Calculate the position of one screen length before the bottom of the results
        int scrollViewContentHeight = self.tableView.contentSize.height;
        int scrollOffsetThreshold = scrollViewContentHeight - self.tableView.bounds.size.height;
        
        // When the user has scrolled past the threshold, start requesting
        if(scrollView.contentOffset.y > scrollOffsetThreshold && self.tableView.isDragging) {
            self.isMoreDataLoading = true;
            
            [self getConversationsAPI];
        }
        
    }
}

@end
