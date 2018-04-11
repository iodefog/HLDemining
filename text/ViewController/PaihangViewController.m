//
//  PaihangViewController.m
//  text
//
//  Created by hanlu on 16/8/4.
//  Copyright © 2016年 吴迪. All rights reserved.
//

#import "PaihangViewController.h"
#import "PaihangTableViewCell.h"
#import "SaveHandle.h"

@interface PaihangViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) UILabel *emptyLabel;

@property (nonatomic,strong) NSArray *dataArray;


@end

@implementation PaihangViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView = ({
        UITableView *table = [[UITableView alloc] initWithFrame:self.view.bounds style:(UITableViewStylePlain)];
        table.estimatedRowHeight = 54;
        table.estimatedSectionHeaderHeight = 0;
        table.estimatedSectionFooterHeight = 0;
        table.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);

        table.delegate = self;
        
        table.dataSource = self;
        
        [table registerNib:[UINib nibWithNibName:@"PaihangTableViewCell" bundle:nil] forCellReuseIdentifier:@"cellID"];
        
        table;
    });
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self.view addSubview:_tableView];
}


- (NSArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[SaveHandle shareSaveHandle] findModelWithDifficulty:_difficulty];
    }
    return _dataArray;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PaihangTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
    
    cell.model = _dataArray[indexPath.row];
    
    if (cell.model.randomNum == self.randomNum) {
        cell.backgroundColor = [UIColor yellowColor];
    }else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    cell.ranking = indexPath.row + 1;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataArray.count == 0) {
        [self showEmptyLabel];
    }
    else {
        [self hiddenEmptyLabel];
    }
    return self.dataArray.count;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -

- (void)showEmptyLabel{
    if (!_emptyLabel) {
        _emptyLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
        _emptyLabel.textColor = [UIColor grayColor];
        _emptyLabel.text = @"暂无数据";
    }
    
    [self.view addSubview:_emptyLabel];
}

- (void)hiddenEmptyLabel{
    [_emptyLabel removeFromSuperview];
}

@end
