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

@interface ConversationFeedViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *arrayOfMessages;
@property (assign, nonatomic) BOOL isMoreDataLoading;
@end

@implementation ConversationFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self getConversations];
}

-(void) getConversations {
//    grab conversations - need to save more information
    
//    Do I really want to save the groups? no, i don't thnk so?
    PFQuery *query = [PFQuery queryWithClassName:@"Group"];
//    [query whereKey:@"author" equalTo: PFUser.currentUser];
//    [query whereKey:@"listTitle" equalTo: self.list[@"name"]];
//    [query whereKey:@"author" equalTo: PFUser.currentUser];
    
//    [query orderByDescending:@"createdAt"];
    
    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *groups, NSError *error) {
        if (groups != nil) {
            self.arrayOfMessages = (NSMutableArray *) groups;
            
            NSLog(@"hit here%@", self.arrayOfMessages);
//            for(NSDictionary *eachGroup in arrayFromServer){
//                NSLog(@"each Group %@", eachGroup);
//    //            Not sure if this is right but we rolling with it for now
//                Group *group = [[Group alloc] initWithJSONData:eachGroup];
//                [groups addObject:group];
//            }
            
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
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

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];
    
    Group *group = self.arrayOfMessages[indexPath.row];
    cell.group = group;
//        Hmm...
    cell.groupNameLabel.text = group[@"groupName"];
    cell.lastMessageLabel.text = group[@"lastMessage"];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"count %lu", (unsigned long)self.arrayOfMessages.count);
    return self.arrayOfMessages.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row + 1 == [self.arrayOfMessages count]){
//        Don't want to save the groups
        [self getConversationsAPI];
        
//        [self getConversations:[self.arrayOfMessages count] + 10];
    }
}

-(void) getConversationsAPI {
    // Configure session so that completion handler is executed on main UI thread
    NSMutableString *URLString = [[NSMutableString alloc] init];
//    [URLString appendString:@"https://api.groupme.com/groups?token="];
    [URLString appendString:@"https://api.groupme.com/v3/groups?token="];
    [URLString appendString:[APIManager getAuthToken]];
    NSError* error = nil;
    NSLog(@"%@", URLString);
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:URLString] options:NSDataReadingUncached error:&error];
//    NSDictionary *userData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//    NSLog(@"%@", userData);
//
    self.isMoreDataLoading = false;
    
    [self setupGroupsFromJSONArray:data];
    
    // ... Use the new data to update the data source ...
    
    // Reload the tableView now that there is new data
    [self.tableView reloadData];
    
//    Need this to make it on the main thread
//    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//
//    NSURLSession *session  = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
//
//    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *requestError) {
//        if (requestError != nil) {
//
//        }
//        else
//        {
//            // Update flag
//            self.isMoreDataLoading = false;
//
//            // ... Use the new data to update the data source ...
//
//            // Reload the tableView now that there is new data
//            [self.tableView reloadData];
//        }
//    }];
//    [task resume];
}

-(void)setupGroupsFromJSONArray:(NSData*)dataFromServerArray{
    NSError *error;
//    NSMutableArray *groups = [[NSMutableArray alloc] init];
    NSDictionary *arrayFromServer = [NSJSONSerialization JSONObjectWithData:dataFromServerArray options:0 error:nil];
    arrayFromServer = [arrayFromServer objectForKey:@"response"];
    NSLog(@"array %@", arrayFromServer);
    if(error){
        NSLog(@"error parsing the json data from server with error description - %@", [error localizedDescription]);
    }
    else {
//        self.groups = [[NSMutableArray alloc] init];
//        NSMutableArray *groups = [[NSMutableArray alloc] init];
        
        for(NSDictionary *eachGroup in arrayFromServer){
            NSLog(@"each Group %@", eachGroup);
//            Not sure if this is right but we rolling with it for now
            Group *group = [[Group alloc] initWithJSONData:eachGroup];
            [self.arrayOfMessages addObject:group];
//            [groups addObject:group];
        }
        
//        PFUser.currentUser[@"GroupME"] = groups;
//        [PFUser.currentUser saveInBackground];
    }
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.tableView reloadData];
//    });
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
           // ... Code to load more results ...
       }

    }
}

@end
