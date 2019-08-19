//
//  GSHAddSceneVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/5/16.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHAddSceneVC.h"
#import "GSHAddSceneCell.h"
#import "GSHChooseDeviceListCell.h"
#import "GSHSceneBackgroundVC.h"
#import "GSHChooseRoomVC.h" // 房间选择
#import "GSHChooseDeviceVC.h"   // 添加执行动作 -- 选择设备
#import "GSHVoiceKeyWordVC.h"

#import "NSString+TZM.h"
#import "ZJPickerView.h"
#import "GSHPickerView.h"

#import "GSHThreeWaySwitchHandleVC.h"
#import "GSHAirConditionerHandleVC.h"
#import "GSHNewWindHandleVC.h"
#import "GSHDeviceSocketHandleVC.h"
#import "GSHUnderFloorHeatVC.h"

#import "GSHAlertManager.h"
#import "UITextField+TZM.h"

#import "GSHAddSceneVCViewModel.h"


@interface GSHAddSceneVC () <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (nonatomic , strong) UITableView *addSceneTableView;
@property (nonatomic , strong) NSArray *cellNameArray;
@property (nonatomic , strong) NSMutableArray *scenePanelArray;
@property (nonatomic , strong) NSMutableArray *selectDeviceArray;
@property (nonatomic , strong) NSMutableArray *floorListArray;
@property (nonatomic , strong) NSArray *voiceKeyWordArray;
@property (nonatomic , strong) GSHSceneM *sceneSetM;
@property (nonatomic , strong) __block GSHOssSceneM *ossSceneSetM;

@end

@implementation GSHAddSceneVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.cellNameArray = @[@[@"场景名称",@"背景图片",@"所属房间"],@[@"语音关键词"],@[@"添加执行动作"]];
    
    if (self.sceneM) {
        self.sceneSetM = [self.sceneM yy_modelCopy];
        self.ossSceneSetM = [self.ossSceneM yy_modelCopy];
        if (self.sceneM.voiceKeyword.length > 0) {
            self.voiceKeyWordArray = [self.sceneM.voiceKeyword componentsSeparatedByString:@","];
        }
        self.selectDeviceArray = [self.sceneM.devices mutableCopy];
        self.navigationItem.title = @"编辑场景";
    } else {
        self.sceneSetM.backgroundId = @(0);
        self.navigationItem.title = @"添加场景";
    }
    
    [self initNavigationView];
    self.addSceneTableView.backgroundColor = [UIColor colorWithHexString:@"#F6F7FA"];
    
    if (self.isAlertToNotiUser) {
        // 场景下信息有变动，默默同步到后台
        [self saveSceneButtonClick:nil];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.sceneSetM = nil;
}

#pragma mark - UI
- (void)initNavigationView {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(saveSceneButtonClick:)];
}

#pragma mark - Lazy
- (NSMutableArray *)selectDeviceArray {
    if (!_selectDeviceArray) {
        _selectDeviceArray = [NSMutableArray array];
    }
    return _selectDeviceArray;
}

- (NSMutableArray *)floorListArray {
    if (!_floorListArray) {
        _floorListArray = [NSMutableArray array];
    }
    return _floorListArray;
}

- (GSHSceneM *)sceneSetM {
    if (!_sceneSetM) {
        _sceneSetM = [[GSHSceneM alloc] init];
    }
    return _sceneSetM;
}

- (GSHOssSceneM *)ossSceneSetM {
    if (!_ossSceneSetM) {
        _ossSceneSetM = [[GSHOssSceneM alloc] init];
    }
    return _ossSceneSetM;
}

- (NSMutableArray *)scenePanelArray {
    if (!_scenePanelArray) {
        _scenePanelArray = [NSMutableArray array];
    }
    return _scenePanelArray;
}

- (UITableView *)addSceneTableView {
    if (!_addSceneTableView) {
        _addSceneTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - KNavigationBar_Height) style:UITableViewStyleGrouped];
        _addSceneTableView.dataSource = self;
        _addSceneTableView.delegate = self;
        _addSceneTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_addSceneTableView registerNib:[UINib nibWithNibName:@"GSHAddSceneCell" bundle:nil] forCellReuseIdentifier:@"addSceneCell"];
        [_addSceneTableView registerNib:[UINib nibWithNibName:@"GSHChooseDeviceListCell" bundle:nil] forCellReuseIdentifier:@"chooseDeviceListCell"];
        [self.view addSubview:_addSceneTableView];
    }
    return _addSceneTableView;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.sceneSetM.scenarioName = textField.text;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 1) {
        return 80.0f;
    }
    return 50.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    } else if (section == 1 || section == 2) {
        return 10;
    } else {
        return 44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] init];
    if (section == 1 || section == 2) {
        view.frame = CGRectMake(0, 0, SCREEN_WIDTH, 10);
    } else if (section == 2) {
        view.frame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, SCREEN_WIDTH - 14, 44)];
        label.text = @"执行动作";
        label.textColor = [UIColor colorWithHexString:@"#999999"];
        label.font = [UIFont systemFontOfSize:14.0];
        [view addSubview:label];
    }
    return view;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    if (indexPath.section == 2 && indexPath.row > 0) {
        GSHDeviceM *deviceM = self.selectDeviceArray[indexPath.row - 1];
        GSHChooseDeviceListCell *deviceCell = (GSHChooseDeviceListCell *)[tableView cellForRowAtIndexPath:indexPath];
        __weak typeof(deviceM) weakDeviceM = deviceM;
        __weak typeof(deviceCell) weakDeviceCell = deviceCell;
        [GSHAddSceneVCViewModel jumpToDeviceHandleVCWithVC:self deviceM:deviceM deviceSetCompleteBlock:^(NSArray * _Nonnull exts) {
            __strong typeof(weakDeviceM) strongDeviceM = weakDeviceM;
            __strong typeof(weakDeviceCell) strongDeviceCell = weakDeviceCell;
            [strongDeviceM.exts removeAllObjects];
            [strongDeviceM.exts addObjectsFromArray:exts];
            strongDeviceCell.deviceActionLabel.text = [GSHAddSceneVCViewModel getDeviceShowStrWithDeviceM:strongDeviceM];
        }];
    } else {
        GSHAddSceneCell *addSceneCell = (GSHAddSceneCell *)[tableView cellForRowAtIndexPath:indexPath];
        if (indexPath.section == 0 && indexPath.row == 1) {
            // 选择背景图片
            GSHSceneBackgroundVC *sceneBackVC = [[GSHSceneBackgroundVC alloc] initWithBackImgId:[self.sceneSetM.backgroundId intValue]];
            __weak typeof(addSceneCell) weakAddSceneCell = addSceneCell;
            sceneBackVC.selectBackImage = ^(int backImgIndex) {
                __strong typeof(weakAddSceneCell) strongAddSceneCell = weakAddSceneCell;
                self.sceneSetM.backgroundId = @(backImgIndex);
                strongAddSceneCell.sceneBackImageView.image = [GSHSceneM getSceneBackgroundImageWithId:backImgIndex];
            };
            [self.navigationController pushViewController:sceneBackVC animated:YES];
        } else if (indexPath.section == 0 && indexPath.row == 2) {
            // 选择房间
            [self popupRoomViewToChooseRoomWithCell:addSceneCell];
        } else if (indexPath.section == 1) {
            // 语音关键词
            GSHVoiceKeyWordVC *voiceKeyWordVC = [[GSHVoiceKeyWordVC alloc] init];
            [voiceKeyWordVC.keyWordArray addObjectsFromArray:self.voiceKeyWordArray];
            @weakify(self)
            voiceKeyWordVC.setVoiceKeyWordBlock = ^(NSArray *voiceKeyWordArray) {
                @strongify(self)
                self.voiceKeyWordArray = voiceKeyWordArray;
                if (voiceKeyWordArray.count > 0) {
                    NSMutableString *voiceKeyWordStr = [NSMutableString string];
                    [voiceKeyWordArray enumerateObjectsUsingBlock:^(NSString*  _Nonnull voiceKeyWord, NSUInteger idx, BOOL * _Nonnull stop) {
                        [voiceKeyWordStr appendString:[NSString stringWithFormat:@"%@,",voiceKeyWord]];
                    }];
                    if (voiceKeyWordStr.length > 0) {
                        [voiceKeyWordStr deleteCharactersInRange:NSMakeRange(voiceKeyWordStr.length - 1, 1)];
                    }
                    self.sceneSetM.voiceKeyword = (NSString *)voiceKeyWordStr;
                } else {
                    self.sceneSetM.voiceKeyword = @"";
                }
            };
            [self.navigationController pushViewController:voiceKeyWordVC animated:YES];
        } else if (indexPath.section == 2 && indexPath.row == 0) {
            // 添加设备
            GSHFloorM *floorM;
            GSHRoomM *roomM;
            if (self.floorListArray.count > 0) {
                floorM = self.floorListArray[0];
                if (floorM.rooms.count > 0) {
                    roomM = floorM.rooms[0];
                }
            }
            GSHChooseDeviceVC *chooseDeviceVC = [[GSHChooseDeviceVC alloc] initWithSelectDeviceArray:self.selectDeviceArray floorM:floorM roomM:roomM floorArray:self.floorListArray];
            chooseDeviceVC.fromFlag = ChooseDeviceFromAddScene;
            @weakify(self)
            chooseDeviceVC.selectDeviceBlock = ^(NSArray *selectedDeviceArray) {
                @strongify(self)
                [self refreshSelectedDeviceArrayWithDeviceArray:selectedDeviceArray];
                [self.addSceneTableView reloadData];
            };
            [self.navigationController pushViewController:chooseDeviceVC animated:YES];
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.cellNameArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *arr = self.cellNameArray[section];
    if (section == 2) {
        return arr.count + self.selectDeviceArray.count;
    }
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 2 && indexPath.row > 0) {
        // 选择的设备
        GSHChooseDeviceListCell *chooseDeviceListCell = [tableView dequeueReusableCellWithIdentifier:@"chooseDeviceListCell" forIndexPath:indexPath];
        chooseDeviceListCell.selectionStyle = UITableViewCellSelectionStyleNone;
        GSHDeviceM *deviceM = self.selectDeviceArray[indexPath.row - 1];
        [chooseDeviceListCell.checkButton setImage:[UIImage imageNamed:@"list_icon_arrow_right"] forState:UIControlStateNormal];
        chooseDeviceListCell.checkButton.enabled = NO;
        NSString *imageStr;
        if (deviceM.category.deviceType.integerValue == 254 && deviceM.category.deviceModel.integerValue < 0) {
            imageStr = [NSString stringWithFormat:@"deviceCategroy_off_icon_infrared_%d",-[deviceM.category.deviceModel intValue]];
        }else{
            imageStr = [NSString stringWithFormat:@"deviceCategroy_off_icon-%d",[deviceM.category.deviceType intValue]];
        }
        chooseDeviceListCell.deviceIconImageView.image = [UIImage imageNamed:imageStr];
        chooseDeviceListCell.deviceNameLabel.text = deviceM.deviceName;
        if (deviceM.exts.count > 0) {
            chooseDeviceListCell.deviceActionLabel.hidden = NO;
            chooseDeviceListCell.deviceActionLabel.text = [GSHAddSceneVCViewModel getDeviceShowStrWithDeviceM:deviceM];
        } else {
            chooseDeviceListCell.deviceActionLabel.text = @"";
        }
        return chooseDeviceListCell;
    } else {
        GSHAddSceneCell *addSceneCell = [tableView dequeueReusableCellWithIdentifier:@"addSceneCell" forIndexPath:indexPath];
        addSceneCell.selectionStyle = UITableViewCellSelectionStyleNone;
        addSceneCell.inputTextField.hidden = !(indexPath.section == 0 && indexPath.row == 0);
        addSceneCell.inputTextField.tzm_maxLen = 16;
        addSceneCell.inputTextField.delegate = self;
        addSceneCell.arrowImageView.hidden = (indexPath.section == 0 && indexPath.row == 0);
        addSceneCell.arrowImageView.image = (indexPath.section == 2 && indexPath.row == 0) ? [UIImage imageNamed:@"scene_list_icon_add"] : [UIImage imageNamed:@"list_icon_arrow_right"];
        addSceneCell.sceneBackImageView.hidden = !(indexPath.section == 0 && indexPath.row == 1);
        addSceneCell.itemNameLabel.text = self.cellNameArray[indexPath.section][indexPath.row];
        addSceneCell.detailLabel.text = (indexPath.section == 0 && indexPath.row == 2) ? @"选取房间" : @"";
        if (self.sceneSetM.scenarioName || self.sceneSetM.backgroundId || self.sceneSetM.floorName) {
            if (indexPath.section == 0 && indexPath.row == 0) {
                addSceneCell.inputTextField.text = self.sceneSetM.scenarioName;
            } else if (indexPath.section == 0 && indexPath.row == 1) {
                addSceneCell.sceneBackImageView.image = [GSHSceneM getSceneBackgroundImageWithId:[self.sceneSetM.backgroundId intValue]];
            } else if (indexPath.section == 0 && indexPath.row == 2) {
                NSString *roomStr = @"";
                if ([GSHOpenSDK share].currentFamily.floor.count == 1) {
                    roomStr = self.sceneSetM.roomName?self.sceneSetM.roomName:@"";
                } else {
                    roomStr = [NSString stringWithFormat:@"%@%@",self.sceneSetM.floorName?self.sceneSetM.floorName:@"",self.sceneSetM.roomName?self.sceneSetM.roomName:@""];
                }
                addSceneCell.detailLabel.text = roomStr.length > 0 ? roomStr : @"选取房间";
            }
        }
        return addSceneCell;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2 && indexPath.row > 0) {
        return YES;
    }
    return NO;
}

// 定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

// 进入编辑模式，按下出现的编辑按钮后,进行删除操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (self.selectDeviceArray.count > indexPath.row - 1) {
            [self.selectDeviceArray removeObjectAtIndex:indexPath.row - 1];
            [self.addSceneTableView reloadData];
        }
    }
}

// 修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

#pragma mark - method
// 保存按钮点击
- (void)saveSceneButtonClick:(UIButton *)button {
    
    [self.view endEditing:YES];
    if (!self.sceneSetM.scenarioName || [self.sceneSetM.scenarioName checkStringIsEmpty]) {
        [SVProgressHUD showErrorWithStatus:@"场景名称不能为空"];
        return;
    }
    if ([self.sceneSetM.scenarioName judgeTheillegalCharacter]) {
        [SVProgressHUD showErrorWithStatus:@"名字不能含特殊字符"];
        return;
    }
    if (!self.sceneSetM.backgroundId) {
        [SVProgressHUD showErrorWithStatus:@"请选择背景图片"];
        return;
    }
    if (self.selectDeviceArray.count == 0) {
        [SVProgressHUD showErrorWithStatus:@"请添加执行动作"];
        return;
    }
    self.sceneSetM.familyId = [GSHOpenSDK share].currentFamily.familyId.numberValue;
    if (self.sceneSetM.devices.count > 0) {
        [self.sceneSetM.devices removeAllObjects];
    }
    [self.sceneSetM.devices addObjectsFromArray:self.selectDeviceArray];
    
    for (GSHDeviceM *deviceM in self.sceneSetM.devices) {
        if (deviceM.exts.count == 0) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@ 未设置执行动作",deviceM.deviceName]];
            return;
        }
    }
    
    self.ossSceneSetM.md5 = [[self.sceneSetM yy_modelToJSONString] md5String];
    self.ossSceneSetM.familyId = [GSHOpenSDK share].currentFamily.familyId.numberValue;
    self.ossSceneSetM.scenarioName = self.sceneSetM.scenarioName;
    self.ossSceneSetM.rank = self.largestRank.numberValue;
    self.ossSceneSetM.backgroundId = self.sceneSetM.backgroundId;
    self.ossSceneSetM.roomId = self.sceneSetM.roomId;
    self.ossSceneSetM.roomName = self.sceneSetM.roomName?self.sceneSetM.roomName:@"";
    self.ossSceneSetM.floorName = self.sceneSetM.floorName?self.sceneSetM.floorName:@"";
    self.ossSceneSetM.voiceKeyword = self.sceneSetM.voiceKeyword?self.sceneSetM.voiceKeyword:@"";
    
    if (self.sceneM) {
        if (button) {
            [SVProgressHUD showWithStatus:@"修改中"];
        }
        @weakify(self)
        NSString *volumeId = [self.ossSceneSetM.fid componentsSeparatedByString:@","].firstObject;
        [GSHSceneManager alertSceneWithVolumeId:volumeId oldRoomId:self.sceneM.roomId.stringValue sceneM:self.sceneSetM ossSceneM:self.ossSceneSetM block:^(NSError *error) {
            @strongify(self)
            if (error) {
                if (button) {
                    if (error.code == 71) {
                        // 情景名称已存在
                        [SVProgressHUD showErrorWithStatus:@"情景名称已存在"];
                    } else {
                        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                    }
                }
            } else {
                if (self.updateSceneBlock) {
                    self.updateSceneBlock(self.ossSceneSetM);
                }
                
                if (button) {
                    [SVProgressHUD showSuccessWithStatus:@"修改成功"];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
        }];

    } else {
        [SVProgressHUD showWithStatus:@"添加中"];
        @weakify(self)
        [GSHSceneManager addSceneWithSceneM:self.sceneSetM ossSceneM:self.ossSceneSetM block:^(NSString *scenarionId, NSError *error) {
            @strongify(self)
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            } else {
                self.ossSceneSetM.scenarioId = scenarionId.numberValue;
                if (self.saveSceneBlock) {
                    self.saveSceneBlock(self.ossSceneSetM);
                }
                [SVProgressHUD showSuccessWithStatus:@"添加成功"];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
}

// 弹出选择房间的弹框
- (void)popupRoomViewToChooseRoomWithCell:(GSHAddSceneCell *)cell {
    __weak typeof(cell) weakCell = cell;
    @weakify(self)
    [GSHPickerView
     showPickerViewContainResetButtonWithDataArray:[self handleRoomInfoWithFloorMList:[GSHOpenSDK share].currentFamily.floor]
     cancelBenTitle:@"重置"
     cancelBenTitleColor:[UIColor colorWithHexString:@"#4C90F7"]
     sureBtnTitle:@"确定"
     cancelBlock:^{
         // 重置按钮点击
         NSLog(@"重置了");
         @strongify(self)
         self.sceneSetM.floorName = nil;
         self.sceneSetM.floorId = nil;
         self.sceneSetM.roomName = nil;
         self.sceneSetM.roomId = nil;
         [self.addSceneTableView reloadData];
         
     } completion:^(NSString *selectContent , NSArray *selectRowArray) {
         
         __strong typeof(weakCell) strongCell = weakCell;
         @strongify(self)
         strongCell.detailLabel.text = selectContent;
         
         if ([GSHOpenSDK share].currentFamily.floor.count == 1) {
             // 只有一个楼层
             GSHFloorM *floorM = [GSHOpenSDK share].currentFamily.floor[0];
             self.sceneSetM.floorName = floorM.floorName;
             self.sceneSetM.floorId = floorM.floorId;
             NSNumber *roomRow = selectRowArray[0];
             GSHRoomM *roomM = floorM.rooms[[roomRow intValue]];
             self.sceneSetM.roomName = roomM.roomName;
             self.sceneSetM.roomId = roomM.roomId;
         } else {
             // 有多个楼层
             if (selectRowArray.count == 2) {
                 NSNumber *floorRow = selectRowArray[0];
                 NSNumber *roomRow = selectRowArray[1];
                 if ([GSHOpenSDK share].currentFamily.floor.count > [floorRow intValue]) {
                     GSHFloorM *floorM = [GSHOpenSDK share].currentFamily.floor[[floorRow intValue]];
                     self.sceneSetM.floorName = floorM.floorName;
                     self.sceneSetM.floorId = floorM.floorId;
                     if (floorM.rooms.count > [roomRow intValue]) {
                         GSHRoomM *roomM = floorM.rooms[[roomRow intValue]];
                         self.sceneSetM.roomName = roomM.roomName;
                         self.sceneSetM.roomId = roomM.roomId;
                     }
                 }
             }
         }
     }];
}

- (NSArray *)handleRoomInfoWithFloorMList:(NSArray *)floorMList {
    if (floorMList.count == 1) {
        GSHFloorM *floorM = floorMList[0];
        NSMutableArray *roomNameArray = [NSMutableArray array];
        for (GSHRoomM *roomM in floorM.rooms) {
            [roomNameArray addObject:roomM.roomName];
        }
        return roomNameArray;
    } else {
        NSMutableArray *floorArray = [NSMutableArray array];
        for (GSHFloorM *floorM in floorMList) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            NSMutableArray *roomNameArray = [NSMutableArray array];
            for (GSHRoomM *roomM in floorM.rooms) {
                [roomNameArray addObject:roomM.roomName];
            }
            [dic setObject:roomNameArray forKey:floorM.floorName];
            [floorArray addObject:dic];
        }
        return floorArray;
    }
}

// 从当前已选设备数组中，删除已改为未选中的设备
- (void)removeFromSelectDeviceArrayWithDeviceM:(GSHDeviceM *)deviceM {
    for (GSHDeviceM *tmpDeviceM in self.selectDeviceArray) {
        if ([deviceM.deviceId isKindOfClass:NSNumber.class]) {
            if ([tmpDeviceM.deviceId isEqualToNumber:deviceM.deviceId]) {
                [self.selectDeviceArray removeObject:tmpDeviceM];
                break;
            }
        }
    }
}

// 设备选择完成之后，刷新已选择设备情况
- (void)refreshSelectedDeviceArrayWithDeviceArray:(NSArray *)deviceArray {
    NSMutableArray *shouldBeAddedArray = [NSMutableArray array];
    for (GSHDeviceM *deviceM in deviceArray) {
        BOOL isIn = NO;
        for (GSHDeviceM *selectedDeviceM in self.selectDeviceArray) {
            if ([deviceM.deviceId isKindOfClass:NSNumber.class]) {
                if ([selectedDeviceM.deviceId isEqualToNumber:deviceM.deviceId]) {
                    isIn = YES;
                }
            }
        }
        if (!isIn) {
            [shouldBeAddedArray addObject:deviceM];
        }
    }
    
    NSMutableArray *shouldBeDeleteArray = [NSMutableArray array];
    for (GSHDeviceM *selectedDeviceM in self.selectDeviceArray) {
        BOOL isIn = NO;
        for (GSHDeviceM *deviceM in deviceArray) {
            if ([selectedDeviceM.deviceId isKindOfClass:NSNumber.class]) {
                if ([deviceM.deviceId isEqualToNumber:selectedDeviceM.deviceId]) {
                    isIn = YES;
                }
            }
        }
        if (!isIn) {
            [shouldBeDeleteArray addObject:selectedDeviceM];
        }
    }
    if (shouldBeAddedArray.count > 0) {
        [self.selectDeviceArray addObjectsFromArray:shouldBeAddedArray];
    }
    if (shouldBeDeleteArray.count > 0) {
        [self.selectDeviceArray removeObjectsInArray:shouldBeDeleteArray];
    }
    for (GSHDeviceM *deviceM in self.selectDeviceArray) {
        if (deviceM.exts.count == 0) {
            [deviceM.exts addObjectsFromArray:[GSHAddSceneVCViewModel getInitExtsWithDeviceM:deviceM]];
        }
    }
}

@end
