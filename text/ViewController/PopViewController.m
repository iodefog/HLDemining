//
//  PopViewController.m
//  Created by Aotu on 16/4/11.
//  Copyright © 2016年 Aotu. All rights reserved.
//

#import "PopViewController.h"

@interface PopViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableVIew;
    NSArray *_dataArray;
    NSArray *_arr2;
    
    
    
}
@end

@implementation PopViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableVIew = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableVIew.delegate = self;
    _tableVIew.dataSource = self;
    _tableVIew.scrollEnabled = YES;
    _tableVIew.estimatedRowHeight = 54;
    _tableVIew.estimatedSectionHeaderHeight = 0;
    _tableVIew.estimatedSectionFooterHeight = 0;
    _tableVIew.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _tableVIew.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_tableVIew];
    
    
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.difficultyArray.count;
    
}



-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *str = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
    }
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.text = self.difficultyArray[indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate popViewController:self didselectedWith:indexPath.row];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}


@end
