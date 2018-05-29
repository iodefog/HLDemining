//
//  UserModel.h
//  text
//
//  Created by hanlu on 16/8/4.
//  Copyright © 2016年 LHL. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,KindOfUserDifficulty) {
    KindOfUserDifficultySuperEasy, // 超级容易
    KindOfUserDifficultyEasy, // 容易
    KindOfUserDifficultyNormal, // 正常
    KindOfUserDifficultyHard, // 难
    KindOfUserDifficultyVeryHard, // 梦魇
};

@interface UserModel : NSObject

@property (nonatomic,strong) NSString *name;

@property (nonatomic,assign) NSInteger costTime;

@property (nonatomic,assign) NSString *datetime;

@property (nonatomic,assign) NSInteger id_vierfy;

@property (nonatomic,assign) NSInteger randomNum;

@property (nonatomic,assign) KindOfUserDifficulty difficulty;

+ (UserModel *)modelWithName:(NSString *)name costTime:(NSInteger)costTime ID:(NSInteger)ID Difficulty:(KindOfUserDifficulty)difficulty RandomNum:(NSInteger)randomNum;

@end
