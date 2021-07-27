//
//  MessagesViewController.m
//  fbu-app
//
//  Created by mwen on 7/26/21.
//

#import "MessagesViewController.h"
#import "Group.h"
#import "APIManager.h"
#import "Platform.h"

@interface MessagesViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic) NSMutableArray *userData;
@property (nonatomic, strong) NSMutableArray *arrayOfMessages;
@property (nonatomic, strong) NSString *latestMessageID;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property(strong, nonatomic) NSMutableDictionary *avatarTable;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;
@end

@implementation MessagesViewController
NSString * const mediaTypes[] = { @"image", @"video", @"location" };

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.arrayOfMessages = [[NSMutableArray alloc]init];
    
    Platform *userPlatform = PFUser.currentUser[@"GroupMe"];
    [userPlatform fetchIfNeeded];
    
    self.senderId = userPlatform[@"userID"];
    self.senderDisplayName = userPlatform[@"userName"];
    
    [self setupChatBubbles];
    self.avatarTable = [[NSMutableDictionary alloc] init];
    
    // Adds profile picture but makes it run substantially slower
    //    for (NSDictionary *user in self.group.members) {
    //        if ([user objectForKey:@"image_url"] != [NSNull null]) {
    //            [self.avatarTable setValue:[NSURL URLWithString:[user objectForKey:@"image_url"]] forKey:[user objectForKey:@"user_id"]];
    //        }
    //    }
    
    [self getMessages];
}

- (void) getMessages {
    NSMutableString *URLString = [[NSMutableString alloc] init];
    [URLString appendString:@"https://api.groupme.com/v3/groups/"];
    [URLString appendString:self.group.groupID];
    [URLString appendString:@"/messages?limit=10&token="];
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
            [self setupMessages:data];
        }
    }];
    
    [task resume];
    [self.refreshControl endRefreshing];
}

- (void) setupMessages: (NSData*)data{
    NSDictionary *arrayFromServer = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSDictionary *responseFromServer = [arrayFromServer objectForKey:@"response"];
    NSDictionary *messageFromServer = [responseFromServer objectForKey:@"messages"];
    
    for(NSDictionary *message in messageFromServer){
        JSQMessage *jsqMessage;
        NSString *senderId = [message objectForKey:@"sender_id"];
        NSString *senderName = [message objectForKey:@"name"];
        
        double timestamp = [[message objectForKey:@"created_at"] doubleValue];
        NSTimeInterval timeInterval = timestamp;
        NSDate *sentDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        
        NSString *messageText = [message objectForKey:@"text"];
        
        // Text messages
        if (![messageText isEqual:[NSNull null]]) {
            NSLog(@"Message %@", [message objectForKey:@"text"]);
            jsqMessage = [[JSQMessage alloc] initWithSenderId:senderId
                                            senderDisplayName:senderName
                                                         date:sentDate
                                                         text:messageText];
            
            if (jsqMessage) {
                [self.arrayOfMessages addObject:jsqMessage];
            }
        }
        
        // Media messages
        if ([[message objectForKey:@"attachments"] count]) {

            for (NSDictionary *attachment in [message objectForKey:@"attachments"]) {
                // IMAGE //
                if ([[attachment objectForKey:@"type"] isEqualToString:@"image"] || [[attachment objectForKey:@"type"] isEqualToString:@"linked_image"]){
                    
                    NSURL *photoURL = [NSURL URLWithString:[attachment objectForKey:@"url"]];
                    NSData *photoData = [NSData dataWithContentsOfURL:photoURL];
                    JSQPhotoMediaItem *photo = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageWithData:photoData]];

                    // Don't mark as outgoing if not me
                    if (![senderId isEqualToString:self.senderId]){
                        photo.appliesMediaViewMaskAsOutgoing = NO;
                    }
                    
                    jsqMessage = [[JSQMessage alloc] initWithSenderId:senderId
                                                    senderDisplayName:senderName
                                                                 date:sentDate
                                                                media:photo];
                }
                
                // VIDEO //
                if ([[attachment objectForKey:@"type"] isEqualToString:@"video"]){
                    JSQVideoMediaItem *mediaItem = [[JSQVideoMediaItem alloc] initWithFileURL:[attachment objectForKey:@"url"] isReadyToPlay:NO];
                    
                    [self.collectionView reloadData];

                    jsqMessage = [[JSQMessage alloc] initWithSenderId:senderId
                                                    senderDisplayName:senderName
                                                                 date:sentDate
                                                                media:mediaItem];
                }
                
                if (jsqMessage) {
                    [self.arrayOfMessages addObject:jsqMessage];
                }
            }
        }
        
        self.latestMessageID = message[@"id"];
    }
    
    self.arrayOfMessages = [[[self.arrayOfMessages reverseObjectEnumerator] allObjects] mutableCopy];
    [self.collectionView reloadData];
    [self scrollToBottomAnimated:YES];
}

- (void)setupChatBubbles {
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    self.outgoingBubbleImageData =
    [bubbleFactory outgoingMessagesBubbleImageWithColor:[self groupMeBlue]];
    self.incomingBubbleImageData =
    [bubbleFactory incomingMessagesBubbleImageWithColor:[self groupMeLightGray]];
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

    [APIManager sendTextMessage:text inGroup:self.group.groupID];
    
    [self finishSendingMessageAnimated:YES];
    [self scrollToBottomAnimated:YES];
    
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.arrayOfMessages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
             messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessage *message = [self.arrayOfMessages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubbleImageData;
    }
    
    return self.incomingBubbleImageData;
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

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.arrayOfMessages count];
}


- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    JSQMessage *msg = [self.arrayOfMessages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor whiteColor];
        }
        else {
            cell.textView.textColor = [UIColor blackColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                               NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
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

# pragma color templates
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
