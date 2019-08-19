//
//  GSHAutoAddAutoVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/6/14.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHAutoAddAutoVC.h"
#import "GSHAddAutoVC.h"


@interface GSHAutoAddAutoVC ()

@property (nonatomic , strong) NSMutableArray *autoListArray;
@property (nonatomic , strong) NSMutableArray *choosedArray;
@property (nonatomic , strong) NSMutableArray *noChoosedArray;
@property (nonatomic , strong) NSMutableDictionary *selectDic;

@end

@implementation GSHAutoAddAutoVC

+ (instancetype)autoAddAutoVC {
    GSHAutoAddAutoVC *vc = [TZMPageManager viewControllerWithSB:@"GSHAddAutoAction" andID:@"GSHAutoAddAutoVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self createNavigationButton]; // 创建 保存 按钮
    
    [self getAutoList]; // 获取联动列表
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI
- (void)createNavigationButton {
    // 保存
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(SCREEN_WIDTH - 44, 0, 44, 44);
    rightButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [rightButton setTitleColor:[UIColor colorWithHexString:@"#4C90F7"] forState:UIControlStateNormal];
    [rightButton setTitle:@"确定" forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(saveButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

#pragma mark - Lazy
- (NSMutableArray *)autoListArray {
    if (!_autoListArray) {
        _autoListArray = [NSMutableArray array];
    }
    return _autoListArray;
}

- (NSMutableArray *)choosedArray {
    if (!_choosedArray) {
        _choosedArray = [NSMutableArray array];
    }
    return _choosedArray;
}

- (NSMutableArray *)noChoosedArray {
    if (!_noChoosedArray) {
        _noChoosedArray = [NSMutableArray array];
    }
    return _noChoosedArray;
}

- (NSMutableDictionary *)selectDic {
    if (!_selectDic) {
        _selectDic = [NSMutableDictionary dictionary];
    }
    return _selectDic;
}

#pragma mark - method
- (void)saveButtonClick:(UIButton *)button {
    for (int i = 0; i < self.autoListArray.count; i ++) {
        GSHOssAutoM *ossAutoM = self.autoListArray[i];
        GSHAutoActionListM *actionListM = [[GSHAutoActionListM alloc] init];
        actionListM.ruleId = ossAutoM.ruleId;
        actionListM.ruleName = ossAutoM.name;
        if ([self.selectDic objectForKey:ossAutoM.ruleId]) {
            if (![self isAddInArrayWithOssAutoM:ossAutoM]) {
                [self.choosedArray addObject:actionListM];
            }
        } else {
            [self.noChoosedArray addObject:actionListM];
        }
    }
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[GSHAddAutoVC class]]) {
            if (self.chooseAutoBlock) {
                self.chooseAutoBlock(self.choosedArray , self.noChoosedArray);
            }
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}

- (BOOL)isAddInArrayWithOssAutoM:(GSHOssAutoM *)ossAutoM {
    BOOL isIn = NO;
    for (GSHAutoActionListM *selectActionListM in self.choosedActionArray) {
        if ([selectActionListM.ruleId isKindOfClass:NSNumber.class]) {
            if ([ossAutoM.ruleId isEqualToNumber:selectActionListM.ruleId]) {
                isIn = YES;
                break;
            }
        }
    }
    return isIn;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.autoListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHAutoAddAutoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"autoAddAutoCell" forIndexPath:indexPath];
    GSHOssAutoM *ossAutoM = self.autoListArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.autoNameLabel.text = ossAutoM.name;
    cell.checkButton.selected = [self.selectDic objectForKey:ossAutoM.ruleId] ? YES : NO;
    //ossAutoM.isSelected;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHAutoAddAutoCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    GSHOssAutoM *ossAutoM = self.autoListArray[indexPath.row];
    cell.checkButton.selected = !cell.checkButton.selected;
//    [ossAutoM setIsSelected:cell.checkButton.selected];
    if (cell.checkButton.selected) {
        // 选中
        [self.selectDic setObject:ossAutoM forKey:ossAutoM.ruleId];
    } else {
        // 取消选中
        if ([self.selectDic objectForKey:ossAutoM.ruleId]) {
            [self.selectDic removeObjectForKey:ossAutoM.ruleId];
        }
    }
    
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH - 30, 20)];
    label.textColor = [UIColor colorWithHexString:@"#999999"];
    label.font = [UIFont systemFontOfSize:14.0];
    label.text = @"请选择要执行的联动";
    [view addSubview:label];
    return view;
}

#pragma mark - request

// 获取联动列表
- (void)getAutoList {
    [SVProgressHUD showWithStatus:@"请求中"];
    [GSHAutoManager getAutoListWithFamilyId:[GSHOpenSDK share].currentFamily.familyId currPage:nil block:^(NSArray<GSHOssAutoM *> *list, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        } else {
            [SVProgressHUD dismiss];
            if (self.autoListArray.count > 0) {
                [self.autoListArray removeAllObjects];
            }
            [self.autoListArray addObjectsFromArray:list];
            if (self.currentAutoId.length > 0 && [self deleteCurrentAutoFromAutoListArray:self.autoListArray]) {
                [self.autoListArray removeObject:[self deleteCurrentAutoFromAutoListArray:self.autoListArray]];
            }
            if (self.choosedActionArray) {
                [self alertAutoIsSelectedWithSelectedArray];
            }
            [self.tableView reloadData];
        }
    }];
}

- (void)alertAutoIsSelectedWithSelectedArray {
    for (GSHAutoActionListM *autoActionListM in self.choosedActionArray) {
        for (GSHOssAutoM *ossAutoM in self.autoListArray) {
            if ([ossAutoM.ruleId isKindOfClass:NSNumber.class]) {
                if ([autoActionListM.ruleId isEqualToNumber:ossAutoM.ruleId]) {
//                    [ossAutoM setIsSelected:YES];
                    [self.selectDic setObject:autoActionListM forKey:autoActionListM.ruleId];
                }
            }
        }
    }
}

// 编辑模式 -- 过滤当前联动
- (GSHOssAutoM *)deleteCurrentAutoFromAutoListArray:(NSArray <GSHOssAutoM *>*)autoListArray {
    GSHOssAutoM *ossAutoM = nil;
    for (int i = 0; i < autoListArray.count; i ++) {
        GSHOssAutoM *tmpOssAutoM = autoListArray[i];
        if ([self.currentAutoId isEqualToString:tmpOssAutoM.ruleId.stringValue]) {
            ossAutoM = tmpOssAutoM;
            break;
        }
    }
    return ossAutoM;
}

@end

@implementation GSHAutoAddAutoCell


@end
