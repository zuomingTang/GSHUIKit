//
//  GSHAutomateVC.m
//  SmartHome
//
//  Created by gemdale on 2018/4/8.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHAutomateVC.h"
#import "GSHAutomateCell.h"

#import "GSHAddAutoVC.h"

#import "UIViewController+TZMPageStatusViewEx.h"
#import "UIView+TZMPageStatusViewEx.h"
#import <MJRefresh/MJRefresh.h>
#import "GSHAlertManager.h"
#import "JXMovableCellTableView.h"
#import "NSObject+TZM.h"

@interface GSHAutomateVC ()
<MGSwipeTableCellDelegate,
JXMovableCellTableViewDelegate,
JXMovableCellTableViewDataSource>

@property (nonatomic , strong) JXMovableCellTableView *automateTableView;

@property (nonatomic, strong) NSMutableArray *autoSourceArray;

@property (nonatomic, strong) GSHAutoM *tmpAutoM;

@property (nonatomic , assign) int currPage;

@end

@implementation GSHAutomateVC

#pragma mark - life circle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.automateTableView setBackgroundColor:[UIColor colorWithHexString:@"#F6F7FA"]];
    
    [self createNavigationButton]; // 创建 导航栏 按钮
    
    self.currPage = 1;
    [self getAutoListWithCurrPage:self.currPage]; // 获取联动列表
    
    [self observerNotifications];
}

-(void)observerNotifications{
    [self observerNotification:GSHOpenSDKFamilyChangeNotification];
}

-(void)handleNotifications:(NSNotification *)notification{
    if ([notification.name isEqualToString:GSHOpenSDKFamilyChangeNotification]) {
        GSHFamilyM *family = notification.object;
        if ([family isKindOfClass:GSHFamilyM.class]) {
            [self getAutoListWithCurrPage:1];
        }
    }
}

-(void)dealloc{
    [self removeNotifications];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI
- (void)createNavigationButton {
    // 添加
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:self action:@selector(addAutoButtonClick:)];
    [self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:@"sense_icon_add_normal"]];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
}

#pragma mark - Lazy

- (NSMutableArray *)autoSourceArray {
    if (!_autoSourceArray) {
        _autoSourceArray = [NSMutableArray array];
    }
    return _autoSourceArray;
}

- (UITableView *)automateTableView {
    if (!_automateTableView) {
        _automateTableView = [[JXMovableCellTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - KTabBarHeight - KNavigationBar_Height) style:UITableViewStyleGrouped];
        _automateTableView.dataSource = self;
        _automateTableView.delegate = self;
        _automateTableView.sectionHeaderHeight = 10;
        _automateTableView.sectionFooterHeight = 0;
        [_automateTableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)]];
        [_automateTableView registerNib:[UINib nibWithNibName:@"GSHAutomateCell" bundle:nil] forCellReuseIdentifier:@"automateCell"];
        _automateTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_automateTableView];
        
        @weakify(self)
        _automateTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            @strongify(self)
            self.currPage = 1;
            [self getAutoListWithCurrPage:self.currPage];
            [self.automateTableView.mj_header endRefreshing];
        }];
        
        _automateTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            @strongify(self)
            self.currPage++;
            [self getAutoListWithCurrPage:self.currPage];
            [self.automateTableView.mj_footer endRefreshing];
        }];
    }
    return _automateTableView;
}

- (GSHAutoM *)tmpAutoM {
    if (!_tmpAutoM) {
        _tmpAutoM = [[GSHAutoM alloc] init];
    }
    return _tmpAutoM;
}

#pragma mark - method
// 添加联动按钮点击
- (void)addAutoButtonClick:(UIButton *)button {
    
    if ([GSHOpenSDK share].currentFamily.familyId.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请先创建家庭"];
        return ;
    }
    GSHAddAutoVC *addAutoVC = [GSHAddAutoVC addAutoVC];
    addAutoVC.hidesBottomBarWhenPushed = YES;
    @weakify(self)
    addAutoVC.addAutoSuccessBlock = ^(GSHOssAutoM *ossAutoM) {
        @strongify(self)
        [self.autoSourceArray insertObject:ossAutoM atIndex:0];
        if (self.autoSourceArray.count > 0) {
            [self dismissPageStatusView];
            [self.automateTableView reloadData];
        }
    };
    [self.navigationController pushViewController:addAutoVC animated:YES];
}

// 无联动时 -- 显示空白页面
- (void)showBlankView {
    NSString *desc = [GSHOpenSDK share].currentFamily.permissions == GSHFamilyMPermissionsManager ? @"点击右上方\"+\"按钮，添加联动" : @"";
    @weakify(self)
    [self showPageStatus:TZMPageStatusNormal
                   image:[UIImage imageNamed:@"blankpage_icon_homeautomation"]
                   title:@"家庭下尚未添加联动"
                    desc:desc
              buttonText:@"刷新"
  didClickButtonCallback:^(TZMPageStatus status) {
      @strongify(self)
      [self getAutoListWithCurrPage:self.currPage];
  }];
}

- (void)hideBlankView {
    [self dismissPageStatusView];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.autoSourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 130.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHAutomateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"automateCell" forIndexPath:indexPath];
    if (self.autoSourceArray.count > indexPath.row) {
        __block GSHOssAutoM *ossAutoM = self.autoSourceArray[indexPath.row];
        cell.backgroundColor = [UIColor clearColor];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.delegate = self;
        if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeWAN) {
            cell.rightButtons = [self createRightButtons:2 rowIndex:(int)indexPath.row];
        } else {
            cell.rightButtons = @[];
        }
        [cell setAutoCellValueWithOssAutoM:ossAutoM];
        @weakify(self)
        __weak typeof(ossAutoM) weakOssAutoM = ossAutoM;
        cell.openSwitchClickBlock = ^(UISwitch *openSwitch) {
            @strongify(self)
            __strong typeof(weakOssAutoM) strongOssAutoM = weakOssAutoM;
            [self updateAutoWithSwitch:openSwitch ossAutoM:strongOssAutoM];
        };
    }
    return cell;
}

- (NSMutableArray *)dataSourceArrayInTableView:(JXMovableCellTableView *)tableView {
    return @[self.autoSourceArray].mutableCopy;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - UITableViewDelegate

- (NSArray *)createRightButtons:(int)number rowIndex:(int)rowIndex {
    
    GSHOssAutoM *ossAutoM = self.autoSourceArray[rowIndex];
    @weakify(self)
    __weak typeof(ossAutoM) weakOssAutoM = ossAutoM;
    MGSwipeButton *editButton = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"intelligent_icon_edit"] backgroundColor:[UIColor clearColor] callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
        @strongify(self)
        __strong typeof(weakOssAutoM) strongOssAutoM = weakOssAutoM;
        NSString *json = [[GSHFileManager shared] readDataWithFileType:LocalStoreFileTypeAuto fileName:strongOssAutoM.fid];
        NSLog(@"===========本地取得的json : %@",json);
        if (json) {
            // 编辑 本地有文件
            NSString *md5 = [json md5String];
            if (![md5 isEqualToString:strongOssAutoM.md5]) {
                // md5 改变，需要重新从服务器请求数据，更新到本地
                [self getFileFromSeverWithFid:strongOssAutoM.fid ossAutoM:strongOssAutoM rowIndex:rowIndex];
            } else {
                [self editButtonClickWithJson:json ossAutoM:strongOssAutoM rowIndex:rowIndex];
            }
        } else {
            [self getFileFromSeverWithFid:strongOssAutoM.fid ossAutoM:strongOssAutoM rowIndex:rowIndex];
        }
        return YES;
    }];
    
    MGSwipeButton *deleteButton = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"intelligent_icon_delete"] backgroundColor:[UIColor clearColor] callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
        // 删除
        @strongify(self)
        @weakify(self)
        [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
            __strong typeof(weakOssAutoM) strongOssAutoM = weakOssAutoM;
            if (buttonIndex == 0) {
                @strongify(self)
                [self deleteAutoWithAutoId:strongOssAutoM.ruleId.stringValue index:rowIndex];
            }
        } textFieldsSetupHandler:NULL andTitle:nil andMessage:@"确认要删除该联动吗？" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:@"删除" cancelButtonTitle:nil otherButtonTitles:@"取消",nil];
        return YES;
    }];
    return @[deleteButton,editButton];
}

- (void)editButtonClickWithJson:(NSString *)json ossAutoM:(GSHOssAutoM *)ossAutoM rowIndex:(int)rowIndex {
    self.tmpAutoM = [GSHAutoM yy_modelWithJSON:json];
    NSMutableArray *deviceIdArr = [NSMutableArray array];
    for (GSHAutoTriggerConditionListM *conditionListM in self.tmpAutoM.trigger.conditionList) {
        if (conditionListM.device) {
            [deviceIdArr addObject:conditionListM.device.deviceId];
        }
    }
    NSMutableArray *tmpDeviceIdArr = [NSMutableArray array];
    NSMutableArray *tmpSceneArr = [NSMutableArray array];
    NSMutableArray *tmpAutoArr = [NSMutableArray array];
    for (GSHAutoActionListM *actionListM in self.tmpAutoM.actionList) {
        if (actionListM.device && ![deviceIdArr containsObject:actionListM.device.deviceId]) {
            [tmpDeviceIdArr addObject:actionListM.device.deviceId];
        }
        if (actionListM.businessId) {
            [tmpSceneArr addObject:actionListM.businessId];
        }
        if (actionListM.ruleId) {
            [tmpAutoArr addObject:actionListM.ruleId];
        }
    }
    [deviceIdArr addObjectsFromArray:tmpDeviceIdArr];
    
    @weakify(self)
    __weak typeof(ossAutoM) weakOssAutoM = ossAutoM;
    [SVProgressHUD showWithStatus:@"数据校验中"];
    [GSHAutoManager checkDevicesFromServerWithDeviceIdArray:deviceIdArr sceneArray:tmpSceneArr autoArray:tmpAutoArr familyId:[GSHOpenSDK share].currentFamily.familyId block:^(NSArray <GSHNameIdM*> *deviceArr,NSArray <GSHNameIdM*> *sceneArr,NSArray <GSHNameIdM*> *autoArr, NSError *error) {
        @strongify(self)
        __strong typeof(weakOssAutoM) strongOssAutoM = weakOssAutoM;
        [SVProgressHUD dismiss];
        if (!error) {
            NSMutableArray *notInDeviceArray = [NSMutableArray array];
            BOOL isAlert = NO;
            for (GSHAutoTriggerConditionListM *conditionListM in self.tmpAutoM.trigger.conditionList) {
                if (conditionListM.device) {
                    BOOL isIn = NO;
                    for (GSHNameIdM *tmpNameIdM in deviceArr) {
                        if ([conditionListM.device.deviceId isEqual:tmpNameIdM.idStr]) {
                            isIn = YES;
                            if (![conditionListM.device.deviceName isEqualToString:tmpNameIdM.nameStr]) {
                                conditionListM.device.deviceName = tmpNameIdM.nameStr;
                                isAlert = YES;
                            }
                        }
                    }
                    if (!isIn) {
                        [notInDeviceArray addObject:conditionListM];
                    }
                }
            }
            if (notInDeviceArray.count > 0) {
                [self.tmpAutoM.trigger.conditionList removeObjectsInArray:notInDeviceArray];
                isAlert = YES;
            }
            NSMutableArray *notInDeviceActionArray = [NSMutableArray array];
            NSMutableArray *notInSceneActionArray = [NSMutableArray array];
            NSMutableArray *notInAutoActionArray = [NSMutableArray array];
            for (GSHAutoActionListM *actionListM in self.tmpAutoM.actionList) {
                if (actionListM.device) {
                    BOOL isIn = NO;
                    for (GSHNameIdM *tmpNameIdM in deviceArr) {
                        if ([actionListM.device.deviceId isEqual:tmpNameIdM.idStr]) {
                            isIn = YES;
                            if (![actionListM.device.deviceName isEqualToString:tmpNameIdM.nameStr]) {
                                actionListM.device.deviceName = tmpNameIdM.nameStr;
                                isAlert = YES;
                            }
                        }
                    }
                    if (!isIn) {
                        [notInDeviceActionArray addObject:actionListM];
                    }
                }
                if (actionListM.businessId) {
                    BOOL isIn = NO;
                    for (GSHNameIdM *tmpNameIdM in sceneArr) {
                        if ([actionListM.businessId isEqual:tmpNameIdM.idStr]) {
                            isIn = YES;
                            if (![actionListM.scenarioName isEqualToString:tmpNameIdM.nameStr]) {
                                actionListM.scenarioName = tmpNameIdM.nameStr;
                                isAlert = YES;
                            }
                        }
                    }
                    if (!isIn) {
                        [notInSceneActionArray addObject:actionListM];
                    }
                }
                if (actionListM.ruleId) {
                    BOOL isIn = NO;
                    for (GSHNameIdM *tmpNameIdM in autoArr) {
                        if ([actionListM.ruleId isEqual:tmpNameIdM.idStr]) {
                            isIn = YES;
                            if (![actionListM.ruleName isEqualToString:tmpNameIdM.nameStr]) {
                                actionListM.ruleName = tmpNameIdM.nameStr;
                                isAlert = YES;
                            }
                        }
                    }
                    if (!isIn) {
                        [notInAutoActionArray addObject:actionListM];
                    }
                }
            }
            if (notInDeviceActionArray.count > 0) {
                [self.tmpAutoM.actionList removeObjectsInArray:notInDeviceActionArray];
                isAlert = YES;
            }
            if (notInSceneActionArray.count > 0) {
                [self.tmpAutoM.actionList removeObjectsInArray:notInSceneActionArray];
                isAlert = YES;
            }
            if (notInAutoActionArray.count > 0) {
                [self.tmpAutoM.actionList removeObjectsInArray:notInAutoActionArray];
                isAlert = YES;
            }
            [self jumpToAutoEditVCWithAutoM:self.tmpAutoM ossAutoM:strongOssAutoM rowIndex:rowIndex isAlert:isAlert];
        } else {
            [self jumpToAutoEditVCWithAutoM:self.tmpAutoM ossAutoM:strongOssAutoM rowIndex:rowIndex isAlert:NO];
        }
    }];
}

- (void)jumpToAutoEditVCWithAutoM:(GSHAutoM *)autoM ossAutoM:(GSHOssAutoM *)ossAutoM rowIndex:(int)rowIndex isAlert:(BOOL)isAlert {
    GSHAddAutoVC *addAutoVC = [GSHAddAutoVC addAutoVC];
    addAutoVC.autoM = [autoM yy_modelCopy];
    addAutoVC.ossAutoM = ossAutoM;
    addAutoVC.isEditType = YES;
    addAutoVC.isAlertToNotiUser = isAlert;
    @weakify(self)
    addAutoVC.updateAutoSuccessBlock = ^(GSHOssAutoM *ossAutoM) {
        @strongify(self)
        if (self.autoSourceArray.count > rowIndex) {
            [self.autoSourceArray removeObjectAtIndex:rowIndex];
        }
        [self.autoSourceArray insertObject:ossAutoM atIndex:rowIndex];
        [self.automateTableView reloadData];
    };
    [self.navigationController pushViewController:addAutoVC animated:YES];
}

#pragma mark - request

// 获取联动列表
- (void)getAutoListWithCurrPage:(int)currPage {
    
    self.navigationItem.rightBarButtonItem.enabled = YES; // [GSHOpenSDK share].currentFamily.permissions == GSHFamilyMPermissionsManager ? YES : NO;
    
    if ([GSHOpenSDK share].currentFamily.familyId.length == 0) {
        [self showBlankView];
        return;
    }
    if (self == [UIViewController visibleTopViewController]) {
        [SVProgressHUD showWithStatus:@"请求中"];
    }
    
    [GSHAutoManager getAutoListWithFamilyId:[GSHOpenSDK share].currentFamily.familyId currPage:[NSString stringWithFormat:@"%d",currPage]  block:^(NSArray<GSHOssAutoM *> *list, NSError *error) {
        
        [SVProgressHUD dismiss];
        if (error) {
            [self.view showPageStatus:TZMPageStatusNormal image:[UIImage imageNamed:@"blankpage_icon_network"] title:nil desc:error.localizedDescription buttonText:@"刷新" didClickButtonCallback:^(TZMPageStatus status) {
                [self getAutoListWithCurrPage:self.currPage];
            }];
        } else {
            if (self.currPage == 1 && self.autoSourceArray.count > 0) {
                [self.autoSourceArray removeAllObjects];
            }
            if (list.count < 12) {
                self.automateTableView.mj_footer.state = MJRefreshStateNoMoreData;
                self.automateTableView.mj_footer.hidden = YES;
            } else {
                self.automateTableView.mj_footer.state = MJRefreshStateIdle;
                self.automateTableView.mj_footer.hidden = NO;
            }
            [self.autoSourceArray addObjectsFromArray:list];
            [SVProgressHUD dismiss];
            if (self.autoSourceArray.count == 0) {
                [self showBlankView];
            } else {
                [self hideBlankView];
                [self.automateTableView reloadData];
            }
            if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
                self.navigationItem.rightBarButtonItem.enabled = NO;
            }
        }
    }];
}

- (void)updateAutoWithSwitch:(UISwitch *)openSwitch ossAutoM:(GSHOssAutoM *)ossAutoM {
    
    NSString *status = [NSString stringWithFormat:@"%d",openSwitch.on];
    __weak typeof(ossAutoM) weakOssAutoM = ossAutoM;
    [SVProgressHUD showWithStatus:@"操作中"];
    [GSHAutoManager updateAutoSwitchWithRuleId:ossAutoM.ruleId.stringValue status:status familyId:[GSHOpenSDK share].currentFamily.familyId block:^(NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            openSwitch.on = !openSwitch.on;
        } else {
            __strong typeof(weakOssAutoM) strongOssAutoM = weakOssAutoM;
            [SVProgressHUD showSuccessWithStatus:@"操作成功"];
            openSwitch.on = [status intValue];
            strongOssAutoM.status = @(openSwitch.on);
        }
    }];
    
}

// 删除联动
- (void)deleteAutoWithAutoId:(NSString *)autoId index:(int)index {
    
    [SVProgressHUD showWithStatus:@"删除中"];
    GSHOssAutoM *ossAutoM = self.autoSourceArray[index];
    @weakify(self)
    [GSHAutoManager deleteAutoWithOssAutoM:ossAutoM familyId:[GSHOpenSDK share].currentFamily.familyId block:^(NSError *error) {
        @strongify(self)
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        } else {
            [SVProgressHUD showSuccessWithStatus:@"删除成功"];
            if (self.autoSourceArray.count > index) {
                [self.autoSourceArray removeObjectAtIndex:index];
                [self.automateTableView reloadData];
                if (self.autoSourceArray.count == 0) {
                    [self showBlankView];
                }
            }
        }
    }];
}

- (void)getFileFromSeverWithFid:(NSString *)fid ossAutoM:(GSHOssAutoM *)ossAutoM rowIndex:(int)rowIndex {
    if (fid.length == 0) {
        return;
    }
    [SVProgressHUD showWithStatus:@"获取文件数据中"];
    @weakify(self)
    [GSHAutoManager getAutoFileFromOssWithFid:fid block:^(NSString *json, NSError *error) {
        @strongify(self)
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        } else {
            [SVProgressHUD dismiss];
            [self editButtonClickWithJson:json ossAutoM:ossAutoM rowIndex:rowIndex];
        }
    }];
}

@end
