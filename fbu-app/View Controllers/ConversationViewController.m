//
//  ConversationViewController.m
//  fbu-app
//
//  Created by mwen on 7/15/21.
//

#import "ConversationViewController.h"

@interface ConversationViewController ()
@property (weak, nonatomic) IBOutlet UILabel *conversationNameLabel;
@end

@implementation ConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.conversationNameLabel.text = self.group.lastMessage;
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
