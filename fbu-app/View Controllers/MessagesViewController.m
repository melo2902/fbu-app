//
//  MessagesViewController.m
//  fbu-app
//
//  Created by mwen on 7/26/21.
//

#import "MessagesViewController.h"
#import "MTDGroup.h"
#import "MTDAPIManager.h"
#import "MTDPlatform.h"

@interface MessagesViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>
@property (nonatomic, strong) NSMutableArray *arrayOfMessages;
@property (nonatomic, strong) NSString *latestMessageID;
@property(strong, nonatomic) NSMutableDictionary *avatarTable;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;
@property (assign, nonatomic) BOOL isMoreDataLoading;
@property (assign, nonatomic) BOOL endLoading;
@property (assign, nonatomic) CGFloat oldContentHeight;
@end

@implementation MessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeVariables];
    [self setupChatBubbles];
    [self getMessages];
}

- (void) initializeVariables {
    self.title = self.group.groupName;
    self.arrayOfMessages = [[NSMutableArray alloc]init];
    self.avatarTable = [[NSMutableDictionary alloc] init];
    // [self setUpAvatarTable];
    
    MTDPlatform *userPlatform = PFUser.currentUser[@"GroupMe"];
    [userPlatform fetchIfNeeded];
    
    self.senderId = userPlatform[@"userID"];
    self.senderDisplayName = userPlatform[@"userName"];
    
    self.isMoreDataLoading = NO;
    self.endLoading = NO;
//    self.oldContentHeight = self.collectionView.contentSize.height;
}

# pragma mark - Initialize collection view

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.arrayOfMessages objectAtIndex:indexPath.item];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.arrayOfMessages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    JSQMessage *msg = [self.arrayOfMessages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor whiteColor];
        } else {
            cell.textView.textColor = [UIColor blackColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                               NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}

# pragma mark - Parse through Messages API data

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.isMoreDataLoading && !self.endLoading) {
        if(scrollView.contentOffset.y < 10) {
            [self getMessages];
        }

    }
}

- (void) getMessages {
    if (!self.isMoreDataLoading && !self.endLoading) {
        self.isMoreDataLoading = YES;
        
        NSMutableString *URLString = [[NSMutableString alloc] init];
        [URLString appendString:@"https://api.groupme.com/v3/groups/"];
        [URLString appendString:self.group.groupID];
        [URLString appendString:@"/messages?limit=10&token="];
        [URLString appendString:PFUser.currentUser[@"authToken"]];
        
        if ([self.latestMessageID length] != 0) {
            [URLString appendString:[NSString stringWithFormat:@"&before_id=%@", self.latestMessageID]];
        }
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        NSURLSession *session  = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
        
        NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:URLString] completionHandler:^(NSData *data, NSURLResponse *response, NSError *requestError) {
            if (requestError != nil) {
                NSLog(@"Trouble requesting page");
            } else {
                NSDictionary *arrayFromServer = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSDictionary *messageFromServer = [[arrayFromServer objectForKey:@"response"] objectForKey: @"messages"];
                
                [self setupMessages:messageFromServer];
            }
        }];
        
        [task resume];
    }
}

- (void) setupMessages: (NSDictionary*)messageFromServer{
    NSInteger numOfNewMessages = [messageFromServer count];
    NSInteger messageCountLimit = 10;
    
    if (numOfNewMessages < messageCountLimit) {
        self.endLoading = YES;
    }
    
    NSMutableArray *newMessages = [[NSMutableArray alloc] init];
    
    for(NSDictionary *message in messageFromServer){
        JSQMessage *newMessage = [self createMessage: message];
        [newMessages addObject:newMessage];
        
        self.latestMessageID = message[@"id"];
    }
    
    [self updateMessagesArray: newMessages];
}

- (JSQMessage *) createMessage: (NSDictionary *) messageData {
    JSQMessage *jsqMessage;
    NSString *senderId = [messageData objectForKey:@"sender_id"];
    NSString *senderName = [messageData objectForKey:@"name"];
    double timestamp = [[messageData objectForKey:@"created_at"] doubleValue];
    NSTimeInterval timeInterval = timestamp;
    NSDate *sentDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    NSString *messageText = [messageData objectForKey:@"text"];
    
    if (![messageText isEqual:[NSNull null]]) {
        jsqMessage = [[JSQMessage alloc] initWithSenderId:senderId
                                        senderDisplayName:senderName
                                                     date:sentDate
                                                     text:messageText];
    } else if ([[messageData objectForKey:@"attachments"] count]) {

        for (NSDictionary *attachment in [messageData objectForKey:@"attachments"]) {
            if ([[attachment objectForKey:@"type"] isEqualToString:@"image"] || [[attachment objectForKey:@"type"] isEqualToString:@"linked_image"]){
                
                NSURL *photoURL = [NSURL URLWithString:[attachment objectForKey:@"url"]];
                NSData *photoData = [NSData dataWithContentsOfURL:photoURL];
                JSQPhotoMediaItem *photo = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageWithData:photoData]];

                if (![senderId isEqualToString:self.senderId]){
                    photo.appliesMediaViewMaskAsOutgoing = NO;
                }
                
                jsqMessage = [[JSQMessage alloc] initWithSenderId:senderId
                                                senderDisplayName:senderName
                                                             date:sentDate
                                                            media:photo];
            }
            
            if ([[attachment objectForKey:@"type"] isEqualToString:@"video"]){
                JSQVideoMediaItem *mediaItem = [[JSQVideoMediaItem alloc] initWithFileURL:[attachment objectForKey:@"url"] isReadyToPlay:NO];
                jsqMessage = [[JSQMessage alloc] initWithSenderId:senderId
                                                senderDisplayName:senderName
                                                             date:sentDate
                                                            media:mediaItem];
            }
        }
    }
    
    return jsqMessage;
}

- (void) updateMessagesArray: (NSMutableArray *) newMessages {
    newMessages = [[[newMessages reverseObjectEnumerator] allObjects] mutableCopy];
    self.arrayOfMessages = [[newMessages arrayByAddingObjectsFromArray:self.arrayOfMessages] mutableCopy];
    [self.collectionView reloadData];
    [self resetViewPosition];
    
    self.isMoreDataLoading = NO;
}

- (void) resetViewPosition {
    CGFloat newTableViewHeight = self.collectionView.contentSize.height;
    
    if (self.oldContentHeight) {
        self.collectionView.contentOffset = CGPointMake(0, newTableViewHeight - self.oldContentHeight);
    } else {
        [self scrollToBottomAnimated:NO];
    }
    
    self.oldContentHeight = self.collectionView.contentSize.height;
}

#pragma mark - Message (bubbles & label) styling

- (void)setupChatBubbles {
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    self.outgoingBubbleImageData =
    [bubbleFactory outgoingMessagesBubbleImageWithColor:[self groupMeBlue]];
    self.incomingBubbleImageData =
    [bubbleFactory incomingMessagesBubbleImageWithColor:[self groupMeLightGray]];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
             messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessage *message = [self.arrayOfMessages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubbleImageData;
    }
    
    return self.incomingBubbleImageData;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.arrayOfMessages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = [self.arrayOfMessages objectAtIndex:indexPath.item];
   
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.arrayOfMessages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item % 3 == 0) { //Timestamp an item
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessage *currentMessage = [self.arrayOfMessages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.arrayOfMessages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
    return 0.0f;
}

#pragma mark - JSQMessage Handling

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate   *)date {
    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];
    [self.arrayOfMessages addObject:message];

    [MTDAPIManager sendTextMessage:text inGroup:self.group.groupID];
    
    [self finishSendingMessageAnimated:YES];
    [self scrollToBottomAnimated:YES];
    
}

# pragma mark - setting up avatars

- (void) setUpAvatarTable {
    // Adds profile picture but makes it run substantially slower
    for (NSDictionary *user in self.group.members) {
        if ([user objectForKey:@"image_url"] != [NSNull null]) {
            [self.avatarTable setValue:[NSURL URLWithString:[user objectForKey:@"image_url"]] forKey:[user objectForKey:@"user_id"]];
        }
    }
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = [self.arrayOfMessages objectAtIndex:indexPath.item];

    if ([[self.avatarTable allKeys] containsObject:message.senderId]) {
        UIImage *avatar = [UIImage imageWithData:[NSData dataWithContentsOfURL:[self.avatarTable valueForKey:message.senderId]]];
        UIImage *circularImage = [JSQMessagesAvatarImageFactory circularAvatarHighlightedImage:avatar withDiameter:kJSQMessagesCollectionViewAvatarSizeDefault];

        return [JSQMessagesAvatarImage avatarWithImage:circularImage];
    } else {
        // Use this for default pfp view later
        NSMutableString * firstCharacters = [NSMutableString string];
        NSArray * words = [message.senderDisplayName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        for (NSString * word in words) {
            if ([word length] > 0) {
                NSString * firstLetter = [word substringToIndex:1];
                [firstCharacters appendString:[firstLetter uppercaseString]];
            }
        }
        return [JSQMessagesAvatarImageFactory avatarImageWithUserInitials:firstCharacters backgroundColor:[self groupMeGray] textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:14] diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    }
}

# pragma mark - view controller segues

- (IBAction)onTapBackButton:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

# pragma mark - color templates
- (UIColor *) groupMeBlue {
    return [UIColor colorWithRed:0.f/255.f green:175.f/255.f blue:240.f/255.f alpha:1.f];
}

-(UIColor *) groupMeLightGray {
    return [UIColor colorWithRed:230.f/255.f green:230.f/255.f blue:230.f/255.f alpha:1.f];
}

-(UIColor *) groupMeWhite {
    return [UIColor whiteColor];
}

-(UIColor *) groupMeGray {
    return [UIColor colorWithRed:130.f/255.f green:130.f/255.f blue:130.f/255.f alpha:1.f];
}

@end
