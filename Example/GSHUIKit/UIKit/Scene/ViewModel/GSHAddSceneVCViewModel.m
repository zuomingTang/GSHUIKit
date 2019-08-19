//
//  GSHAddSceneVCViewModel.m
//  SmartHome
//
//  Created by zhanghong on 2018/12/18.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import "GSHAddSceneVCViewModel.h"

#import "GSHThreeWaySwitchHandleVC.h"
#import "GSHAirConditionerHandleVC.h"
#import "GSHNewWindHandleVC.h"
#import "GSHDeviceSocketHandleVC.h"
#import "GSHUnderFloorHeatVC.h"
#import "GSHTwoWayCurtainHandleVC.h"
#import "GSHAlarmSensorSetVC.h"
#import "GSHDeviceInfoDefines.h"

@implementation GSHAddSceneVCViewModel

// 添加场景 -- 跳转设备操作页面
+ (void)jumpToDeviceHandleVCWithVC:(UIViewController *)vc
                           deviceM:(GSHDeviceM *)deviceM
            deviceSetCompleteBlock:(void(^)(NSArray *exts))deviceSetCompleteBlock {
    
    if ([deviceM.deviceType isEqualToNumber:GSHNewWindDeviceType]) {
        // 新风面板
        GSHNewWindHandleVC *jumpVC = [GSHNewWindHandleVC newWindHandleVCWithDeviceM:deviceM deviceEditType:GSHDeviceVCTypeSceneSet];
        if (deviceSetCompleteBlock) {
            jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
        }
        jumpVC.hidesBottomBarWhenPushed = YES;
        [vc.navigationController pushViewController:jumpVC animated:YES];
    } else if ([deviceM.deviceType isEqualToNumber:GSHAirConditionerDeviceType]) {
        //空调
        GSHAirConditionerHandleVC *jumpVC = [GSHAirConditionerHandleVC airConditionerHandleVCWithDeviceM:deviceM deviceEditType:GSHDeviceVCTypeSceneSet];
        if (deviceSetCompleteBlock) {
            jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
        }
        jumpVC.hidesBottomBarWhenPushed = YES;
        [vc.navigationController pushViewController:jumpVC animated:YES];
    } else if ([deviceM.deviceType isEqualToNumber:GSHOneWaySwitchDeviceType] ||
               [deviceM.deviceType isEqualToNumber:GSHTwoWaySwitchDeviceType] ||
               [deviceM.deviceType isEqualToNumber:GSHThreeWaySwitchDeviceType]) {
        // 开关
        GSHThreeWaySwitchHandleVC *jumpVC = [GSHThreeWaySwitchHandleVC threeWaySwitchHandleVCWithDeviceM:deviceM deviceEditType:GSHDeviceVCTypeSceneSet];
        if ([deviceM.deviceType isEqualToNumber:GSHOneWaySwitchDeviceType]) {
            jumpVC.switchType = SwitchHandleVCTypeOneWay;
        } else if ([deviceM.deviceType isEqualToNumber:GSHTwoWaySwitchDeviceType]) {
            jumpVC.switchType = SwitchHandleVCTypeTwoWay;
        } else if ([deviceM.deviceType isEqualToNumber:GSHThreeWaySwitchDeviceType]) {
            jumpVC.switchType = SwitchHandleVCTypeThreeWay;
        }
        if (deviceSetCompleteBlock) {
            jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
        }
        jumpVC.hidesBottomBarWhenPushed = YES;
        [vc.navigationController pushViewController:jumpVC animated:YES];
    } else if ([deviceM.deviceType isEqualToNumber:GSHCurtainDeviceType]) {
        // 开合窗帘电机
        GSHTwoWayCurtainHandleVC *jumpVC = [GSHTwoWayCurtainHandleVC twoWayCurtainHandleVCWithDeviceM:deviceM deviceEditType:GSHDeviceVCTypeSceneSet type:GSHTwoWayCurtainMotorHandleVC];
        if (deviceSetCompleteBlock) {
            jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
        }
        jumpVC.hidesBottomBarWhenPushed = YES;
        [vc.navigationController pushViewController:jumpVC animated:YES];
    } else if ([deviceM.deviceType isEqualToNumber:GSHOneWayCurtainDeviceType]) {
        // 一路窗帘开关
        GSHTwoWayCurtainHandleVC *jumpVC = [GSHTwoWayCurtainHandleVC twoWayCurtainHandleVCWithDeviceM:deviceM deviceEditType:GSHDeviceVCTypeSceneSet type:GSHTwoWayCurtainHandleVCOneWay];
        if (deviceSetCompleteBlock) {
            jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
        }
        jumpVC.hidesBottomBarWhenPushed = YES;
        [vc.navigationController pushViewController:jumpVC animated:YES];
    } else if ([deviceM.deviceType isEqualToNumber:GSHTwoWayCurtainDeviceType]) {
        // 二路窗帘开关
        GSHTwoWayCurtainHandleVC *jumpVC = [GSHTwoWayCurtainHandleVC twoWayCurtainHandleVCWithDeviceM:deviceM deviceEditType:GSHDeviceVCTypeSceneSet type:GSHTwoWayCurtainHandleVCTwoWay];
        if (deviceSetCompleteBlock) {
            jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
        }
        jumpVC.hidesBottomBarWhenPushed = YES;
        [vc.navigationController pushViewController:jumpVC animated:YES];
    }else if ([deviceM.deviceType isEqualToNumber:GSHUnderFloorDeviceType]) {
        // 地暖
        GSHUnderFloorHeatVC *jumpVC = [GSHUnderFloorHeatVC underFloorHeatHandleVCDeviceM:deviceM deviceEditType:GSHDeviceVCTypeSceneSet];
        if (deviceSetCompleteBlock) {
            jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
        }
        jumpVC.hidesBottomBarWhenPushed = YES;
        [vc.navigationController pushViewController:jumpVC animated:YES];
    } else if ([deviceM.deviceType isEqualToNumber:GSHSocketDeviceType]) {
        // 智能插座
        GSHDeviceSocketHandleVC *jumpVC = [GSHDeviceSocketHandleVC deviceSocketHandleVCDeviceM:deviceM deviceEditType:GSHDeviceVCTypeSceneSet];
        if (deviceSetCompleteBlock) {
            jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
        }
        jumpVC.hidesBottomBarWhenPushed = YES;
        [vc.navigationController pushViewController:jumpVC animated:YES];
    } else if ([deviceM.deviceType isEqualToNumber:GSHAudibleVisualAlarmDeviceType]) {
        // 声光报警器
        GSHAlarmSensorSetVC *alarmSensorSetVC = [GSHAlarmSensorSetVC alarmSensorSetVCWithDeviceM:deviceM sensorType:GSHAudibleVisualAlarmSensor deviceEditType:GSHDeviceVCTypeSceneSet];
        if (deviceSetCompleteBlock) {
            alarmSensorSetVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
        }
        [vc.navigationController pushViewController:alarmSensorSetVC animated:YES];
    }
}

// 添加场景 -- 设备选择属性拼接显示字符串
+(NSString *)getDeviceShowStrWithDeviceM:(GSHDeviceM *)deviceM {
    NSString *showStr = @"";
    if ([deviceM.deviceType isEqualToNumber:GSHOneWaySwitchDeviceType]) {
        // 一路开关
        NSString *value = deviceM.exts[0].rightValue;
        showStr = [NSString stringWithFormat:@"一路%@",[value intValue] == 0 ? @"关":@"开"];
    } else if ([deviceM.deviceType isEqualToNumber:GSHTwoWaySwitchDeviceType]) {
        // 二路开关
        NSString *value1,*showStr1;
        NSString *value2,*showStr2;
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([extM.basMeteId isEqualToString:GSHTwoWaySwitch_firstMeteId]) {
                value1 = extM.rightValue?extM.rightValue:extM.param;
                if (value1) {
                    showStr1 = [NSString stringWithFormat:@"一路%@",[value1 intValue] == 0 ? @"关":@"开"];
                }
            } else if ([extM.basMeteId isEqualToString:GSHTwoWaySwitch_secondMeteId]) {
                value2 = extM.rightValue?extM.rightValue:extM.param;
                if (value2) {
                    showStr2 = [NSString stringWithFormat:@"二路%@",[value2 intValue] == 0 ? @"关":@"开"];
                }
            }
        }
        NSString  *deviceActionShowStr = @"";
        if (showStr1) {
            if (showStr2) {
                deviceActionShowStr = [NSString stringWithFormat:@"%@ | %@",showStr1,showStr2];
            } else {
                deviceActionShowStr = showStr1;
            }
        } else {
            deviceActionShowStr = showStr2;
        }
        showStr = deviceActionShowStr;
    }  else if ([deviceM.deviceType isEqualToNumber:GSHThreeWaySwitchDeviceType]) {
        // 三路开关
        NSString *value1,*showStr1;
        NSString *value2,*showStr2;
        NSString *value3,*showStr3;
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([extM.basMeteId isEqualToString:GSHThreeWaySwitch_firstMeteId]) {
                value1 = extM.rightValue?extM.rightValue:extM.param;
                if (value1) {
                    showStr1 = [NSString stringWithFormat:@"一路%@",[value1 intValue] == 0 ? @"关":@"开"];
                }
            } else if ([extM.basMeteId isEqualToString:GSHThreeWaySwitch_secondMeteId]) {
                value2 = extM.rightValue?extM.rightValue:extM.param;
                if (value2) {
                    showStr2 = [NSString stringWithFormat:@"二路%@",[value2 intValue] == 0 ? @"关":@"开"];
                }
            } else if ([extM.basMeteId isEqualToString:GSHThreeWaySwitch_thirdMeteId]) {
                value3 = extM.rightValue?extM.rightValue:extM.param;
                if (value3) {
                    showStr3 = [NSString stringWithFormat:@"三路%@",[value3 intValue] == 0 ? @"关":@"开"];
                }
            }
        }
        NSString  *deviceActionShowStr = @"";
        if (showStr1) {
            if (showStr2) {
                if (showStr3) {
                    deviceActionShowStr = [NSString stringWithFormat:@"%@ | %@ | %@",showStr1,showStr2,showStr3];
                } else {
                    deviceActionShowStr = [NSString stringWithFormat:@"%@ | %@",showStr1,showStr2];
                }
            } else {
                if (showStr3) {
                    deviceActionShowStr = [NSString stringWithFormat:@"%@ | %@",showStr1,showStr3];
                } else  {
                    deviceActionShowStr = showStr1;
                }
            }
        } else {
            if (showStr2) {
                if (showStr3) {
                    deviceActionShowStr = [NSString stringWithFormat:@"%@ | %@",showStr2,showStr3];
                } else {
                    deviceActionShowStr = showStr2;
                }
            } else {
                if (showStr3) {
                    deviceActionShowStr = showStr3;
                } else  {
                    deviceActionShowStr = @"";
                }
            }
        }
        showStr = deviceActionShowStr;
    } else if ([deviceM.deviceType isEqualToNumber:GSHNewWindDeviceType]) {
        // 新风
        NSString *value;
        NSString *windSpeedValue;
        NSString *windSpeedStr = @"";
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([extM.basMeteId isEqualToString:GSHNewWind_WindSpeedMeteId]) {
                windSpeedValue = extM.rightValue;
            } else if ([extM.basMeteId isEqualToString:GSHNewWind_SwitchMeteId]) {
                value = extM.rightValue;
            }
        }
        if (windSpeedValue) {
            if ([windSpeedValue isEqualToString:@"1"]) {
                windSpeedStr = @"低风";
            } else if ([windSpeedValue isEqualToString:@"2"]) {
                windSpeedStr = @"中风";
            } else if ([windSpeedValue isEqualToString:@"3"]) {
                windSpeedStr = @"高风";
            }
        }
        
        if ([value intValue] == 0) {
            showStr = @"关";
        } else {
            if (windSpeedStr.length > 0) {
                showStr = [NSString stringWithFormat:@"开 | %@",windSpeedStr];
            } else {
                showStr = @"开";
            }
        }
    } else if ([deviceM.deviceType isEqualToNumber:GSHAirConditionerDeviceType]) {
        // 空调
        NSString *value;
        NSString *modelValue;
        NSString *temperatureValue;
        NSString *windSpeedValue;
        NSString *modelStr = @"";
        NSString *temperatureStr = @"";
        NSString *windSpeedStr = @"";
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([extM.basMeteId isEqualToString:GSHAirConditioner_SwitchMeteId]) {
                value = extM.rightValue;
            }
        }
        if (value.integerValue == 0) {
            // 关
            showStr = @"关";
        } else {
            for (GSHDeviceExtM *extM in deviceM.exts) {
                if ([extM.basMeteId isEqualToString:GSHAirConditioner_ModelMeteId]) {
                    modelValue = extM.rightValue;
                } else if ([extM.basMeteId isEqualToString:GSHAirConditioner_TemperatureMeteId]) {
                    temperatureValue = extM.rightValue;
                } else if ([extM.basMeteId isEqualToString:GSHAirConditioner_WindSpeedMeteId]) {
                    windSpeedValue = extM.rightValue;
                }
            }
            if ([modelValue isEqualToString:@"3"]) {
                modelStr = @"制冷";
            } else if ([modelValue isEqualToString:@"4"]) {
                modelStr = @"制热";
            } else if ([modelValue isEqualToString:@"7"]) {
                modelStr = @"送风";
            } else if ([modelValue isEqualToString:@"8"]) {
                modelStr = @"除湿";
            }
            
            temperatureStr = [NSString stringWithFormat:@"%d˚C",[temperatureValue intValue]];
            
            if (windSpeedValue.integerValue == 1) {
                windSpeedStr = @"低风";
            } else if (windSpeedValue.integerValue == 2) {
                windSpeedStr = @"中风";
            } else if (windSpeedValue.integerValue == 3) {
                windSpeedStr = @"高风";
            }
            
            NSMutableString *attributeStr = [NSMutableString stringWithString:@"开"];
            NSArray *attributeArr = @[temperatureStr,modelStr,windSpeedStr];
            for (NSString *str in attributeArr) {
                if (str.length > 0) {
                    [attributeStr appendString:[NSString stringWithFormat:@" | %@",str]];
                }
            }
            showStr = (NSString *)attributeStr;
        }
    } else if ([deviceM.deviceType isEqualToNumber:GSHCurtainDeviceType] ||
               [deviceM.deviceType isEqualToNumber:GSHOneWayCurtainDeviceType]) {
        // 窗帘电机 & 一路窗帘开关
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([extM.basMeteId isEqualToString:GSHCurtain_SwitchMeteId] ||
                [extM.basMeteId isEqualToString:GSHOneWayCurtain_SwitchMeteId]) {
                NSString *value = extM.rightValue;
                NSString *deviceStateStr = @"";
                if (value.intValue == 0) {
                    deviceStateStr = @"开";
                } else if (value.intValue == 1) {
                    deviceStateStr = @"关";
                } else if (value.intValue == 2) {
                    deviceStateStr = @"暂停";
                }
                showStr = deviceStateStr;
            }
        }
    } else if ([deviceM.deviceType isEqualToNumber:GSHTwoWayCurtainDeviceType]) {
        // 二路窗帘开关
        NSString *value1,*showStr1;
        NSString *value2,*showStr2;
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([extM.basMeteId isEqualToString:GSHTwoWayCurtain_OneSwitchMeteId]) {
                // 一路
                value1 = extM.rightValue?extM.rightValue:extM.param;
                if (value1) {
                    NSString *str = nil;
                    if (value1.integerValue == 0) {
                        str = @"开";
                    } else if (value1.integerValue == 1) {
                        str = @"关";
                    } else {
                        str = @"暂停";
                    }
                    showStr1 = [NSString stringWithFormat:@"一路%@",str];
                }
            } else if ([extM.basMeteId isEqualToString:GSHTwoWayCurtain_TwoSwitchMeteId]) {
                // 二路
                value2 = extM.rightValue?extM.rightValue:extM.param;
                if (value2) {
                    NSString *str = nil;
                    if (value2.integerValue == 0) {
                        str = @"开";
                    } else if (value2.integerValue == 1) {
                        str = @"关";
                    } else {
                        str = @"暂停";
                    }
                    showStr2 = [NSString stringWithFormat:@"二路%@",str];
                }
            }
        }
        NSString  *deviceActionShowStr = @"";
        if (showStr1) {
            if (showStr2) {
                deviceActionShowStr = [NSString stringWithFormat:@"%@ | %@",showStr1,showStr2];
            } else {
                deviceActionShowStr = showStr1;
            }
        } else {
            deviceActionShowStr = showStr2;
        }
        showStr = deviceActionShowStr;
    } else if ([deviceM.deviceType isEqualToNumber:GSHUnderFloorDeviceType]) {
        // 地暖
        NSString *value;
        NSString *temperatureValue;
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([extM.basMeteId isEqualToString:GSHUnderFloor_SwitchMeteId]) {
                value = extM.rightValue;
            }
        }
        if (value.integerValue == 0) {
            // 关
            showStr = @"关";
        } else {
            for (GSHDeviceExtM *extM in deviceM.exts) {
                if ([extM.basMeteId isEqualToString:GSHUnderFloor_TemperatureMeteId]) {
                    temperatureValue = extM.rightValue;
                }
            }
            temperatureValue = [NSString stringWithFormat:@"%d˚C",[temperatureValue intValue]];
            showStr = [NSString stringWithFormat:@"开 | %@",temperatureValue];
        }
    } else if ([deviceM.deviceType isEqualToNumber:GSHSocketDeviceType]) {
        // 智能插座
        NSString *openSwitchValue;
        NSString *usbSwitchValue;
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([extM.basMeteId isEqualToString:GSHSocket_SocketSwitchMeteId]) {
                openSwitchValue = extM.rightValue;
            } else if ([extM.basMeteId isEqualToString:GSHSocket_USBSwitchMeteId]) {
                usbSwitchValue = extM.rightValue;
            }
        }
        if (openSwitchValue && !usbSwitchValue) {
            showStr = [NSString stringWithFormat:@"插座: %@",openSwitchValue.intValue==1?@"开":@"关"];
        } else if (!openSwitchValue && usbSwitchValue) {
            showStr = [NSString stringWithFormat:@"USB: %@",usbSwitchValue.intValue==1?@"开":@"关"];
        } else {
            showStr = [NSString stringWithFormat:@"插座: %@ | USB: %@",openSwitchValue.intValue==1?@"开":@"关",usbSwitchValue.intValue==1?@"开":@"关"];
        }
    } else if ([deviceM.deviceType isEqualToNumber:GSHAudibleVisualAlarmDeviceType]) {
        // 声光报警器
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([deviceM.deviceModel isEqualToNumber:@(-2)] && [deviceM.deviceSn containsString:@"_"] ) {
                // 组合传感器 --
                if ([extM.basMeteId isEqualToString:[deviceM getBaseMeteIdFromDeviceSn:deviceM.deviceSn]]) {
                    showStr = extM.rightValue.intValue == 1 ? @"响铃" : @"正常";
                }
            } else {
                if ([extM.basMeteId isEqualToString:GSHAudibleVisualAlarm_alarmMeteId]) {
                    showStr = extM.rightValue.intValue == 1 ? @"响铃" : @"正常";
                }
            }
        }
    }
    return showStr;
}

// 设备选中时初始值获取
+ (NSArray *)getInitExtsWithDeviceM:(GSHDeviceM *)deviceM {
    NSMutableArray *exts = [NSMutableArray array];
    if ([deviceM.deviceType isEqual:GSHOneWaySwitchDeviceType]) {
        // 一路开关
        [exts addObject:[self extMWithBasMeteId:GSHOneWaySwitch_firstMeteId conditionOperator:@"==" rightValue:@"1"]];
    } else if ([deviceM.deviceType isEqual:GSHTwoWaySwitchDeviceType]) {
        // 二路开关
        for (int i = 0; i < 2; i ++) {
            if (i == 0) {
                [exts addObject:[self extMWithBasMeteId:GSHTwoWaySwitch_firstMeteId conditionOperator:@"==" rightValue:@"1"]];
            } else {
                [exts addObject:[self extMWithBasMeteId:GSHTwoWaySwitch_secondMeteId conditionOperator:@"==" rightValue:@"1"]];
            }
        }
    } else if ([deviceM.deviceType isEqual:GSHThreeWaySwitchDeviceType]) {
        // 三路开关
        for (int i = 0; i < 3; i ++) {
            if (i == 0) {
                [exts addObject:[self extMWithBasMeteId:GSHThreeWaySwitch_firstMeteId conditionOperator:@"==" rightValue:@"1"]];
            } else if (i == 1) {
                [exts addObject:[self extMWithBasMeteId:GSHThreeWaySwitch_secondMeteId conditionOperator:@"==" rightValue:@"1"]];
            } else {
                [exts addObject:[self extMWithBasMeteId:GSHThreeWaySwitch_thirdMeteId conditionOperator:@"==" rightValue:@"1"]];
            }
        }
    } else if ([deviceM.deviceType isEqual:GSHCurtainDeviceType]) {
        // 窗帘电机
        [exts addObject:[self extMWithBasMeteId:GSHCurtain_SwitchMeteId conditionOperator:@"==" rightValue:@"0"]];
    } else if ([deviceM.deviceType isEqual:GSHOneWayCurtainDeviceType]) {
        // 一路窗帘开关
        [exts addObject:[self extMWithBasMeteId:GSHOneWayCurtain_SwitchMeteId conditionOperator:@"==" rightValue:@"0"]];
    } else if ([deviceM.deviceType isEqual:GSHTwoWayCurtainDeviceType]) {
        // 二路窗帘开关
        for (int i = 0; i < 2; i ++) {
            if (i == 0) {
                [exts addObject:[self extMWithBasMeteId:GSHTwoWayCurtain_OneSwitchMeteId conditionOperator:@"==" rightValue:@"0"]];
            } else {
                [exts addObject:[self extMWithBasMeteId:GSHTwoWayCurtain_TwoSwitchMeteId conditionOperator:@"==" rightValue:@"0"]];
            }
        }
    } else if ([deviceM.deviceType isEqual:GSHAirConditionerDeviceType]) {
        // 空调
        // 制冷模式
        [exts addObject:[self extMWithBasMeteId:GSHAirConditioner_ModelMeteId conditionOperator:@"==" rightValue:@"3"]];
        // 风量
        [exts addObject:[self extMWithBasMeteId:GSHAirConditioner_WindSpeedMeteId conditionOperator:@"==" rightValue:@"1"]];
        // 26度
        [exts addObject:[self extMWithBasMeteId:GSHAirConditioner_TemperatureMeteId conditionOperator:@"" rightValue:@"26"]];
        // 默认 开
        [exts addObject:[self extMWithBasMeteId:GSHAirConditioner_SwitchMeteId conditionOperator:@"==" rightValue:@"10"]];
    } else if ([deviceM.deviceType isEqual:GSHNewWindDeviceType]) {
        // 新风
        // 默认 低风
        [exts addObject:[self extMWithBasMeteId:GSHNewWind_WindSpeedMeteId conditionOperator:@"==" rightValue:@"1"]];
        // 默认开
        [exts addObject:[self extMWithBasMeteId:GSHNewWind_SwitchMeteId conditionOperator:@"==" rightValue:@"4"]];
    } else if ([deviceM.deviceType isEqual:GSHUnderFloorDeviceType]) {
        // 地暖
        // 默认 开
        [exts addObject:[self extMWithBasMeteId:GSHUnderFloor_SwitchMeteId conditionOperator:@"==" rightValue:@"10"]];
        // 默认 20度
        [exts addObject:[self extMWithBasMeteId:GSHUnderFloor_TemperatureMeteId conditionOperator:@"==" rightValue:@"20"]];
        
    } else if ([deviceM.deviceType isEqual:GSHSocketDeviceType]) {
        // 插座
        [exts addObject:[self extMWithBasMeteId:GSHSocket_SocketSwitchMeteId conditionOperator:@"==" rightValue:@"1"]];
    } else if ([deviceM.deviceType isEqual:GSHScenePanelDeviceType]) {
        // 场景面板
        [exts addObject:[self extMWithBasMeteId:GSHScenePanel_FirstMeteId conditionOperator:@"==" rightValue:@"1"]];
    } else if ([deviceM.deviceType isEqual:GSHInfrareCurtainDeviceType]) {
        // 红外幕帘
        [exts addObject:[self extMWithBasMeteId:GSHInfrareCurtain_alarmMeteId conditionOperator:@"==" rightValue:@"1"]];
    } else if ([deviceM.deviceType isEqual:GSHAudibleVisualAlarmDeviceType]) {
        // 声光报警器
        [exts addObject:[self extMWithBasMeteId:GSHAudibleVisualAlarm_alarmMeteId conditionOperator:@"==" rightValue:@"1"]];
    }
    return (NSArray *)exts;
}

+ (GSHDeviceExtM *)extMWithBasMeteId:(NSString *)basMeteId
                   conditionOperator:(NSString *)conditionOperator
                          rightValue:(NSString *)rightValue {
    GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
    extM.basMeteId = basMeteId;
    extM.conditionOperator = conditionOperator;
    extM.rightValue = rightValue;
    return extM;
}

@end
