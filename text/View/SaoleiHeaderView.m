//
//  SaoleiHeaderView.m
//  text
//
//  Created by hanlu on 16/8/2.
//  Copyright © 2016年 吴迪. All rights reserved.
//

#import "SaoleiHeaderView.h"
#import "SaoleiNumberOrTimeImageView.h"
#define WD_width CGRectGetWidth(self.frame)
#define WD_height CGRectGetHeight(self.frame)

@implementation SaoleiHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:179 / 255.0f green:177 / 255.0f blue:179 / 255.0f alpha:1];
        
        CGFloat mm =  [UIScreen mainScreen].bounds.size.height / 736;
        
        _numberOfLeiView = [[SaoleiNumberOrTimeImageView alloc] initWithFrame:CGRectMake(WD_width / 4 - 50*mm, WD_height / 2 - 20*mm, 60*mm , 40*mm)];
        
        [self addSubview:_numberOfLeiView];
        
        _restartButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.bounds) - 25*mm, CGRectGetMidY(self.bounds) - 25*mm, 50*mm, 50*mm)];
        
        self.restartKind = RestartKindNormal;
        
        [self addSubview:_restartButton];
        
        _timeOfLeiView = [[SaoleiNumberOrTimeImageView alloc] initWithFrame:CGRectMake(WD_width / 4 * 3 - 10*mm, WD_height / 2 - 20*mm, 60*mm , 40*mm)];
        
        [self addSubview:_timeOfLeiView];
    }
    return self;
}

- (void)setRestartKind:(RestartKind)restartKind {
    _restartKind = restartKind;
    
    switch (restartKind) {
        case RestartKindNormal:
            [_restartButton setBackgroundImage:[UIImage imageNamed:@"classic_smile"] forState:(UIControlStateNormal)];
            
            [_restartButton setBackgroundImage:[UIImage imageNamed:@"classic_smile_down"] forState:(UIControlStateHighlighted)];
            break;
        case RestartKindWin:
            [_restartButton setBackgroundImage:[UIImage imageNamed:@"classic_smile_win"] forState:(UIControlStateNormal)];
            break;
        case RestartKindLose:
            [_restartButton setBackgroundImage:[UIImage imageNamed:@"classic_smile_dead"] forState:(UIControlStateNormal)];
            break;
    }
}

@end
