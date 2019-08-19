//
//  GSHChooseRepeatCountVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/6/1.
//  Copyright © 2018年 gemdale. All rights reserved.
//

/*
 重复页面中，如果只选择一项，显示执行一次；
 如果选择周六和周日，显示：周末执行
 如果选择一周所有工作日，显示工作日执行；
 选择一周所有天数，显示：每天执行；
 如果选择工作日中的某几天，或者选择所有工作日加上周末某一天，或者选择周末加上工作日某几天，则显示：所有被选中的天；

 */

#import "GSHChooseRepeatCountVC.h"

@interface GSHChooseRepeatCountVC ()

@property (nonatomic , strong) NSArray *cellTypeNameArray;
@property (nonatomic , strong) NSMutableIndexSet *repeatCountIndexSet;

@end

@implementation GSHChooseRepeatCountVC

+ (instancetype)chooseRepeatCountVC {
    GSHChooseRepeatCountVC *vc = [TZMPageManager viewControllerWithSB:@"GSHAddAutomationSB" andID:@"GSHChooseRepeatCountVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cellTypeNameArray = @[@"每周一",@"每周二",@"每周三",@"每周四",@"每周五",@"每周六",@"每周日"];

    if (self.choosedIndexSet.count > 0) {
        [self.repeatCountIndexSet addIndexes:self.choosedIndexSet];
    }
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    [self createNavigationButton]; // 创建 确定 按钮
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Lazy
- (NSMutableIndexSet *)repeatCountIndexSet {
    if (!_repeatCountIndexSet) {
        _repeatCountIndexSet = [NSMutableIndexSet indexSet];
    }
    return _repeatCountIndexSet;
}

#pragma mark - UI
- (void)createNavigationButton {
    // 添加
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(sureButtonClick:)];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GSHChooseRepeatCountCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chooseRepeatCountCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.cellNameLabel.text = self.cellTypeNameArray[indexPath.row];
    cell.checkButton.selected = [self.choosedIndexSet containsIndex:indexPath.row];
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHChooseRepeatCountCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.checkButton.selected = !cell.checkButton.selected;
    if (cell.checkButton.selected) {
        // 选中
        [self.repeatCountIndexSet addIndex:indexPath.row];
    } else {
        // 取消选中
        [self.repeatCountIndexSet removeIndex:indexPath.row];
    }
}

#pragma mark - method
- (void)sureButtonClick:(UIButton *)button {
    
//    if (self.repeatCountIndexSet.count == 0) {
//        [SVProgressHUD showErrorWithStatus:@"请选择一项"];
//        return;
//    }
    NSString *showRepeatStr = [self showRepeatCountStringWithIndexSet:self.repeatCountIndexSet];
    if (self.chooseRepeatCountBlock) {
        self.chooseRepeatCountBlock(self.repeatCountIndexSet,showRepeatStr);
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (NSString *)showRepeatCountStringWithIndexSet:(NSIndexSet *)indexSet {
    __block NSMutableString *showStr = [NSMutableString stringWithFormat:@""];
    if (indexSet.count == 7) {
        [showStr appendString:@"每天执行"];
    } else if (indexSet.count == 2 && [indexSet containsIndex:5] && [indexSet containsIndex:6]){
        [showStr appendString:@"周末执行"];
    } else if (indexSet.count == 5 && ![indexSet containsIndex:5] && ![indexSet containsIndex:6]) {
        [showStr appendString:@"工作日执行"];
    } else if (indexSet.count == 0) {
        [showStr appendString:@"仅一次"];
    } else {
        [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == 0) {
                [showStr appendString:@"周一、"];
            } else if (idx == 1) {
                [showStr appendString:@"周二、"];
            } else if (idx == 2) {
                [showStr appendString:@"周三、"];
            } else if (idx == 3) {
                [showStr appendString:@"周四、"];
            } else if (idx == 4) {
                [showStr appendString:@"周五、"];
            } else if (idx == 5) {
                [showStr appendString:@"周六、"];
            } else if (idx == 6) {
                [showStr appendString:@"周日、"];
            }
        }];
        showStr = [[showStr substringToIndex:(showStr.length - 1)] mutableCopy];
    }
    return showStr;
}

@end

@implementation GSHChooseRepeatCountCell

@end
