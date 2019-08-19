//
//  GSHChooseSceneListVC.m
//  SmartHome
//
//  Created by zhanghong on 2019/4/10.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHChooseSceneListVC.h"
#import "UIViewController+TZMPageStatusViewEx.h"
#import "UIView+TZMPageStatusViewEx.h"

@interface GSHChooseSceneListVC () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic , strong) NSMutableArray *sourceArray;
@property (nonatomic , strong) GSHOssSceneM *selectOssSceneM;
@property (nonatomic , strong) GSHDeviceM *scenePanelDeviceM;
@property (nonatomic , assign) int indexValue;
@property (nonatomic , strong) NSString *basMeteId;
@property (strong, nonatomic) IBOutlet UITableView *sceneTableView;

@end

@implementation GSHChooseSceneListVC

+ (instancetype)chooseSceneListVCWithDeviceM:(GSHDeviceM *)deviceM indexValue:(int)indexValue basMeteId:(NSString *)basMeteId {
    GSHChooseSceneListVC *vc = [TZMPageManager viewControllerWithSB:@"GSHChooseSceneListSB" andID:@"GSHChooseSceneListVC"];
    vc.indexValue = indexValue;
    vc.scenePanelDeviceM = deviceM;
    vc.basMeteId = basMeteId;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 请求场景列表
    [self getSceneList];
}

#pragma mark - Lazy
- (NSMutableArray *)sourceArray {
    if (!_sourceArray) {
        _sourceArray = [NSMutableArray array];
    }
    return _sourceArray;
}

#pragma mark - request

// 请求场景列表
- (void)getSceneList {
    [SVProgressHUD showWithStatus:@"场景获取中"];
    @weakify(self)
    [GSHSceneManager getSceneListWithFamilyId:[GSHOpenSDK share].currentFamily.familyId currPage:nil block:^(NSArray<GSHOssSceneM *> *list, NSError *error) {
        @strongify(self)
        [SVProgressHUD dismiss];
        if (error) {
            [self.view showPageStatus:TZMPageStatusNormal image:[UIImage imageNamed:@"blankpage_icon_network"] title:nil desc:error.localizedDescription buttonText:@"刷新" didClickButtonCallback:^(TZMPageStatus status) {
                [self getSceneList];
            }];
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        } else {
            [self dismissPageStatusView];
            if (self.sourceArray.count > 0) {
                [self.sourceArray removeAllObjects];
            }
            [self.sourceArray addObjectsFromArray:list];

            [self.sceneTableView reloadData];
            if (self.sourceArray.count == 0) {
                [self showPageStatus:TZMPageStatusNormal image:[UIImage imageNamed:@"blankpage_icon_homescene"] title:nil desc:@"暂无场景" buttonText:nil didClickButtonCallback:nil];
            }
        }
    }];
}

- (void)showBlankView {
    
    @weakify(self)
    [self showPageStatus:TZMPageStatusNormal
                   image:[UIImage imageNamed:@"blankpage_icon_homescene"]
                   title:@"还未添加场景"
                    desc:@""
              buttonText:@"刷新"
  didClickButtonCallback:^(TZMPageStatus status) {
      @strongify(self)
      [self getSceneList];
  }];
}

// 确定
- (IBAction)sureButtonClick:(id)sender {
    if (!self.selectOssSceneM) {
        [SVProgressHUD showErrorWithStatus:@"未选择场景"];
        return;
    }
    GSHAutoActionListM *actionListM = [[GSHAutoActionListM alloc] init];
    actionListM.scenarioId = self.selectOssSceneM.scenarioId;
    actionListM.scenarioName = self.selectOssSceneM.scenarioName;
    actionListM.businessId = self.selectOssSceneM.businessId;
    
    GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
    extM.basMeteId = self.basMeteId;
    extM.rightValue = [NSString stringWithFormat:@"%d",self.indexValue];
    extM.conditionOperator = @"==";
    
    GSHDeviceM *deviceM = [[GSHDeviceM alloc] init];
    deviceM.deviceSn = self.scenePanelDeviceM.deviceSn;
    deviceM.deviceId = self.scenePanelDeviceM.deviceId;
    deviceM.deviceType = self.scenePanelDeviceM.deviceType;
    deviceM.deviceModel = self.scenePanelDeviceM.deviceModel;
    deviceM.deviceName = self.scenePanelDeviceM.deviceName;
    
    GSHAutoTriggerConditionListM *conditionListM = [[GSHAutoTriggerConditionListM alloc] init];
    conditionListM.week = 0;
    conditionListM.device = deviceM;
    [conditionListM.device.exts addObject:extM];
    
    GSHAutoTriggerM *triggerM = [[GSHAutoTriggerM alloc] init];
    triggerM.relationType = @(0);
    triggerM.name = @"联动条件";
    [triggerM.conditionList addObject:conditionListM];
    
    GSHAutoM *setAutoM = [[GSHAutoM alloc] init];
    setAutoM.week = 127;
    setAutoM.startTime = @(0);
    setAutoM.endTime = @(0);
    setAutoM.status = @(1);
    setAutoM.type = @(0);
    setAutoM.familyId = [GSHOpenSDK share].currentFamily.familyId.numberValue;
    [setAutoM.actionList addObject:actionListM];
    setAutoM.trigger = triggerM;
    
    GSHOssAutoM *ossAutoM = [[GSHOssAutoM alloc] init];
    ossAutoM.familyId = [GSHOpenSDK share].currentFamily.familyId.numberValue;
    ossAutoM.name = setAutoM.automationName;
    ossAutoM.type = setAutoM.type;
    ossAutoM.status = setAutoM.status;
    ossAutoM.md5 = [[setAutoM yy_modelToJSONString] md5String];
    ossAutoM.relationType = setAutoM.trigger.relationType;
    
    @weakify(self)
    [SVProgressHUD showWithStatus:@"绑定中"];
    [GSHAutoManager bindSceneWithOssAutoM:ossAutoM
                                    autoM:setAutoM
                                 deviceId:self.scenePanelDeviceM.deviceId.stringValue
                                basMeteId:self.basMeteId
                               scenarioId:self.selectOssSceneM.scenarioId.stringValue
                                    block:^(NSString *ruleId, NSError *error) {
                                        @strongify(self)
                                        if (error) {
                                            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                                        } else {
                                            [SVProgressHUD showSuccessWithStatus:@"绑定成功"];
                                            if (self.bindSceneSuccessBlock) {
                                                self.bindSceneSuccessBlock(self.selectOssSceneM);
                                            }
                                            [self.navigationController popViewControllerAnimated:YES];
                                        }
                                    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GSHChooseSceneListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GSHChooseSceneListCell" forIndexPath:indexPath];
    if (self.sourceArray.count > indexPath.row) {
        GSHOssSceneM *ossSceneM = self.sourceArray[indexPath.row];
        cell.sceneNameLabel.text = ossSceneM.scenarioName;
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHChooseSceneListCell *cell = (GSHChooseSceneListCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.checkButton.selected = YES;
    cell.sceneNameLabel.textColor = [UIColor colorWithHexString:@"#4c90f7"];
    GSHOssSceneM *ossSceneM = self.sourceArray[indexPath.row];
    self.selectOssSceneM = ossSceneM;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHChooseSceneListCell *cell = (GSHChooseSceneListCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.checkButton.selected = NO;
    cell.sceneNameLabel.textColor = [UIColor colorWithHexString:@"#282828"];
}

@end

@implementation GSHChooseSceneListCell



@end
