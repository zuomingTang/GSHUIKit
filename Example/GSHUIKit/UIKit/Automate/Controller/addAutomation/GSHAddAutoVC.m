//
//  GSHAddAutoVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/5/30.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHAddAutoVC.h"
#import "GSHAddTriggerConditionVC.h"
#import "GSHAutoAddActionVC.h"

#import "GSHAutoTimeSetVC.h"
#import "GSHAutoEffectTimeSetVC.h"

#import "GSHPickerView.h"

#import "NSString+TZM.h"
#import "UITextField+TZM.h"

#import <GSHOpenSDKSoundCode/GSHDeviceM.h>
#import "GSHAlertManager.h"

#import "GSHAddAutoVCViewModel.h"
#import "GSHDeviceInfoDefines.h"

@interface GSHAddAutoVC () <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *addAutoTableView;
@property (weak, nonatomic) IBOutlet UIView *effectTimeView;    // 生效时间段
@property (weak, nonatomic) IBOutlet UILabel *showEffectTimeLabel;

// 定时
@property (strong, nonatomic) __block NSString *timeStr;    // 定时条件 -- 时间
@property (strong, nonatomic) __block NSString *repeatCountStr;     // 定时条件 -- 重复次数
@property (strong, nonatomic) NSMutableIndexSet *timingWeekIndexSet;
// 生效时间段
@property (strong, nonatomic) NSMutableIndexSet *effectTimeWeekIndexSet;
@property (strong, nonatomic) __block NSString *effectStartTime;
@property (strong, nonatomic) __block NSString *effectEndTime;

@property (strong, nonatomic) NSMutableArray *deviceConditionArray; // 设备受控时条件
@property (strong, nonatomic) NSMutableArray *actionArray; // 执行动作

@property (strong, nonatomic) UITextField *autoNameTextField;

@property (strong, nonatomic) GSHAutoM *setAutoM; // 执行动作
@property (strong, nonatomic) GSHAutoTriggerM *triggerM;
@property (strong, nonatomic) GSHOssAutoM *ossSetAutoM;

@end

@implementation GSHAddAutoVC

+ (instancetype)addAutoVC {
    GSHAddAutoVC *vc = [TZMPageManager viewControllerWithSB:@"GSHAddAutomationSB" andID:@"GSHAddAutoVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNavigationView];
    
    UITapGestureRecognizer *effectTimeGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(effectTimeChoose:)];
    [self.effectTimeView addGestureRecognizer:effectTimeGesture];
    
    if (self.autoM) {
        // 编辑
        [self initEditData];
        self.navigationItem.title = @"编辑联动";
    } else {
        // 非编辑
        self.navigationItem.title = @"添加联动";
        // 默认 设置为‘满足以上全部条件’
        self.triggerM.relationType = @(0);
        self.showEffectTimeLabel.text = @"全天";
        self.effectStartTime = @"00:00";
        self.effectEndTime = @"00:00";
        self.effectTimeWeekIndexSet = [[self getWeekIndexSetWithWeek:127] mutableCopy];
    }
    if (self.isAlertToNotiUser) {
        // 该联动下的信息有更改，自动同步到后台
        [self saveAutoButtonClick:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initEditData {
    
    self.setAutoM = [self.autoM yy_modelCopy];
    self.ossSetAutoM = [self.ossAutoM yy_modelCopy];
    self.triggerM = self.autoM.trigger;
    
    self.actionArray = [self.autoM.actionList mutableCopy];
    
    if (self.setAutoM.trigger.isSetTime) {
        // 有设置定时时间
        GSHAutoTriggerConditionListM *conditionListM = self.setAutoM.trigger.conditionList[0];
        self.timeStr = conditionListM.getDateTimer;
        self.timingWeekIndexSet = [[self getWeekIndexSetWithWeek:conditionListM.week] mutableCopy];
        self.repeatCountStr = [conditionListM getWeekStrWithIndexSet:self.timingWeekIndexSet];
    }
    int deviceConditionIndex = self.setAutoM.trigger.isSetTime ? 1 : 0;
    if (self.deviceConditionArray.count > 0) {
        [self.deviceConditionArray removeAllObjects];
    }
    for (int i = deviceConditionIndex; i < self.triggerM.conditionList.count; i ++) {
        GSHAutoTriggerConditionListM *conditionListM = self.triggerM.conditionList[i];
        [self.deviceConditionArray addObject:conditionListM];
    }
    
    // 生效时间段
    self.effectTimeWeekIndexSet = [[self getWeekIndexSetWithWeek:self.setAutoM.week] mutableCopy];
    if (self.setAutoM.getStartTime && self.setAutoM.getEndTime) {
        self.effectStartTime = self.setAutoM.getStartTime;
        if ([self.setAutoM.getStartTime isEqualToString:self.setAutoM.getEndTime]) {
            self.showEffectTimeLabel.text = @"全天";
            self.effectEndTime = self.setAutoM.getEndTime;
        } else {
            NSDate *tmpStartTime = [NSDate dateWithString:self.setAutoM.getStartTime format:@"HH:mm"];
            NSDate *tmpEndTime = [NSDate dateWithString:self.setAutoM.getEndTime format:@"HH:mm"];
            if (tmpEndTime.timeIntervalSinceReferenceDate < tmpStartTime.timeIntervalSinceReferenceDate) {
                self.effectEndTime = [NSString stringWithFormat:@"n%@",self.setAutoM.getEndTime];
            } else {
                self.effectEndTime = self.setAutoM.getEndTime;
            }
            if ([self.effectEndTime containsString:@"n"]) {
                self.showEffectTimeLabel.text = [NSString stringWithFormat:@"%@ - %@(第二天)",self.effectStartTime,[self.effectEndTime substringFromIndex:1]];
            } else {
                self.showEffectTimeLabel.text = [NSString stringWithFormat:@"%@ - %@",self.effectStartTime,self.effectEndTime];
            }
        }
    } else {
        self.showEffectTimeLabel.text = @"";
    }
}

#pragma mark - UI
- (void)initNavigationView {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(saveAutoButtonClick:)];
}

#pragma mark - Lazy
- (NSMutableArray *)deviceConditionArray {
    if (!_deviceConditionArray) {
        _deviceConditionArray = [NSMutableArray array];
    }
    return _deviceConditionArray;
}

- (NSMutableArray *)actionArray {
    if (!_actionArray) {
        _actionArray = [NSMutableArray array];
    }
    return _actionArray;
}

- (GSHAutoM *)setAutoM {
    if (!_setAutoM) {
        _setAutoM = [[GSHAutoM alloc] init];
        _setAutoM.trigger = self.triggerM;
    }
    return _setAutoM;
}

- (GSHAutoTriggerM *)triggerM {
    if (!_triggerM) {
        _triggerM = [[GSHAutoTriggerM alloc] init];
        _triggerM.name = @"测试";
    }
    return _triggerM;
}

- (GSHOssAutoM *)ossSetAutoM {
    if (!_ossSetAutoM) {
        _ossSetAutoM = [[GSHOssAutoM alloc] init];
    }
    return _ossSetAutoM;
}

- (NSMutableIndexSet *)timingWeekIndexSet {
    if (!_timingWeekIndexSet) {
        _timingWeekIndexSet = [NSMutableIndexSet indexSet];
    }
    return _timingWeekIndexSet;
}

- (NSMutableIndexSet *)effectTimeWeekIndexSet {
    if (!_effectTimeWeekIndexSet) {
        _effectTimeWeekIndexSet = [NSMutableIndexSet indexSet];
    }
    return _effectTimeWeekIndexSet;
}

#pragma mark - method

- (void)saveAutoButtonClick:(UIButton *)button {
    
    [self.view endEditing:YES];
    
    if (!self.setAutoM.automationName || [self.setAutoM.automationName checkStringIsEmpty]) {
        [SVProgressHUD showErrorWithStatus:@"联动名称不能为空"];
        return;
    }
    if ([self.setAutoM.automationName judgeTheillegalCharacter]) {
        [SVProgressHUD showErrorWithStatus:@"名字不能含特殊字符"];
        return;
    }
    if (!self.timeStr && self.deviceConditionArray.count == 0) {
        [SVProgressHUD showErrorWithStatus:@"请设置触发条件"];
        return;
    }
    for (GSHAutoTriggerConditionListM *tmpConditionListM in self.deviceConditionArray) {
        if (tmpConditionListM.device.exts.count == 0) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"条件栏目中 %@ 未设置执行动作",tmpConditionListM.device.deviceName]];
            return;
        }
    }
    if (self.actionArray.count == 0) {
        [SVProgressHUD showErrorWithStatus:@"请添加执行动作"];
        return;
    }
    for (GSHAutoActionListM *actionListM in self.actionArray) {
        if (actionListM.device && actionListM.device.exts.count == 0) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"执行动作栏目中 %@ 未设置执行动作",actionListM.device.deviceName]];
            return;
        }
    }
    
    if (self.triggerM.conditionList.count > 0) {
        [self.triggerM.conditionList removeAllObjects];
    }
    if (self.timeStr.length > 0) {
        GSHAutoTriggerConditionListM *conditionListM = [[GSHAutoTriggerConditionListM alloc] init];
        conditionListM.datetimer = [self changeStringToTimerWithStr:self.timeStr];
        conditionListM.week = [self getDecimalByBinary:[self getWeekWithWeekIndexSet:self.timingWeekIndexSet]];
        [self.triggerM.conditionList insertObject:conditionListM atIndex:0];
    }
    if (self.deviceConditionArray.count > 0) {
        for (GSHAutoTriggerConditionListM *triggerConditionListM in self.deviceConditionArray) {
            [self.triggerM.conditionList addObject:triggerConditionListM];
        }
    }
    self.setAutoM.trigger = self.triggerM;
    self.setAutoM.status = @(1);
    
    if (self.timeStr) {
        // 有时间
        if (self.setAutoM.trigger.conditionList.count == 1) {
            // 只有时间
            self.setAutoM.type = @(1);
        } else {
            // 既有时间 ， 又有设备条件
            self.setAutoM.type = @(2);
        }
    } else {
        // 只有设备条件
        self.setAutoM.type = @(0);
    }
    self.setAutoM.familyId = [GSHOpenSDK share].currentFamily.familyId.numberValue;
    
    if ([self.effectEndTime containsString:@"n"]) {
        self.setAutoM.endTime = [self changeStringToTimerWithStr:[self.effectEndTime substringFromIndex:1]];
    } else {
        self.setAutoM.endTime = [self changeStringToTimerWithStr:self.effectEndTime];
    }
    self.setAutoM.startTime = [self changeStringToTimerWithStr:self.effectStartTime];
    self.setAutoM.week = [self getDecimalByBinary:[self getWeekWithWeekIndexSet:self.effectTimeWeekIndexSet]];
    
    if (self.setAutoM.actionList.count > 0) {
        [self.setAutoM.actionList removeAllObjects];
    }
    if (self.actionArray.count > 0) {
        [self.setAutoM.actionList addObjectsFromArray:self.actionArray];
    }
    
    self.ossSetAutoM.familyId = [GSHOpenSDK share].currentFamily.familyId.numberValue;
    self.ossSetAutoM.name = self.setAutoM.automationName;
    self.ossSetAutoM.type = self.setAutoM.type;
    self.ossSetAutoM.status = self.setAutoM.status;
    self.ossSetAutoM.md5 = [[self.setAutoM yy_modelToJSONString] md5String];
    self.ossSetAutoM.relationType = self.setAutoM.trigger.relationType;
    
    NSLog(@"保存的联动 json : %@",[self.setAutoM yy_modelToJSONString]);
    @weakify(self)
    if (self.isEditType) {
        // 编辑模式
        if (button) {
            [SVProgressHUD showWithStatus:@"修改中"];
        }
        NSString *volumeId = [self.ossSetAutoM.fid componentsSeparatedByString:@","].firstObject;
        
        [GSHAutoManager updateAutoWithVolumeId:volumeId ossAutoM:self.ossSetAutoM autoM:self.setAutoM block:^(NSError *error) {
            if (error) {
                if (button) {
                    if (error.code == 71) {
                        // 情景名称已存在
                        [SVProgressHUD showErrorWithStatus:@"联动名称已存在"];
                    } else {
                        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                    }
                }
            } else {
                if (self.updateAutoSuccessBlock) {
                    self.updateAutoSuccessBlock(self.ossSetAutoM);
                }
                // 更新本地文件
                if (button) {
                    [SVProgressHUD showSuccessWithStatus:@"修改成功"];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
        }];
    } else {
        // 添加联动
        [SVProgressHUD showWithStatus:@"添加中"];
        [GSHAutoManager addAutoWithOssAutoM:self.ossSetAutoM autoM:self.setAutoM block:^(NSString *ruleId, NSError *error) {
            @strongify(self)
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            } else {
                self.ossSetAutoM.ruleId = ruleId.numberValue;
                [SVProgressHUD showSuccessWithStatus:@"添加成功"];
                if (self.addAutoSuccessBlock) {
                    self.addAutoSuccessBlock(self.ossSetAutoM);
                }
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
}

// 选择生效时间段
- (void)effectTimeChoose:(UITapGestureRecognizer *)tapGesture {
    
    if (self.timeStr) {
        // 已设置定时条件
        [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
            
        } textFieldsSetupHandler:NULL andTitle:nil andMessage:@"已设置定时条件，生效时间默认全天" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:nil otherButtonTitles:@"知道了",nil];
    } else {
        GSHAutoEffectTimeSetVC *effectTimeSetVC = [GSHAutoEffectTimeSetVC autoEffectTimeSetVCWithStartTime:self.effectStartTime endTime:self.effectEndTime weekIndexSet:self.effectTimeWeekIndexSet timeSetVCType:GSHEffectTimeSetTypeVCAuto];
        @weakify(self)
        effectTimeSetVC.saveBlock = ^(BOOL isAllDay,NSIndexSet *repeatCountIndexSet, NSString * _Nonnull startTime, NSString * _Nonnull endTime) {
            @strongify(self)
            self.effectTimeWeekIndexSet = [repeatCountIndexSet mutableCopy];
            if (isAllDay) {
                self.showEffectTimeLabel.text = @"全天";
                self.effectStartTime = @"00:00";
                self.effectEndTime = @"00:00";
            } else {
                if ([endTime containsString:@"n"]) {
                    self.showEffectTimeLabel.text = [NSString stringWithFormat:@"%@ - %@(第二天)",startTime,[endTime substringFromIndex:1]];
                    self.effectEndTime = [endTime substringFromIndex:1];
                } else {
                    self.showEffectTimeLabel.text = [NSString stringWithFormat:@"%@ - %@",startTime,endTime];
                    self.effectEndTime = endTime;
                }
                self.effectStartTime = startTime;
            }
        };
        [self.navigationController pushViewController:effectTimeSetVC animated:YES];
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.autoNameTextField) {
        self.setAutoM.automationName = textField.text;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 1 ) {
        if (self.timeStr) {
            // 有定时
            return 3 + self.deviceConditionArray.count;
        } else {
            // 无定时
            if (self.deviceConditionArray.count >= 1) {
                return 2 + self.deviceConditionArray.count;
            } else {
                return 1 + self.deviceConditionArray.count;
            }
        }
    } else if (section == 2) {
        return 1 + self.actionArray.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        GSHAddAutoOneCell *oneCell = [tableView dequeueReusableCellWithIdentifier:@"oneCell" forIndexPath:indexPath];
        oneCell.selectionStyle = UITableViewCellSelectionStyleNone;
        oneCell.nameInputTextField.delegate = self;
        oneCell.nameInputTextField.text = self.setAutoM.automationName;
        oneCell.nameInputTextField.tzm_maxLen = 16;
        self.autoNameTextField = oneCell.nameInputTextField;
        return oneCell;
    } else if (indexPath.section == 1) {
        NSInteger satisfyRow = self.timeStr ? self.deviceConditionArray.count + 2 : self.deviceConditionArray.count + 1;
        NSInteger deviceBeginRow = self.timeStr ? 2 : 1;
        NSInteger conditionCount = self.timeStr ? self.deviceConditionArray.count + 1 : self.deviceConditionArray.count;
        if (indexPath.row == 0 || (conditionCount >= 1 && indexPath.row == satisfyRow)) {
            GSHAddAutoFourCell *fourCell = [tableView dequeueReusableCellWithIdentifier:@"fourCell" forIndexPath:indexPath];
            fourCell.selectionStyle = UITableViewCellSelectionStyleNone;
            fourCell.typeNameLabel.text = indexPath.row == 0 ? @"添加条件" : (self.triggerM.relationType.integerValue == 0 ? @"满足以上所有条件时" : @"满足以上任一条件时");
            fourCell.rightImageView.image = indexPath.row == 0 ? [UIImage imageNamed:@"auto_list_icon_add"] : [UIImage imageNamed:@"list_icon_arrow_right"];
            return fourCell;
        } else {
            GSHAddAutoFiveCell *fiveCell = [tableView dequeueReusableCellWithIdentifier:@"fiveCell" forIndexPath:indexPath];
            if (self.timeStr && indexPath.row == 1) {
                // 有定时条件
                fiveCell.cellImageView.image = [UIImage imageNamed:@"intelligent_icon_timing"];
                fiveCell.cellNameLabel.text = @"定时条件";
                fiveCell.rightMiddleLabel.hidden = YES;
                fiveCell.rightUpLabel.hidden = NO;
                fiveCell.rightDownLabel.hidden = NO;
                fiveCell.rightUpLabel.text = self.timeStr;
                fiveCell.rightDownLabel.text = self.repeatCountStr;
            } else {
                // 无定时条件
                GSHAutoTriggerConditionListM *triggerConditionM = self.deviceConditionArray[indexPath.row - deviceBeginRow];
                fiveCell.cellNameLabel.text = triggerConditionM.device.deviceName;
                NSString *imageStr;
                if (triggerConditionM.device.category.deviceType.integerValue == 254 && triggerConditionM.device.category.deviceModel.integerValue < 0) {
                    imageStr = [NSString stringWithFormat:@"deviceCategroy_off_icon_infrared_%d",-[triggerConditionM.device.category.deviceModel intValue]];
                }else{
                    imageStr = [NSString stringWithFormat:@"deviceCategroy_off_icon-%d",[triggerConditionM.device.category.deviceType intValue]];
                }
                
                fiveCell.cellImageView.image = [UIImage imageNamed:imageStr];
                fiveCell.rightMiddleLabel.hidden = NO;
                if (triggerConditionM.device.exts.count > 0) {
                    fiveCell.rightMiddleLabel.text = [GSHAddAutoVCViewModel getDeviceShowStrWithDeviceM:triggerConditionM.device];
                } else {
                    fiveCell.rightMiddleLabel.text = @"";
                }
                fiveCell.rightUpLabel.hidden = YES;
                fiveCell.rightDownLabel.hidden = YES;
            }
            return fiveCell;
        }
    } else if (indexPath.section == 2){
        if (indexPath.row == 0) {
            GSHAddAutoFourCell *fourCell = [tableView dequeueReusableCellWithIdentifier:@"fourCell" forIndexPath:indexPath];
            fourCell.selectionStyle = UITableViewCellSelectionStyleNone;
            fourCell.typeNameLabel.text = @"添加执行动作";
            fourCell.rightImageView.image = [UIImage imageNamed:@"auto_list_icon_add"];
            return fourCell;
        } else {
            GSHAddAutoFiveCell *fiveCell = [tableView dequeueReusableCellWithIdentifier:@"fiveCell" forIndexPath:indexPath];
            GSHAutoActionListM *autoActionListM = self.actionArray[indexPath.row - 1];
            fiveCell.cellNameLabel.text = autoActionListM.getActionName;
            if (autoActionListM.scenarioId) {
                fiveCell.cellImageView.image = [UIImage imageNamed:@"automation_icon_scenario"];
            } else if (autoActionListM.ruleId) {
                fiveCell.cellImageView.image = [UIImage imageNamed:@"automation_icon_automation"];
            } else {
                NSString *imageStr;
                if (autoActionListM.device.category.deviceType.integerValue == 254 && autoActionListM.device.category.deviceModel.integerValue < 0) {
                    imageStr = [NSString stringWithFormat:@"deviceCategroy_off_icon_infrared_%d",-[autoActionListM.device.category.deviceModel intValue]];
                }else{
                    imageStr = [NSString stringWithFormat:@"deviceCategroy_off_icon-%d",[autoActionListM.device.category.deviceType intValue]];
                }
                
                fiveCell.cellImageView.image = [UIImage imageNamed:imageStr];
            }
            fiveCell.rightUpLabel.hidden = YES;
            fiveCell.rightDownLabel.hidden = YES;
            fiveCell.rightMiddleLabel.hidden = NO;
            if (autoActionListM.device.exts.count > 0) {
                NSLog(@"att str : %d %@",(int)indexPath.row,[GSHAddAutoVCViewModel getDeviceShowStrWithDeviceM:autoActionListM.device]);
                fiveCell.rightMiddleLabel.text = [GSHAddAutoVCViewModel getDeviceShowStrWithDeviceM:autoActionListM.device];
            } else {
                fiveCell.rightMiddleLabel.text = @"";
            }
            return fiveCell;
        }
    }
    return nil;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger satisfyRow = self.timeStr ? self.deviceConditionArray.count + 2 : self.deviceConditionArray.count + 1;
    if (indexPath.section == 1) {
        if (indexPath.row > 0 && indexPath.row < satisfyRow) {
            return 70;
        } else {
            return 50;
        }
    } else if (indexPath.section == 2) {
        return indexPath.row == 0 ? 50 : 70;
    }
    return 50.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    if (section == 0) {
        view.backgroundColor = [UIColor colorWithHexString:@"#E9F2FF"];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"让设备在家居环境变化时，作出正确响应";
        label.textColor = [UIColor colorWithHexString:@"#297DFD"];
        label.font = [UIFont systemFontOfSize:14.0];
        [view addSubview:label];
    } else {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, SCREEN_WIDTH - 14, 44)];
        label.text = section == 1 ? @"触发条件" : @"执行任务";
        label.textColor = [UIColor colorWithHexString:@"#999999"];
        label.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14.0];
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
    if (indexPath.section == 1) {
        NSInteger satisfyRow = self.timeStr ? self.deviceConditionArray.count + 2 : self.deviceConditionArray.count + 1;
        if (indexPath.row == 0) {
            // 添加条件
            GSHAddTriggerConditionVC *addTriggerConditionVC = [GSHAddTriggerConditionVC addTriggerConditionVC];
            addTriggerConditionVC.selectedDeviceArray = [self.deviceConditionArray mutableCopy];
            addTriggerConditionVC.time = self.timeStr;
            @weakify(self)
            addTriggerConditionVC.compeleteSetTimeBlock = ^(NSString *time, NSString *repeatCount,NSIndexSet *repeatCountIndexSet) {
                @strongify(self)
                self.timeStr = time;
                self.repeatCountStr = repeatCount;
                self.timingWeekIndexSet = [repeatCountIndexSet mutableCopy];
                // 选择定时条件后 -- 生效时间段为全天
                self.showEffectTimeLabel.text = @"全天";
                self.effectStartTime = @"00:00";
                self.effectEndTime = @"00:00";
                [self.effectTimeWeekIndexSet removeAllIndexes];
                
                [self.addAutoTableView reloadData];
            };
            addTriggerConditionVC.selectDeviceBlock = ^(NSArray *selectedDeviceArray) {
                @strongify(self)
                [self refreshTriggerConditionArrayWithDeviceArray:selectedDeviceArray];
                [self.addAutoTableView reloadData];
            };
            [self.navigationController pushViewController:addTriggerConditionVC animated:YES];
        } else if (indexPath.row == satisfyRow) {
            GSHAddAutoFourCell *fourCell = (GSHAddAutoFourCell *)[tableView cellForRowAtIndexPath:indexPath];
            __weak typeof(fourCell) weakFourCell = fourCell;
            @weakify(self)
            // 选择满足条件方式
            [GSHPickerView showPickerViewWithDataArray:@[@"满足以上所有条件时",@"满足以上任一条件时"]
                                            completion:^(NSString *selectContent , NSArray *selectRowArray) {
                __strong typeof(weakFourCell) strongFourCell = weakFourCell;
                @strongify(self)
                strongFourCell.typeNameLabel.text = selectContent;
                self.triggerM.relationType = [selectContent isEqualToString:@"满足以上所有条件时"] ? @(0) : @(1);
            }];
        } else if (indexPath.row == 1) {
            if (self.timeStr) {
                // 选了时间
                GSHAutoTimeSetVC *timeSetVC = [GSHAutoTimeSetVC autoTimeSetVC];
                timeSetVC.time = self.timeStr;
                timeSetVC.repeatCount = self.repeatCountStr;
                timeSetVC.choosedIndexSet = self.timingWeekIndexSet;
                @weakify(self)
                timeSetVC.compeleteSetTimeBlock = ^(NSString *time, NSString *repeatCount,NSIndexSet *repeatCountIndexSet) {
                    @strongify(self)
                    self.timeStr = time;
                    self.repeatCountStr = repeatCount;
                    self.timingWeekIndexSet = [repeatCountIndexSet mutableCopy];
                    
                    // 选择了定时条件 -- 生效时间段默认为全天
                    self.showEffectTimeLabel.text = @"全天";
                    self.effectStartTime = @"00:00";
                    self.effectEndTime = @"00:00";
                    [self.effectTimeWeekIndexSet removeAllIndexes];
                    
                    [self.addAutoTableView reloadData];
                };
                [self.navigationController pushViewController:timeSetVC animated:YES];
            } else {
                GSHAutoTriggerConditionListM *triggerConditionListM = self.deviceConditionArray[indexPath.row-1];
                if ([triggerConditionListM.device.deviceType isEqual:GSHSOSSensorDeviceType]) {
                    [SVProgressHUD showErrorWithStatus:@"紧急按钮不可再选"];
                    return;
                }
                GSHAddAutoFiveCell *deviceCell = (GSHAddAutoFiveCell *)[tableView cellForRowAtIndexPath:indexPath];
                __weak typeof(triggerConditionListM.device) weakDeviceM = triggerConditionListM.device;
                __weak typeof(deviceCell) weakDeviceCell = deviceCell;
                [GSHAddAutoVCViewModel jumpToDeviceHandleVCWithVC:self
                                                          deviceM:triggerConditionListM.device
                                                   deviceEditType:GSHDeviceVCTypeAutoTriggerSet
                                           deviceSetCompleteBlock:^(NSArray * _Nonnull exts) {
                                               __strong typeof(weakDeviceM) strongDeviceM = weakDeviceM;
                                               __strong typeof(weakDeviceCell) strongDeviceCell = weakDeviceCell;
                                               [strongDeviceM.exts removeAllObjects];
                                               [strongDeviceM.exts addObjectsFromArray:exts];
                                               strongDeviceCell.rightMiddleLabel.text = [GSHAddAutoVCViewModel getDeviceShowStrWithDeviceM:strongDeviceM];
                                           }];
            }
        } else {
            // 设备
            GSHAddAutoFiveCell *deviceCell = (GSHAddAutoFiveCell *)[tableView cellForRowAtIndexPath:indexPath];
            __weak typeof(deviceCell) weakDeviceCell = deviceCell;
            if (self.timeStr) {
                GSHAutoTriggerConditionListM *triggerConditionListM = self.deviceConditionArray[indexPath.row-2];
                __weak typeof(triggerConditionListM.device) weakDeviceM = triggerConditionListM.device;
                [GSHAddAutoVCViewModel jumpToDeviceHandleVCWithVC:self
                                                          deviceM:triggerConditionListM.device
                                                   deviceEditType:GSHDeviceVCTypeAutoTriggerSet
                                           deviceSetCompleteBlock:^(NSArray * _Nonnull exts) {
                                               __strong typeof(weakDeviceM) strongDeviceM = weakDeviceM;
                                               __strong typeof(weakDeviceCell) strongDeviceCell = weakDeviceCell;
                                               [strongDeviceM.exts removeAllObjects];
                                               [strongDeviceM.exts addObjectsFromArray:exts];
                                               strongDeviceCell.rightMiddleLabel.text = [GSHAddAutoVCViewModel getDeviceShowStrWithDeviceM:strongDeviceM];
                                           }];
            } else {
                GSHAutoTriggerConditionListM *triggerConditionListM = self.deviceConditionArray[indexPath.row-1];
                __weak typeof(triggerConditionListM.device) weakDeviceM = triggerConditionListM.device;
                [GSHAddAutoVCViewModel jumpToDeviceHandleVCWithVC:self
                                                          deviceM:triggerConditionListM.device
                                                   deviceEditType:GSHDeviceVCTypeAutoTriggerSet
                                           deviceSetCompleteBlock:^(NSArray * _Nonnull exts) {
                                               __strong typeof(weakDeviceM) strongDeviceM = weakDeviceM;
                                               __strong typeof(weakDeviceCell) strongDeviceCell = weakDeviceCell;
                                               [strongDeviceM.exts removeAllObjects];
                                               [strongDeviceM.exts addObjectsFromArray:exts];
                                               strongDeviceCell.rightMiddleLabel.text = [GSHAddAutoVCViewModel getDeviceShowStrWithDeviceM:strongDeviceM];
                                           }];
            }
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            // 添加执行动作
            GSHAutoAddActionVC *autoAddActionVC = [GSHAutoAddActionVC autoAddActionVC];
            autoAddActionVC.currentAutoId = self.autoM ? self.ossSetAutoM.ruleId.stringValue : @"";
            autoAddActionVC.choosedActionArray = [self.actionArray copy];
            @weakify(self)
            autoAddActionVC.chooseSceneBlock = ^(NSArray *choosedArray , NSArray *noChoosedArray) {
                @strongify(self)
                for (GSHAutoActionListM *actionListM in noChoosedArray) {
                    [self removeFromActionArrayWithActionListM:actionListM type:0];
                }
                if (choosedArray.count > 0) {
                    [self.actionArray addObjectsFromArray:choosedArray];
                }
                [self.addAutoTableView reloadData];
            };
            autoAddActionVC.chooseAutoBlock = ^(NSArray *choosedArray, NSArray *noChoosedArray) {
                @strongify(self)
                for (GSHAutoActionListM *actionListM in noChoosedArray) {
                    [self removeFromActionArrayWithActionListM:actionListM type:1];
                }
                if (choosedArray.count > 0) {
                    [self.actionArray addObjectsFromArray:choosedArray];
                }
                [self.addAutoTableView reloadData];
            };
            autoAddActionVC.chooseDeviceBlock = ^(NSArray *selectedDeviceArray) {
                @strongify(self)
                [self refreshActionArrayWithDeviceArray:selectedDeviceArray];
                [self.addAutoTableView reloadData];
            };
            [self.navigationController pushViewController:autoAddActionVC animated:YES];
        } else {
            GSHAddAutoFiveCell *deviceCell = (GSHAddAutoFiveCell *)[tableView cellForRowAtIndexPath:indexPath];
            GSHAutoActionListM *autoActionListM = self.actionArray[indexPath.row - 1];
            if (autoActionListM.device) {
                // 设备
                __weak typeof(autoActionListM.device) weakDeviceM = autoActionListM.device;
                __weak typeof(deviceCell) weakDeviceCell = deviceCell;
                [GSHAddAutoVCViewModel jumpToDeviceHandleVCWithVC:self
                                                          deviceM:autoActionListM.device
                                                   deviceEditType:GSHDeviceVCTypeAutoActionSet
                                           deviceSetCompleteBlock:^(NSArray * _Nonnull exts) {
                                               __strong typeof(weakDeviceM) strongDeviceM = weakDeviceM;
                                               __strong typeof(weakDeviceCell) strongDeviceCell = weakDeviceCell;
                                               [strongDeviceM.exts removeAllObjects];
                                               [strongDeviceM.exts addObjectsFromArray:exts];
                                               strongDeviceCell.rightMiddleLabel.text = [GSHAddAutoVCViewModel getDeviceShowStrWithDeviceM:strongDeviceM];
                                           }];
            }
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row > 0) {
        NSInteger conditionCount = self.timeStr ? self.deviceConditionArray.count + 1 : self.deviceConditionArray.count;
        NSInteger satisfyRow = self.timeStr ? self.deviceConditionArray.count + 2 : self.deviceConditionArray.count + 1;
        if (conditionCount >= 1 && indexPath.row == satisfyRow) {
            return NO;
        } else {
            return YES;
        }
    }
    if (indexPath.section == 2 && indexPath.row > 0) {
        return YES;
    }
    return NO;
}

// 定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

// 进入编辑模式
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.section == 1) {
            // 触发条件
            if (self.timeStr) {
                if (indexPath.row == 1) {
                    self.timeStr = nil;
                    self.repeatCountStr = nil;
                    [self.addAutoTableView reloadSection:1 withRowAnimation:UITableViewRowAnimationFade];
                    return;
                } else {
                    if (self.deviceConditionArray.count > indexPath.row - 2) {
                        [self.deviceConditionArray removeObjectAtIndex:indexPath.row - 2];
                    }
                }
            } else {
                if (self.deviceConditionArray.count > indexPath.row - 1) {
                    [self.deviceConditionArray removeObjectAtIndex:indexPath.row - 1];
                }
            }
            [self.addAutoTableView reloadData];
        } else if (indexPath.section == 2) {
            // 执行动作
            if (self.actionArray.count > indexPath.row - 1) {
                [self.actionArray removeObjectAtIndex:indexPath.row - 1];
                [self.addAutoTableView reloadData];
            }
        }
    }
}

// 修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

#pragma mark - data handle
// 从当前已选设备数组中，删除已改为未选中的设备
- (void)removeFromSelectDeviceArrayWithDeviceM:(GSHAutoTriggerConditionListM *)triggerConditionListM {
    for (GSHAutoTriggerConditionListM *tmpTriggerConditionListM in self.deviceConditionArray) {
        if (tmpTriggerConditionListM.device) {
            if ([triggerConditionListM.device.deviceId isKindOfClass:NSNumber.class]) {
                if ([tmpTriggerConditionListM.device.deviceId isEqualToNumber:triggerConditionListM.device.deviceId]) {
                    [self.deviceConditionArray removeObject:tmpTriggerConditionListM];
                    break;
                }
            }
        }
    }
}

- (void)removeFromActionArrayWithActionListM:(GSHAutoActionListM *)actionListM type:(int)type {
    for (GSHAutoActionListM *selectActionListM in self.actionArray) {
        if (type == 0) {
            // 情景
            if ([actionListM.scenarioId isKindOfClass:NSNumber.class]) {
                if ([selectActionListM.scenarioId isEqualToNumber:actionListM.scenarioId]) {
                    [self.actionArray removeObject:selectActionListM];
                    break;
                }
            }
        } else if (type == 1){
            // 联动
            if ([actionListM.ruleId isKindOfClass:NSNumber.class]) {
                if ([selectActionListM.ruleId isEqualToNumber:actionListM.ruleId]) {
                    [self.actionArray removeObject:selectActionListM];
                    break;
                }
            }
        } else {
            // 设备
            if ([actionListM.device.deviceId isKindOfClass:NSNumber.class]) {
                if ([selectActionListM.device.deviceId isEqualToNumber:actionListM.device.deviceId]) {
                    [self.actionArray removeObject:selectActionListM];
                    break;
                }
            }
        }
    }
}

// 触发条件 -- 设备选择完成之后，刷新已选择设备情况
- (void)refreshTriggerConditionArrayWithDeviceArray:(NSArray *)deviceArray {
    NSMutableArray *shouldBeAddedArray = [NSMutableArray array];
    for (GSHDeviceM *deviceM in deviceArray) {
        BOOL isIn = NO;
        for (GSHAutoTriggerConditionListM *tmpTriggerConditionListM in self.deviceConditionArray) {
            if ([deviceM.deviceId isKindOfClass:NSNumber.class]) {
                if (tmpTriggerConditionListM.device && [tmpTriggerConditionListM.device.deviceId isEqualToNumber:deviceM.deviceId]) {
                    isIn = YES;
                }
            }
        }
        if (!isIn) {
            GSHAutoTriggerConditionListM *triggerConditionListM = [[GSHAutoTriggerConditionListM alloc] init];
            triggerConditionListM.device = deviceM;
            [shouldBeAddedArray addObject:triggerConditionListM];
        }
    }
    
    NSMutableArray *shouldBeDeleteArray = [NSMutableArray array];
    for (GSHAutoTriggerConditionListM *tmpTriggerConditionListM in self.deviceConditionArray) {
        BOOL isIn = NO;
        for (GSHDeviceM *deviceM in deviceArray) {
            if (tmpTriggerConditionListM.device) {
                if ([tmpTriggerConditionListM.device.deviceId isKindOfClass:NSNumber.class]) {
                    if ([deviceM.deviceId isEqualToNumber:tmpTriggerConditionListM.device.deviceId]) {
                        isIn = YES;
                    }
                }
            } else {
                isIn = YES;
            }
        }
        if (!isIn) {
            [shouldBeDeleteArray addObject:tmpTriggerConditionListM];
        }
    }
    if (shouldBeAddedArray.count > 0) {
        [self.deviceConditionArray addObjectsFromArray:shouldBeAddedArray];
    }
    if (shouldBeDeleteArray.count > 0) {
        [self.deviceConditionArray removeObjectsInArray:shouldBeDeleteArray];
    }
    for (GSHAutoTriggerConditionListM *conditionListM in self.deviceConditionArray) {
        if (conditionListM.device.exts.count == 0) {
            [conditionListM.device.exts addObjectsFromArray:[GSHAddAutoVCViewModel getInitExtsWithDeviceM:conditionListM.device deviceEditType:GSHDeviceVCTypeAutoTriggerSet]];
        }
    }
}

// 执行动作 -- 设备选择完成之后，刷新已选择设备情况
- (void)refreshActionArrayWithDeviceArray:(NSArray *)deviceArray {
    NSMutableArray *shouldBeAddedArray = [NSMutableArray array];
    for (GSHDeviceM *deviceM in deviceArray) {
        BOOL isIn = NO;
        for (GSHAutoActionListM *selectedAutoActionListM in self.actionArray) {
            if (selectedAutoActionListM.device && [deviceM.deviceId isKindOfClass:NSNumber.class]) {
                if ([selectedAutoActionListM.device.deviceId isEqualToNumber:deviceM.deviceId]) {
                    isIn = YES;
                }
            }
        }
        if (!isIn) {
            GSHAutoActionListM *autoActionListM = [[GSHAutoActionListM alloc] init];
            autoActionListM.device = deviceM;
            [shouldBeAddedArray addObject:autoActionListM];
        }
    }
    
    NSMutableArray *shouldBeDeleteArray = [NSMutableArray array];
    for (GSHAutoActionListM *selectedAutoActionListM in self.actionArray) {
        BOOL isIn = NO;
        if (selectedAutoActionListM.device) {
            for (GSHDeviceM *deviceM in deviceArray) {
                if ([selectedAutoActionListM.device.deviceId isKindOfClass:NSNumber.class]) {
                    if ([deviceM.deviceId isEqualToNumber:selectedAutoActionListM.device.deviceId]) {
                        isIn = YES;
                    }
                }
            }
        } else {
            isIn = YES;
        }
        if (!isIn) {
            [shouldBeDeleteArray addObject:selectedAutoActionListM];
        }
    }
    if (shouldBeAddedArray.count > 0) {
        [self.actionArray addObjectsFromArray:shouldBeAddedArray];
    }
    if (shouldBeDeleteArray.count > 0) {
        [self.actionArray removeObjectsInArray:shouldBeDeleteArray];
    }
    for (GSHAutoActionListM *actionListM in self.actionArray) {
        if (actionListM.device.exts.count == 0) {
            [actionListM.device.exts addObjectsFromArray:[GSHAddAutoVCViewModel getInitExtsWithDeviceM:actionListM.device deviceEditType:GSHDeviceVCTypeAutoActionSet]];
        }
    }
}

// 将星期集合转成星期字符串
- (NSString *)getWeekWithWeekIndexSet:(NSIndexSet *)weekIndexSet {
    NSMutableString *str = [NSMutableString stringWithString:@"0000000"];
    for (int i = 6; i >= 0; i --) {
        if (i == 6) {
            if ([weekIndexSet containsIndex:6]) {
                [str replaceCharactersInRange:NSMakeRange(6, 1) withString:@"1"];
            }
        } else {
            if ([weekIndexSet containsIndex:i]) {
                [str replaceCharactersInRange:NSMakeRange(5-i, 1) withString:@"1"];
            }
        }
    }
    return str;
}

// 将星期字符串转成星期集合
- (NSIndexSet *)getWeekIndexSetWithWeek:(NSInteger)week {
    if (week > 127) {
        week = 127;
    }
    NSString *weekStr = [self getBinaryByDecimal:week];
    for (NSInteger i = 7 - weekStr.length; i > 0; i --) {
        weekStr = [NSString stringWithFormat:@"0%@",weekStr];
    }
    NSMutableIndexSet *weekIndexSet = [NSMutableIndexSet indexSet];
    for (NSInteger i = weekStr.length-1; i >= 0; i--) {
        NSString *str = [weekStr substringWithRange:NSMakeRange(i, 1)];
        if ([str isEqualToString:@"1"]) {
            if (i == weekStr.length-1) {
                [weekIndexSet addIndex:6];
            } else {
                [weekIndexSet addIndex:5-i];
            }
        }
    }
    return weekIndexSet;
}

- (NSNumber *)changeStringToTimerWithStr:(NSString *)dateStr {
    NSArray *dataArr = [dateStr componentsSeparatedByString:@":"];
    int hour = ((NSString *)dataArr.firstObject).intValue;
    int minute = ((NSString *)dataArr.lastObject).intValue;
    return @(hour * 3600 + minute * 60);
}

/**
 二进制转换为十进制
 
 @param binary 二进制数
 @return 十进制数
 */
- (NSInteger)getDecimalByBinary:(NSString *)binary {
    
    NSInteger decimal = 0;
    for (int i=0; i<binary.length; i++) {
        
        NSString *number = [binary substringWithRange:NSMakeRange(binary.length - i - 1, 1)];
        if ([number isEqualToString:@"1"]) {
            
            decimal += pow(2, i);
        }
    }
    return decimal;
}

/**
 十进制转换为二进制
 
 @param decimal 十进制数
 @return 二进制数
 */
- (NSString *)getBinaryByDecimal:(NSInteger)decimal {
    
    NSString *binary = @"";
    while (decimal) {
        binary = [[NSString stringWithFormat:@"%ld", decimal % 2] stringByAppendingString:binary];
        if (decimal / 2 < 1) {
            break;
        }
        decimal = decimal / 2 ;
    }
//    if (binary.length % 4 != 0) {
//        NSMutableString *mStr = [[NSMutableString alloc]init];
//        for (int i = 0; i < 4 - binary.length % 4; i++) {
//            [mStr appendString:@"0"];
//        }
//        binary = [mStr stringByAppendingString:binary];
//    }
    return binary;
}


@end

#pragma mark - UITableViewCell
@interface GSHAddAutoOneCell ()

@end

@implementation GSHAddAutoOneCell

@end

@interface GSHAddAutoTwoCell ()

@property (weak, nonatomic) IBOutlet UILabel *typeNameLabel;

@end

@implementation GSHAddAutoTwoCell

- (void)setCellValueWithNameStr:(NSString *)str {
    self.typeNameLabel.text = str;
}

@end

@interface GSHAddAutoThreeCell ()

@property (weak, nonatomic) IBOutlet UILabel *typeNameLabel;

@end

@implementation GSHAddAutoThreeCell

- (void)setCellValueWithNameStr:(NSString *)str {
    self.typeNameLabel.text = str;
}

@end

@interface GSHAddAutoFourCell ()

@end

@implementation GSHAddAutoFourCell


@end

@implementation GSHAddAutoFiveCell


@end
