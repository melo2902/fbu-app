//
//  MTDListCell.m
//  fbu-app
//
//  Created by mwen on 7/12/21.
//

#import "MTDListCell.h"

@implementation MTDListCell

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

@end
