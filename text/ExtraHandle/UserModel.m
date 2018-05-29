//
//  UserModel.m
//  text
//
//  Created by hanlu on 16/8/4.
//  Copyright © 2016年 LHL. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

- (instancetype)initWithName:(NSString *)name costTime:(NSInteger)costTime ID:(NSInteger)ID Difficulty:(KindOfUserDifficulty)difficulty RandomNum:(NSInteger)randomNum{
    self = [super init];
    if (self) {
        _name = name;
        
        _costTime = costTime;
        
        _id_vierfy = ID;
        
        _difficulty = difficulty;
        
        _randomNum = randomNum;
    }
    return self;
}

+ (UserModel *)modelWithName:(NSString *)name costTime:(NSInteger)costTime ID:(NSInteger)ID Difficulty:(KindOfUserDifficulty)difficulty RandomNum:(NSInteger)randomNum{
    return [[super alloc] initWithName:name costTime:costTime ID:ID Difficulty:difficulty RandomNum:randomNum];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"name:%@,time:%ld,difficulty:%ld",self.name,self.costTime,self.difficulty];
}

@end
