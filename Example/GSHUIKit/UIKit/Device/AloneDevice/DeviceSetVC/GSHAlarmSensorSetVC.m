//
//  GSHSensorSetVC.m
//  SmartHome
//
//  Created by zhanghong on 2019/5/7.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHAlarmSensorSetVC.h"
#import "UINavigationController+TZM.h"
#import "GSHDeviceEditVC.h"
#import "GSHDeviceInfoDefines.h"

@interface GSHAlarmSensorSetVC ()

@property (weak, nonatomic) IBOutlet UILabel *sensorNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *guideImageView;
@property (weak, nonatomic) IBOutlet UIButton *normalButton;
@property (weak, nonatomic) IBOutlet UIButton *alarmButton;
@property (weak, nonatomic) IBOutlet UIButton *sureButton;

@property (strong, nonatomic) GSHDeviceM *deviceM;
@property (assign, nonatomic) GSHSensorType sensorType;
@property (strong, nonatomic) NSString *alarmMeteId;
@property (assign, nonatomic) GSHDeviceVCType deviceEditType;

@end

@implementation GSHAlarmSensorSetVC

+ (instancetype)alarmSensorSetVCWithDeviceM:(GSHDeviceM *)deviceM
                                 sensorType:(GSHSensorType)sensorType
                             deviceEditType:(GSHDeviceVCType)deviceEditType {
    GSHAlarmSensorSetVC *vc = [TZMPageManager viewControllerWithSB:@"GSHAlarmSensorSetSB" andID:@"GSHAlarmSensorSetVC"];
    vc.deviceM = deviceM;
    vc.sensorType = sensorType;
    vc.deviceEditType = deviceEditType;
    return vc;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tzm_prefersNavigationBarHidden = YES;
    self.sensorNameLabel.text = self.deviceM.deviceName;
    
    NSString *guideImageViewName = @"";
    if (self.sensorType == GSHSomatasensorySensor) {
        // 红外人体传感器
        self.alarmMeteId = GSHSomatasensorySensor_alarmMeteId;
        guideImageViewName = @"somatasensory_set_backImg";
    } else if (self.sensorType == GSHGateMagetismSensor) {
        // 门磁传感器
        self.alarmMeteId = GSHGateMagetismSensor_isOpenedMeteId;
        guideImageViewName = @"gateMagnetism_set_backImg";
    } else if (self.sensorType == GSHGasSensor) {
        // 气体传感器
        self.alarmMeteId = GSHGasSensor_alarmMeteId;
        guideImageViewName = @"gas_img_co";
    } else if (self.sensorType == GSHWaterLoggingSensor) {
        // 水浸传感器
        self.alarmMeteId = GSHWaterLoggingSensor_alarmMeteId;
        guideImageViewName = @"automation_img_water";
    } else if (self.sensorType == GSHInfrareCurtainSensor) {
        // 红外幕帘
        self.alarmMeteId = GSHInfrareCurtain_alarmMeteId;
        guideImageViewName = @"InfrareCurtain_conditionsset";
    } else if (self.sensorType == GSHSOSSensor) {
        // 紧急按钮
        self.alarmMeteId = GSHSOSSensor_alarmMeteId;
        guideImageViewName = @"automation_img_sos_magnet";
    } else if (self.sensorType == GSHAudibleVisualAlarmSensor) {
        // 声光报警器
        self.alarmMeteId = GSHAudibleVisualAlarm_alarmMeteId;
        guideImageViewName = @"audibleVisualAlarm_icon_img";
        [self.alarmButton setTitle:@"响铃" forState:UIControlStateNormal];
        [self.alarmButton setTitle:@"响铃" forState:UIControlStateSelected];
        if (self.deviceEditType == GSHDeviceVCTypeControl) {
            [self.sureButton setTitle:@"进入设备" forState:UIControlStateNormal];
            if ([GSHOpenSDK share].currentFamily.permissions == GSHFamilyMPermissionsMember) {
                // 成员隐藏按钮
                self.sureButton.hidden = YES;
            }
        }
    } else if (self.sensorType == GSHInfrareReactionSensor) {
        // 红外人体感应面板
        self.alarmMeteId = GSHInfrareReaction_alarmMeteId;
        guideImageViewName = @"infraredReaction_icon_img";
    }
    
    self.guideImageView.image = [UIImage imageNamed:guideImageViewName];
    
    if (!(self.deviceEditType == GSHDeviceVCTypeControl && self.sensorType == GSHAudibleVisualAlarmSensor)) {
        // 将声光报警器的控制页面排除在外
        if (self.deviceM.exts.count > 0) {
            GSHDeviceExtM *extM = self.deviceM.exts[0];
            NSString *value = extM.rightValue?extM.rightValue:(extM.param?extM.param:@"");
            if (value.intValue == 1) {
                self.alarmButton.selected = YES;
                self.normalButton.selected = NO;
                [self.alarmButton setBackgroundColor:[UIColor whiteColor]];
                [self.normalButton setBackgroundColor:[UIColor clearColor]];
            } else {
                self.alarmButton.selected = NO;
                self.normalButton.selected = YES;
                [self.alarmButton setBackgroundColor:[UIColor clearColor]];
                [self.normalButton setBackgroundColor:[UIColor whiteColor]];
            }
        } else {
            self.alarmButton.selected = NO;
            self.normalButton.selected = YES;
            [self.alarmButton setBackgroundColor:[UIColor clearColor]];
            [self.normalButton setBackgroundColor:[UIColor whiteColor]];
        }
    }
}


#pragma mark - method

- (IBAction)normalButtonClick:(UIButton *)sender {
    
    if (self.sensorType == GSHAudibleVisualAlarmSensor && self.deviceEditType == GSHDeviceVCTypeControl) {
        [self controlDeviceWithBasMeteId:GSHAudibleVisualAlarm_alarmMeteId value:@"0"];
    } else {
        if (sender.selected) {
            return;
        }
        sender.selected = YES;
        self.alarmButton.selected = NO;
        [self.alarmButton setBackgroundColor:[UIColor clearColor]];
        [self.normalButton setBackgroundColor:[UIColor whiteColor]];
    }
}

- (IBAction)alarmButtonClick:(UIButton *)sender {
    
    if (self.sensorType == GSHAudibleVisualAlarmSensor && self.deviceEditType == GSHDeviceVCTypeControl) {
        [self controlDeviceWithBasMeteId:GSHAudibleVisualAlarm_alarmMeteId value:@"1"];
    } else {
        if (sender.selected) {
            return;
        }
        sender.selected = YES;
        self.normalButton.selected = NO;
        [self.alarmButton setBackgroundColor:[UIColor whiteColor]];
        [self.normalButton setBackgroundColor:[UIColor clearColor]];
    }
    
}

- (IBAction)backButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sureButtonClick:(id)sender {
    if (self.sensorType == GSHAudibleVisualAlarmSensor && self.deviceEditType == GSHDeviceVCTypeControl) {
        // 声光报警器的操作页面
        if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
            [SVProgressHUD showInfoWithStatus:@"离线环境无法查看"];
            return;
        }
        if (!self.deviceM) {
            [SVProgressHUD showErrorWithStatus:@"设备数据出错"];
            return;
        }
        GSHDeviceEditVC *deviceEditVC = [GSHDeviceEditVC deviceEditVCWithDevice:self.deviceM type:GSHDeviceEditVCTypeEdit];
        @weakify(self)
        deviceEditVC.deviceEditSuccessBlock = ^(GSHDeviceM *deviceM) {
            @strongify(self)
            self.deviceM = deviceM;
            self.sensorNameLabel.text = self.deviceM.deviceName;
        };
        [self.navigationController pushViewController:deviceEditVC animated:YES];
    } else {
        NSMutableArray *exts = [NSMutableArray array];
        // 告警
        NSString *triggerMeteId;
        if ([self.deviceM.deviceModel isEqualToNumber:@(-2)] && [self.deviceM.deviceSn containsString:@"_"]) {
            // 通过组合传感器虚拟出来的传感器
            triggerMeteId = [self.deviceM getBaseMeteIdFromDeviceSn:self.deviceM.deviceSn];
        } else {
            triggerMeteId = self.alarmMeteId;
        }
        NSString *triggerValue = self.alarmButton.selected ? @"1" : @"0";
        GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
        extM.basMeteId = triggerMeteId;
        if (self.deviceEditType == GSHDeviceVCTypeSceneSet) {
            extM.rightValue = triggerValue;
            extM.param = self.alarmButton.selected ? @"响铃" : @"正常";
        } else if (self.deviceEditType == GSHDeviceVCTypeAutoTriggerSet) {
            extM.conditionOperator = @"==";
            extM.rightValue = triggerValue;
        } else if (self.deviceEditType == GSHDeviceVCTypeAutoActionSet) {
            extM.param = triggerValue;
        }
        [exts addObject:extM];
        if (self.deviceSetCompleteBlock) {
            self.deviceSetCompleteBlock(exts);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

// 设备控制
- (void)controlDeviceWithBasMeteId:(NSString *)basMeteId
                             value:(NSString *)value {
    
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeWAN) {
        [SVProgressHUD showWithStatus:@"操作中"];
    }
    [GSHDeviceManager deviceControlWithDeviceId:self.deviceM.deviceId.stringValue deviceSN:self.deviceM.deviceSn familyId:[GSHOpenSDK share].currentFamily.familyId basMeteId:basMeteId value:value block:^(NSError *error) {
        if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeWAN) {
            if (error && self == [UIViewController visibleTopViewController]) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            } else {
                [SVProgressHUD dismiss];
            }
        }
    }];
    
}


@end
