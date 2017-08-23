//
//  ViewController.m
//  text
//
//  Created by hanlu on 16/7/30.
//  Copyright © 2016年 吴迪. All rights reserved.
//

#import "ViewController.h"
#import "SaoleiView.h"
#import "SaoleiHeaderView.h"
#import "SaoleiNumberOrTimeImageView.h"
#import "SaoleiFooterView.h"
@interface SaoleiViewController ()

@property (nonatomic,assign) SaoleiUserClickKind clickKind;

@property (nonatomic,assign) BOOL firstClick;

@property (nonatomic,assign) NSInteger numberOfLeiExist;

@property (nonatomic,assign) NSInteger numberOfLei;

@property (nonatomic,assign) NSInteger timeInterval;

@property (nonatomic,strong) NSTimer *timer;

@property (nonatomic,strong) SaoleiView *saoleiView;

@property (nonatomic,strong) SaoleiHeaderView *headerView;

@property (nonatomic,strong) SaoleiFooterView *footerView;

@property (nonatomic,strong) NSDate *beginDate;

@property (nonatomic,strong) NSDate *winDate;

@end

@implementation SaoleiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _firstClick = YES;
    
    [self setupUI];
    
    self.numberOfLei = 5;
    
    self.numberOfLeiExist = self.numberOfLei;
}

- (void)setupUI {
    SaoleiView *view = [[SaoleiView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame)) NumberOfChessInLine:16 NumberOfChessInList:16 ViewController:self];
    
    view.center = CGPointMake(self.view.center.x, self.view.center.y  + 50 * [UIScreen mainScreen].bounds.size.height / 736);
    
    self.saoleiView = view;
    
    [self.view addSubview:view];
    
    _headerView = [[SaoleiHeaderView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(view.frame) - 60, self.view.frame.size.width, 60)];
    
    [_headerView.restartButton addTarget:self action:@selector(gameRestarted) forControlEvents:(UIControlEventTouchUpInside)];
    
    [self.view addSubview:_headerView];
    
    _footerView = [[SaoleiFooterView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(view.frame), self.view.frame.size.width, 60)];
    
    [_footerView.normalButton addTarget:self action:@selector(changeClickKindWithButton:) forControlEvents:(UIControlEventTouchUpInside)];
    
    [_footerView.questionButton addTarget:self action:@selector(changeClickKindWithButton:) forControlEvents:(UIControlEventTouchUpInside)];
    
    [_footerView.flagButton addTarget:self action:@selector(changeClickKindWithButton:) forControlEvents:(UIControlEventTouchUpInside)];
    
    [self.view addSubview:_footerView];
}

- (void)changeClickKindWithButton:(UIButton *)sender {
    self.clickKind = sender.tag;
}

- (void)gameRestarted {
    self.numberOfLeiExist = self.numberOfLei;
    
    self.timeInterval = 0;
    
    self.saoleiView.userInteractionEnabled = YES;
    
    self.firstClick = YES;
    
    self.clickKind = SaoleiUserClickKindNormal;
    
    self.headerView.restartKind = RestartKindNormal;
    
    [self timerEnd];
    
    [self.saoleiView getRestarted];
}

- (void)timerStart {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeAdd) userInfo:nil repeats:YES];
}

- (void)timerEnd {
    [self.timer invalidate];
}

- (void)timeAdd{
    self.timeInterval ++;
}
/**
 *  棋盘上的按钮被点到
 */
- (void)buttonDidClicked:(SaoleiChessView *)sender{
    switch (self.clickKind) {
        case SaoleiUserClickKindFlag:{
            [self otherClickStyle:SaoleiUserClickKindFlag withSender:sender];
            
            [self checkWin];
        }
            break;
        case SaoleiUserClickKindNormal:{
            [self normalClickStyleWithSender:sender];
            
            [self checkWin];
            }
            break;
        case SaoleiUserClickKindQusetion:{
            [self otherClickStyle:SaoleiUserClickKindQusetion withSender:sender];
        }
            break;
    }
    
}

- (void)normalClickStyleWithSender:(SaoleiChessView *)sender {
    if (_firstClick) {
        [self setLeiNumber:self.numberOfLei andFirstPosition:sender.position];
        
        [self timerStart];
        
        _firstClick = !_firstClick;
        
        self.beginDate = [NSDate date];
    }
    
    /**
     *  该按钮首先需要可以被点击
     */
    if (sender.enabled) {
        /**
         *  该按钮其次上面不能有棋子和问号，这俩都不能被点击
         */
        if (sender.clickKind == SaoleiUserClickKindNormal) {
            /**
             *  当该棋子为雷的时候
             */
            if (sender.isLei) {
                [sender setBackgroundImage:[UIImage imageNamed:@"tile_0_b"] forState:(UIControlStateDisabled)];
                
                sender.enabled = NO;
                
                [self loseGame];
            }else {
                /**
                 *  周围的雷数不为0
                 */
                if (sender.numberOfLei) {
                    NSString *string = [NSString stringWithFormat:@"tile_0_%ld~hd.png",sender.numberOfLei];
                    
                    [sender setBackgroundImage:[UIImage imageNamed:string] forState:(UIControlStateDisabled)];
                    
                    sender.enabled = NO;
                }else {
                    [sender setBackgroundImage:[UIImage imageNamed:@"tile_0_base~hd"] forState:(UIControlStateDisabled)];
                    
                    sender.enabled = NO;
                    /**
                     *  当用户点击的这个棋子周围8个格都没有雷的时候，系统自动帮忙点击其余8个,加快游戏进度
                     */
                    for (SaoleiChessView *chess in [self getButtonsAroundSender:sender]) {
                        [self normalClickStyleWithSender:chess];
                    }
                }
            }
        }
    }
}

- (void)otherClickStyle:(SaoleiUserClickKind)clickKind withSender:(SaoleiChessView *)sender {
    if (sender.clickKind != clickKind) {
        sender.clickKind = clickKind;
    } else {
        sender.clickKind = SaoleiUserClickKindNormal;
    }
    [self checkNumberOfLeiExistist];
}

- (void)checkNumberOfLeiExistist {
    NSInteger numberOfFlags = 0;
    
    for (SaoleiChessView *chess in self.saoleiView.subviews) {
        if (chess.clickKind == SaoleiUserClickKindFlag) {
            numberOfFlags ++;
        }
    }
    
    self.numberOfLeiExist = self.numberOfLei - numberOfFlags;
}

- (void)checkWin {
    NSInteger realNumber = 0;
    
    for (SaoleiChessView *chess in self.saoleiView.subviews) {
        if (chess.isLei) {
            if (chess.clickKind == SaoleiUserClickKindFlag) {
                realNumber ++;
            }
        }
        
    }
    if (realNumber == self.numberOfLei && self.numberOfLeiExist == 0) {
        [self winGame];
    }
}

- (void)winGame {
    self.headerView.restartKind = RestartKindWin;
    
    self.saoleiView.userInteractionEnabled = NO;
    
    [self timerEnd];
    
    self.winDate = [NSDate date];
    
    
}

- (void)loseGame {
    self.headerView.restartKind = RestartKindLose;
    
    [self.saoleiView showAll];
    
    self.saoleiView.userInteractionEnabled = NO;
    
    [self timerEnd];
}

/**
 *  返回按钮周围一圈按钮的数组
 */
- (NSArray <__kindof SaoleiChessView *> *)getButtonsAroundSender:(SaoleiChessView *)sender {
    NSMutableArray *array = [NSMutableArray array];
    
    NSInteger x = sender.position.x;
    
    NSInteger y = sender.position.y;
    
    for (int y1 = 0; y1 < 3; y1 ++) {
        for (int x1 = 0; x1 < 3; x1 ++) {
            SaoleiChessView *chess = [self.saoleiView viewWithPostion:[Position positionWithX:x - 1 + x1 andY:y - 1 +y1]];
            if (chess && ![chess isEqual:sender] && [chess isKindOfClass:[SaoleiChessView class]]) {
                [array addObject:chess];
            }
        }
    }
    
    return array;
}
/**
 *  该按钮设置周围雷的数量
 */
- (void)setNumberOfLeiToSender:(SaoleiChessView *)sender {
    NSArray *array = [self getButtonsAroundSender:sender];
    
    if (!sender.isLei) {
        for (SaoleiChessView *item in array) {
        
            if (item.isLei) {
                sender.numberOfLei ++;
            }
        }
    }
}

/**
 *  设置雷的数量
 *
 *  @param number
 */
- (void)setLeiNumber:(NSInteger)number andFirstPosition:(Position  *)position{
    NSMutableArray *array = [NSMutableArray array];
    
    while (number) {
        NSInteger x = arc4random() % self.saoleiView.numberOfChessInLine + 1;
        
        NSInteger y = arc4random() % self.saoleiView.numberOfChessInList + 1;
        
        if (position.x == x && position.y == y) {
            continue;
        }else {
            Position *p = [Position positionWithX:x andY:y];
            
            if ([array containsObject:p]) {
                continue;
            } else {
                [array addObject:p];
            }
        }
        number --;
    }

    for (Position *p in array) {
        SaoleiChessView *chess = [self.saoleiView viewWithPostion:p];

        chess.isLei = YES;
    }
    
    for (SaoleiChessView *chess in self.saoleiView.subviews) {
        [self setNumberOfLeiToSender:chess];
    }
}
/**
 *  设置有多少个雷的时候更换显示
 */
- (void)setNumberOfLeiExist:(NSInteger)numberOfLeiExist {
    _numberOfLeiExist = numberOfLeiExist;
    
    self.headerView.numberOfLeiView.numberInImage = numberOfLeiExist;
}

/**
 *  设置过了多长时间
 */
- (void)setTimeInterval:(NSInteger)timeInterval {
    _timeInterval = timeInterval;
    
    self.headerView.timeOfLeiView.numberInImage = timeInterval;
}
@end
