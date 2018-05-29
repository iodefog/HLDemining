//
//  ViewController.m
//  text
//
//  Created by hanlu on 16/7/30.
//  Copyright © 2016年 LHL. All rights reserved.
//

#import "SaoleiViewController.h"
#import "SaoleiView.h"
#import "SaoleiHeaderView.h"
#import "SaoleiNumberOrTimeImageView.h"
#import "SaoleiFooterView.h"
#import "SaveHandle.h"
#import "PopViewController.h"
#import "PaihangViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <InMobiSDK/InMobiSDK.h>
#import "Masonry.h"

#define HLScreenWidth MIN(CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds))
#define HLScreenHeight MAX(CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds))

@interface SaoleiViewController ()<UIPopoverPresentationControllerDelegate,
PopViewControllerDelegate,
IMInterstitialDelegate,
IMBannerDelegate>
/**
 *  用户选择的点击方式
 */
@property (nonatomic,assign) SaoleiUserClickKind clickKind;
/**
 *  是否是第一次点击
 */
@property (nonatomic,assign) BOOL firstClick;

/**
 *  是否是正在游戏
 */
@property (nonatomic,assign) BOOL isPalying;

/**
 *  还剩余的雷数(用来控制左侧计数面板的显示数字)
 */
@property (nonatomic,assign) NSInteger numberOfLeiExist;
/**
 *  雷存在的总数
 */
@property (nonatomic,assign) NSInteger numberOfLei;
/**
 *  用来控制右侧计时面板的显示时间
 */
@property (nonatomic,assign) NSInteger timeInterval;
/**
 *  右侧计时面板定时器
 */
@property (nonatomic,strong) NSTimer *timer;
/**
 *  扫雷主视图
 */
@property (nonatomic,strong) SaoleiView *saoleiView;
/**
 *  扫雷头部视图
 */
@property (nonatomic,strong) SaoleiHeaderView *headerView;
/**
 *  扫雷选择视图
 */
@property (nonatomic,strong) SaoleiFooterView *footerView;

@property (nonatomic,copy) NSString *userName;
/**
 *  难度(中级16X16 40个雷，初级8X8 10个雷)
 */
@property (nonatomic,assign) KindOfUserDifficulty difficulty;

@property (nonatomic,strong) PopViewController *popVC;

@property (nonatomic,strong) PaihangViewController *paihangVC;

@property (nonatomic,assign) NSInteger randomNum;

@property (nonatomic,strong) NSArray *difficultyArray;

@property (nonatomic,strong) IMBanner *banner;
@property (nonatomic,strong) IMInterstitial *interstitial;
@property (nonatomic,strong) AVAudioPlayer *player;
@end

@implementation SaoleiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _firstClick = YES;
    
    self.difficultyArray = @[
                             NSLocalizedString(@"儿童模式(5雷)", nil),
                             NSLocalizedString(@"简单(10雷)", nil),
                             NSLocalizedString(@"中级(40雷)", nil),
                             NSLocalizedString(@"困难(70雷)", nil),
                             NSLocalizedString(@"梦魇(100雷)", nil)];
    
    [self setupUI];
    
    self.userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    
    self.difficulty = [[[NSUserDefaults standardUserDefaults] objectForKey:@"difficulty"] integerValue];
    
    [self addAdBannner];
    
    if (!self.interstitial) {
        self.interstitial = [[IMInterstitial alloc] initWithPlacementId:1523427796248];
        self.interstitial.delegate = self;
        [self.interstitial load];
    }
}

- (void)addAdBannner{
    self.banner = [[IMBanner alloc] initWithFrame:CGRectMake(0, 300, 320, 50)
                                      placementId:1513346833738 delegate:self] ;
//    self.banner.keywords = @"sports, cars, bikes";//设置显示广告的类型
//    self.banner.refreshInterval = 25;
    [self.view addSubview:self.banner];
    [self.banner mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.height.mas_equalTo(50);
    }];

    [self.banner load];
//    [self.banner shouldAutoRefresh:YES];//设置是否自动刷新
    
}

- (void)addInterstitial{
    [self.interstitial showFromViewController:self];
    [self.interstitial load];
}


- (void)setupUI {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"选择难度", nil) style:(UIBarButtonItemStylePlain) target:self action:@selector(popView)];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"排行榜", nil) style:(UIBarButtonItemStylePlain) target:self action:@selector(popPaihang)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"排行榜"] style:UIBarButtonItemStylePlain target:self action:@selector(popPaihang)];

    
    SaoleiView *view = [[SaoleiView alloc] initWithFrame:CGRectMake(0, 0, HLScreenWidth, HLScreenWidth) NumberOfChessInLine:0 NumberOfChessInList:0 ViewController:self];
    
    view.center = CGPointMake(HLScreenWidth/2, HLScreenHeight/2  + 0 * HLScreenHeight / 736 );
    
    self.saoleiView = view;
    
    [self.view addSubview:view];
    
    _headerView = [[SaoleiHeaderView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(view.frame) - 60*HLScreenHeight / 736, HLScreenWidth, 60*HLScreenHeight / 736)];
    
    [_headerView.restartButton addTarget:self action:@selector(tryGameRestarted) forControlEvents:(UIControlEventTouchUpInside)];
    
    [self.view addSubview:_headerView];
    
    _footerView = [[SaoleiFooterView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(view.frame)+30, HLScreenWidth, 60*HLScreenHeight / 736)];
    
    [_footerView.normalButton addTarget:self action:@selector(changeClickKindWithButton:) forControlEvents:(UIControlEventTouchUpInside)];
    
    [_footerView.questionButton addTarget:self action:@selector(changeClickKindWithButton:) forControlEvents:(UIControlEventTouchUpInside)];
    
    [_footerView.flagButton addTarget:self action:@selector(changeClickKindWithButton:) forControlEvents:(UIControlEventTouchUpInside)];
    
    [self.view addSubview:_footerView];
    
    self.clickKind = 0;
    
}

-(void)popPaihang{
    _paihangVC = [[PaihangViewController alloc] init];
    
    _paihangVC.randomNum = self.randomNum;
    
    _paihangVC.difficulty = self.difficulty;
    
    _paihangVC.modalPresentationStyle = UIModalPresentationPopover;
    
    //设置依附的按钮
    _paihangVC.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
    
    //可以指示小箭头颜色
    _paihangVC.popoverPresentationController.backgroundColor = [UIColor whiteColor];
    
    //content尺寸
    _paihangVC.preferredContentSize = CGSizeMake(200, 250);
    
    //pop方向
    _paihangVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    //delegate
    _paihangVC.popoverPresentationController.delegate = self;
    
    [self presentViewController:_paihangVC animated:YES completion:nil];
}

-(void)popView{
    _popVC = [[PopViewController alloc] init];
    
    _popVC.difficultyArray = self.difficultyArray;
    
    _popVC.delegate = self;
    
    _popVC.modalPresentationStyle = UIModalPresentationPopover;
    
    //设置依附的按钮
    _popVC.popoverPresentationController.barButtonItem = self.navigationItem.leftBarButtonItem;
    
    //可以指示小箭头颜色
    _popVC.popoverPresentationController.backgroundColor = [UIColor whiteColor];
    
    //content尺寸
    if ([[[self class] getPreferredLanguage] isEqualToString:@"zh-Hans"]) {
        _popVC.preferredContentSize = CGSizeMake(120, 216);
    }else {
        _popVC.preferredContentSize = CGSizeMake(200, 216);
    }
    //pop方向
    _popVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    //delegate
    _popVC.popoverPresentationController.delegate = self;
    
    [self presentViewController:_popVC animated:YES completion:nil];
}
//代理方法 ,点击即可dismiss掉每次init产生的PopViewController
-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    return UIModalPresentationNone;
}

- (void)popViewController:(PopViewController *)popViewController didselectedWith:(NSInteger)indexPathRow {
    [popViewController dismissViewControllerAnimated:YES completion:^{
        self.difficulty = indexPathRow;
        
        [self gameRestarted];
    }];
}

- (void)changeClickKindWithButton:(UIButton *)sender {
    _footerView.flagButton.selected = NO;
    _footerView.normalButton.selected = NO;
    _footerView.questionButton.selected = NO;
    self.clickKind = sender.tag;
    sender.selected = !sender.selected;
}

- (void)tryGameRestarted{
    if (self.isPalying) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"尝试重试", nil) message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *enter = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self gameRestarted];
        }];
        [alertController addAction:cancel];
        [alertController addAction:enter];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else {
        [self gameRestarted];
    }
}

- (void)gameRestarted {
    
    self.isPalying = NO;
    
    [self addInterstitial];

    self.numberOfLeiExist = self.numberOfLei;
    
    self.timeInterval = 0;
    
    self.saoleiView.userInteractionEnabled = YES;
    
    self.firstClick = YES;
    
    self.clickKind = SaoleiUserClickKindNormal;
    
    self.headerView.restartKind = RestartKindNormal;
    
    [self changeClickKindWithButton:_footerView.normalButton];
    
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
        
        self.isPalying = YES;

        _firstClick = !_firstClick;
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
                    NSString *string = [NSString stringWithFormat:@"tile_0_%ld~hd.png",(long)sender.numberOfLei];
                    
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
    if (realNumber == self.numberOfLei || self.numberOfLeiExist == 0) {
        [self winGame];
    }
}

- (void)winGame {
    self.isPalying = NO;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"9714" ofType:@"mp3"];
    [self playMusic:[NSURL fileURLWithPath:path] volume:1];
    
    self.headerView.restartKind = RestartKindWin;
    
    self.saoleiView.userInteractionEnabled = NO;
    
    [self timerEnd];
    
    NSString *message = nil;
    
    NSString *difficulty = self.difficultyArray[self.difficulty];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"恭喜大侠", nil) message:nil preferredStyle:(UIAlertControllerStyleAlert)];
    
    NSArray *array = [[SaveHandle shareSaveHandle]findModelWithDifficulty:self.difficulty];
    
    if (array.count < 5 || (array.count >= 5 && ((UserModel *)array.lastObject).costTime > self.timeInterval)) {
        message = [NSString stringWithFormat:NSLocalizedString(@"SuccessTip", nil),difficulty,self.timeInterval];
        
        UserModel *model = array.lastObject;
    
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = NSLocalizedString(@"请输入大侠的昵称", nil);
            textField.text = self.userName;
        }];
        
        __weak SaoleiViewController *weakSelf = self;
        
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            NSString *userName = alert.textFields.firstObject.text;
            
            [[NSUserDefaults standardUserDefaults] setObject:userName forKey:@"userName"];
            
            if (userName.length == 0) {
                userName = NSLocalizedString(@"默认", nil);
            }
            if (array.count >= 5) {
                [[SaveHandle shareSaveHandle] deleteWithID:model.id_vierfy];
            }
            
            self.randomNum = arc4random()%10000 + 1;
            
            [[SaveHandle shareSaveHandle] saveWithUsrName:userName andUserTime:weakSelf.timeInterval andDifficulty:weakSelf.difficulty RandomNum:self.randomNum];
        }]];
        
    }else {
        message = [NSString stringWithFormat:NSLocalizedString(@"SuccessTip1", nil),difficulty,self.timeInterval];
        
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:(UIAlertActionStyleDefault) handler:nil]];
    }
    
    alert.message = message;
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)loseGame {
    self.isPalying = NO;

    NSString *path = [[NSBundle mainBundle] pathForResource:@"1554" ofType:@"mp3"];
    [self playMusic:[NSURL fileURLWithPath:path] volume:0.5];
    
    self.headerView.restartKind = RestartKindLose;
    
    [self.saoleiView showAll];
    
    self.saoleiView.userInteractionEnabled = NO;
    
    [self timerEnd];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"FailTip", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *againAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"再玩一局", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self gameRestarted];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:againAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
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

- (void)setNumberOfLei:(NSInteger)numberOfLei {
    _numberOfLei = numberOfLei;
    
    self.numberOfLeiExist = numberOfLei;
}

- (void)setDifficulty:(KindOfUserDifficulty)difficulty {
    _difficulty = difficulty;
    
    [[NSUserDefaults standardUserDefaults] setObject:@(difficulty) forKey:@"difficulty"];
    
    switch (difficulty) {
        case KindOfUserDifficultySuperEasy:{
            self.saoleiView.numberOfChessInLine = 6;
            self.saoleiView.numberOfChessInList = 6;
            self.numberOfLei = 5;
            self.title = NSLocalizedString(@"儿童难度", nil);
            
            break;
        }
            
        case KindOfUserDifficultyEasy:{
            self.saoleiView.numberOfChessInLine = 9;
            self.saoleiView.numberOfChessInList = 9;
            self.numberOfLei = 10;
            self.title = NSLocalizedString(@"简单难度", nil);
            
            break;
        }
            
        case KindOfUserDifficultyNormal:{
            self.saoleiView.numberOfChessInLine = 16;
            self.saoleiView.numberOfChessInList = 16;
            self.numberOfLei = 40;
            self.title = NSLocalizedString(@"中等难度", nil);
            
            break;
        }
       
        case KindOfUserDifficultyHard:{
            self.saoleiView.numberOfChessInLine = 20;
            self.saoleiView.numberOfChessInList = 20;
            self.numberOfLei = 70;
            self.title = NSLocalizedString(@"困难难度", nil);
            
            break;
        }
            
        case KindOfUserDifficultyVeryHard:{
            self.saoleiView.numberOfChessInLine = 30;
            self.saoleiView.numberOfChessInList = 30;
            self.numberOfLei = 100;
            self.title = NSLocalizedString(@"梦魇难度", nil);
            
            break;
        }
    }
    [self.saoleiView resetView];
}
#pragma mark -

- (void)playMusic:(NSURL *)url volume:(CGFloat)volume{
    NSError *error = nil;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    self.player = player;
    player.volume = volume;
    [player prepareToPlay];
    [player  play];
    
//    SystemSoundID soundID = 0;
//
//    CFURLRef urlRef = (__bridge CFURLRef)(url);
//    AudioServicesCreateSystemSoundID(urlRef, &soundID);
    
    // 播放音效
    // AudioServicesPlaySystemSound(soundID);
    
    //有震动效果
//    AudioServicesPlayAlertSound(self.soundID);
}


#pragma mark -

+ (NSString*)getPreferredLanguage
{
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString* preferredLang = [languages objectAtIndex:0];
    NSLog(@"Preferred Language:%@", preferredLang);
    return preferredLang;
}

#pragma mark - Banner

/*Indicates that the banner has received an ad. */
- (void)bannerDidFinishLoading:(IMBanner *)banner {
    NSLog(@"bannerDidFinishLoading");
}
/* Indicates that the banner has failed to receive an ad */
- (void)banner:(IMBanner *)banner didFailToLoadWithError:(IMRequestStatus *)error {
    NSLog(@"banner failed to load ad");
    NSLog(@"Error : %@", error.description);
}
/* Indicates that the banner is going to present a screen. */
- (void)bannerWillPresentScreen:(IMBanner *)banner {
    NSLog(@"bannerWillPresentScreen");
}
/* Indicates that the banner has presented a screen. */
- (void)bannerDidPresentScreen:(IMBanner *)banner {
    NSLog(@"bannerDidPresentScreen");
}
/* Indicates that the banner is going to dismiss the presented screen. */
- (void)bannerWillDismissScreen:(IMBanner *)banner {
    NSLog(@"bannerWillDismissScreen");
}
/* Indicates that the banner has dismissed a screen. */
- (void)bannerDidDismissScreen:(IMBanner *)banner {
    NSLog(@"bannerDidDismissScreen");
}
/* Indicates that the user will leave the app. */
- (void)userWillLeaveApplicationFromBanner:(IMBanner *)banner {
    NSLog(@"userWillLeaveApplicationFromBanner");
}
/*  Indicates that the banner was interacted with. */
-(void)banner:(IMBanner *)banner didInteractWithParams:(NSDictionary *)params{
    NSLog(@"bannerdidInteractWithParams");
}
/*Indicates that the user has completed the action to be incentivised with .*/
-(void)banner:(IMBanner*)banner rewardActionCompletedWithRewards:(NSDictionary*)rewards{
    NSLog(@"rewardActionCompletedWithRewards");
}

#pragma mark - Interstitial

/*Indicates that the interstitial is ready to be shown */
- (void)interstitialDidFinishLoading:(IMInterstitial *)interstitial {
    NSLog(@"interstitialDidFinishLoading");
}
/* Indicates that the interstitial has failed to receive an ad. */
- (void)interstitial:(IMInterstitial *)interstitial didFailToLoadWithError:(IMRequestStatus *)error {
    NSLog(@"Interstitial failed to load ad");
    NSLog(@"Error : %@",error.description);
}
/* Indicates that the interstitial has failed to present itself. */
- (void)interstitial:(IMInterstitial *)interstitial didFailToPresentWithError:(IMRequestStatus *)error {
    NSLog(@"Interstitial didFailToPresentWithError");
    NSLog(@"Error : %@",error.description);
}
/* indicates that the interstitial is going to present itself. */
- (void)interstitialWillPresent:(IMInterstitial *)interstitial {
    NSLog(@"interstitialWillPresent");
}
/* Indicates that the interstitial has presented itself */
- (void)interstitialDidPresent:(IMInterstitial *)interstitial {
    NSLog(@"interstitialDidPresent");
}
/* Indicates that the interstitial is going to dismiss itself. */
- (void)interstitialWillDismiss:(IMInterstitial *)interstitial {
    NSLog(@"interstitialWillDismiss");
}
/* Indicates that the interstitial has dismissed itself. */
- (void)interstitialDidDismiss:(IMInterstitial *)interstitial {
    NSLog(@"interstitialDidDismiss");
}
/* Indicates that the user will leave the app. */
- (void)userWillLeaveApplicationFromInterstitial:(IMInterstitial *)interstitial {
    NSLog(@"userWillLeaveApplicationFromInterstitial");
}
/* interstitial:didInteractWithParams: Indicates that the interstitial was interacted with. */
- (void)interstitial:(IMInterstitial *)interstitial didInteractWithParams:(NSDictionary *)params {
    NSLog(@"InterstitialDidInteractWithParams");
}
/* Not used for direct integration. Notifies the delegate that the ad server has returned an ad but assets are not yet available. */
- (void)interstitialDidReceiveAd:(IMInterstitial *)interstitial {
    NSLog(@"interstitialDidReceiveAd");
}

@end
