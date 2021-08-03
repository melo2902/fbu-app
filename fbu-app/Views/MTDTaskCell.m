//
//  MTDTaskCell.m
//  fbu-app
//
//  Created by mwen on 7/13/21.
//

#import "MTDTaskCell.h"
#import "Parse/Parse.h"

@implementation MTDTaskCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)layoutSubviews {
    self.contentView.backgroundColor = [UIColor systemGroupedBackgroundColor];

    UIView *whiteRoundedView = [[UIView alloc]initWithFrame:CGRectMake(0, 2, self.contentView.frame.size.width - 1, self.contentView.frame.size.height - 5)];
                                      
    whiteRoundedView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    whiteRoundedView.clipsToBounds = true;
    whiteRoundedView.layer.masksToBounds = true;
    whiteRoundedView.layer.cornerRadius = 12.0;

    [self.contentView addSubview:whiteRoundedView];
    [self.contentView sendSubviewToBack:whiteRoundedView];
}

- (IBAction)onTapStatus:(id)sender {
    if (self.completionButton.selected) {
        NSLog(@"Button is not selected!");
        
        self.completionButton.selected = NO;
        self.task[@"completed"] = @NO;
        
    } else {
        NSLog(@"Button is selected!");
        
        self.completionButton.selected = YES;
        self.task[@"completed"] = @YES;
    }
    
    [self.task saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            self.completionButtonTapHandler();
        }
    }];
}

@end
