//
//  PaihangTableViewCell.m
//  text
//
//  Created by hanlu on 16/8/4.
//  Copyright © 2016年 LHL. All rights reserved.
//

#import "PaihangTableViewCell.h"
#import "UserModel.h"

@interface PaihangTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *rankingLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameModel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;


@end

@implementation PaihangTableViewCell

- (void)setModel:(UserModel *)model {
    _model = model;
    
    _nameModel.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"用户名", nil),model.name];
    
    _timeLabel.text = [NSString stringWithFormat:@"%@:%ld秒", NSLocalizedString(@"耗时",nil),model.costTime];
}

- (void)setRanking:(NSInteger)ranking {
    _ranking = ranking;
    
    _rankingLabel.text = [NSString stringWithFormat:@"%ld .",ranking];
}

@end
