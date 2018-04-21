//
//  SaoleiFooterView.m
//  text
//
//  Created by hanlu on 16/8/2.
//  Copyright © 2016年 LHL. All rights reserved.
//

#import "SaoleiFooterView.h"
#define WD_width self.frame.size.width
#define WD_height self.frame.size.height
@implementation SaoleiFooterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    CGFloat width = 0;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        width = WD_width/ 8;
    }
    else {
        width = WD_width/ 10;
    }
    
    
    _normalButton = [[UIButton alloc] initWithFrame:CGRectMake(WD_width / 4 - width/2, WD_height / 2 - width/2, width, width)];
    _normalButton.tag = 0;
    [_normalButton setBackgroundImage:[UIImage imageNamed:@"tile_1_mask_down"] forState:(UIControlStateNormal)];
    [_normalButton setBackgroundImage:[UIImage imageNamed:@"tile_1_mask_down_h"] forState:(UIControlStateSelected)];
    _normalButton.selected = YES;

    [self addSubview:_normalButton];
    
    _normalLabel = [self getTipLabelFrame:CGRectMake(WD_width / 4 - width/2, CGRectGetMaxY(_normalButton.frame)+5, width, 20) text:NSLocalizedString(@"排雷", nil)];
    [self addSubview:_normalLabel];

    _flagButton = [[UIButton alloc] initWithFrame:CGRectMake(WD_width / 2 - width/2, WD_height / 2 - width/2, width, width)];
    
    _flagButton.tag = 1;
    
    [_flagButton setBackgroundImage:[UIImage imageNamed:@"tile_1_d"] forState:(UIControlStateNormal)];
    [_flagButton setBackgroundImage:[UIImage imageNamed:@"tile_1_d_h"] forState:(UIControlStateSelected)];

    [self addSubview:_flagButton];
    
    _flagLabel = [self getTipLabelFrame:CGRectMake(WD_width / 2 - width/2, CGRectGetMaxY(_normalButton.frame)+5, width, 20) text:NSLocalizedString(@"有雷", nil)];
    [self addSubview:_flagLabel];

    
    _questionButton = [[UIButton alloc] initWithFrame:CGRectMake(WD_width / 4 * 3 - width/2, WD_height / 2 - width/2, width, width)];
    _questionButton.tag = 2;
    [_questionButton setBackgroundImage:[UIImage imageNamed:@"tile_1_hint_q"] forState:(UIControlStateNormal)];
    [_questionButton setBackgroundImage:[UIImage imageNamed:@"tile_1_hint_q_h@2x"] forState:(UIControlStateSelected)];
    
    [self addSubview:_questionButton];
    
    _questionLabel = [self getTipLabelFrame:CGRectMake(WD_width / 4 * 3 - width/2, CGRectGetMaxY(_normalButton.frame)+5, width, 20) text:NSLocalizedString(@"疑问", nil)];
    [self addSubview:_questionLabel];
}

- (UILabel *)getTipLabelFrame:(CGRect)frame text:(NSString *)text{
    UILabel * label = [[UILabel alloc] initWithFrame:frame];
    label.text = text;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        label.font = [UIFont systemFontOfSize:15];
    }
    else {
        label.font = [UIFont systemFontOfSize:21];
    }
    return label;
}

@end
