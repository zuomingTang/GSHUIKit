//
//  GSHAddAutoVCViewModel.m
//  SmartHome
//
//  Created by zhanghong on 2018/11/26.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import "GSHAddAutoVCViewModel.h"

#import "GSHThreeWaySwitchHandleVC.h"
#import "GSHAirConditionerHandleVC.h"
#import "GSHNewWindHandleVC.h"
#import "GSHUnderFloorHeatVC.h"
#import "GSHAirConditionerSetVC.h"
#import "GSHScenePanelHandleVC.h"
#import "GSHGateMagnetismSetVC.h"
#import "GSHTwoWayCurtainHandleVC.h"

#import "GSHHumitureSensorSetVC.h"
#import "GSHDeviceSocketHandleVC.h"
#import "GSHAirBoxSensorSetVC.h"

#import "GSHAlarmSensorSetVC.h"
#import "GSHDeviceInfoDefines.h"

@implementation GSHAddAutoVCViewModel

// 添加联动 -- 跳转设备操作页面
+ (void)jumpToDeviceHandleVCWithVC:(UIViewController *)vc
                           deviceM:(GSHDeviceM *)deviceM
                    deviceEditType:(GSHDeviceVCType)deviceEditType
            deviceSetCompleteBlock:(void(^)(NSArray *exts))deviceSetCompleteBlock {
    
    if ([deviceM.deviceType isEqualToNumber:GSHNewWindDeviceType]) {
        // 新风面板
        GSHNewWindHandleVC *jumpVC = [GSHNewWindHandleVC newWindHandleVCWithDeviceM:deviceM deviceEditType:deviceEditType];
        if (deviceSetCompleteBlock) {
            jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
        }
        jumpVC.hidesBottomBarWhenPushed = YES;
        [vc.navigationController pushViewController:jumpVC animated:YES];
    } else if ([deviceM.deviceType isEqualToNumber:GSHAirConditionerDeviceType]) {
        //空调
        if (deviceEditType == GSHDeviceVCTypeAutoTriggerSet) {
            // 触发条件
            GSHAirConditionerSetVC *jumpVC = [GSHAirConditionerSetVC airConditionerSetVCWithDeviceM:deviceM deviceEditType:deviceEditType];
            jumpVC.hidesBottomBarWhenPushed = YES;
            if (deviceSetCompleteBlock) {
                jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
            }
            [vc.navigationController pushViewController:jumpVC animated:YES];
        } else {
            GSHAirConditionerHandleVC *jumpVC = [GSHAirConditionerHandleVC airConditionerHandleVCWithDeviceM:deviceM deviceEditType:deviceEditType];
            jumpVC.hidesBottomBarWhenPushed = YES;
            if (deviceSetCompleteBlock) {
                jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
            }
            [vc.navigationController pushViewController:jumpVC animated:YES];
        }
    } else if ([deviceM.deviceType isEqualToNumber:GSHOneWaySwitchDeviceType] ||
               [deviceM.deviceType isEqualToNumber:GSHTwoWaySwitchDeviceType] ||
               [deviceM.deviceType isEqualToNumber:GSHThreeWaySwitchDeviceType]) {
        // 开关
        GSHThreeWaySwitchHandleVC *jumpVC = [GSHThreeWaySwitchHandleVC threeWaySwitchHandleVCWithDeviceM:deviceM deviceEditType:deviceEditType];
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
        GSHTwoWayCurtainHandleVC *jumpVC = [GSHTwoWayCurtainHandleVC twoWayCurtainHandleVCWithDeviceM:deviceM deviceEditType:deviceEditType type:GSHTwoWayCurtainMotorHandleVC];
        if (deviceSetCompleteBlock) {
            jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
        }
        jumpVC.hidesBottomBarWhenPushed = YES;
        [vc.navigationController pushViewController:jumpVC animated:YES];
    } else if ([deviceM.deviceType isEqualToNumber:GSHOneWayCurtainDeviceType]) {
        // 一路窗帘开关
        GSHTwoWayCurtainHandleVC *jumpVC = [GSHTwoWayCurtainHandleVC twoWayCurtainHandleVCWithDeviceM:deviceM deviceEditType:deviceEditType type:GSHTwoWayCurtainHandleVCOneWay];
        if (deviceSetCompleteBlock) {
            jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
        }
        jumpVC.hidesBottomBarWhenPushed = YES;
        [vc.navigationController pushViewController:jumpVC animated:YES];
    } else if ([deviceM.deviceType isEqualToNumber:GSHTwoWayCurtainDeviceType]) {
        // 二路窗帘开关
        GSHTwoWayCurtainHandleVC *jumpVC = [GSHTwoWayCurtainHandleVC twoWayCurtainHandleVCWithDeviceM:deviceM deviceEditType:deviceEditType type:GSHTwoWayCurtainHandleVCTwoWay];
        if (deviceSetCompleteBlock) {
            jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
        }
        jumpVC.hidesBottomBarWhenPushed = YES;
        [vc.navigationController pushViewController:jumpVC animated:YES];
    } else if ([deviceM.deviceType isEqualToNumber:GSHUnderFloorDeviceType]) {
        // 地暖
        GSHUnderFloorHeatVC *jumpVC = [GSHUnderFloorHeatVC underFloorHeatHandleVCDeviceM:deviceM deviceEditType:deviceEditType];
        if (deviceSetCompleteBlock) {
            jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
        }
        jumpVC.hidesBottomBarWhenPushed = YES;
        [vc.navigationController pushViewController:jumpVC animated:YES];
    } else if ([deviceM.deviceType isEqualToNumber:GSHScenePanelDeviceType]) {
        // 场景面板
        GSHScenePanelHandleVC *jumpVC = [GSHScenePanelHandleVC scenePanelHandleVCDeviceM:deviceM deviceEditType:deviceEditType];
        if (deviceSetCompleteBlock) {
            jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
        }
        [vc.navigationController pushViewController:jumpVC animated:YES];
    } else if ([deviceM.deviceType isEqualToNumber:GSHSocketDeviceType]) {
        // 智能插座
        GSHDeviceSocketHandleVC *jumpVC = [GSHDeviceSocketHandleVC deviceSocketHandleVCDeviceM:deviceM deviceEditType:deviceEditType];
        if (deviceSetCompleteBlock) {
            jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
        }
        jumpVC.hidesBottomBarWhenPushed = YES;
        [vc.navigationController pushViewController:jumpVC animated:YES];
    } else if ([deviceM.deviceType isEqualToNumber:GSHAirBoxSensorDeviceType]) {
        // 空气盒子 （PM2.5 + 温湿度）
        GSHAirBoxSensorSetVC *jumpVC = [GSHAirBoxSensorSetVC airBoxSensorSetVCWithDeviceM:deviceM];
        if (deviceSetCompleteBlock) {
            jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
        }
        [vc.navigationController pushViewController:jumpVC animated:YES];
    } else if ([deviceM.deviceType isEqualToNumber:GSHHumitureSensorDeviceType]) {
        // 温湿度传感器
        GSHHumitureSensorSetVC *jumpVC = [GSHHumitureSensorSetVC humitureSensorSetVCWithDeviceM:deviceM];
        if (deviceSetCompleteBlock) {
            jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
        }
        [vc.navigationController pushViewController:jumpVC animated:YES];
    } else if ([deviceM.deviceType isEqualToNumber:GSHGateMagetismSensorDeviceType]) {
        // 门磁
        GSHGateMagnetismSetVC *jumpVC = [GSHGateMagnetismSetVC gateMagnetismSetVCWithDeviceM:deviceM];
        if (deviceSetCompleteBlock) {
            jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
        }
        [vc.navigationController pushViewController:jumpVC animated:YES];
    } else if ([deviceM.deviceType isEqualToNumber:GSHSomatasensorySensorDeviceType] ||
             [deviceM.deviceType isEqualToNumber:GSHWaterLoggingSensorDeviceType] ||
             [deviceM.deviceType isEqualToNumber:GSHGasSensorDeviceType] ||
             [deviceM.deviceType isEqualToNumber:GSHSOSSensorDeviceType] ||
             [deviceM.deviceType isEqualToNumber:GSHInfrareCurtainDeviceType] ||
             [deviceM.deviceType isEqualToNumber:GSHAudibleVisualAlarmDeviceType] ||
             [deviceM.deviceType isEqualToNumber:GSHInfrareReactionDeviceType]) {
        NSInteger sensorType;
        if ([deviceM.deviceType isEqualToNumber:GSHSomatasensorySensorDeviceType]) {
            // 人体红外传感器
            sensorType = GSHSomatasensorySensor;
        } else if ([deviceM.deviceType isEqualToNumber:GSHWaterLoggingSensorDeviceType]) {
            // 水浸传感器
            sensorType = GSHWaterLoggingSensor;
        } else if ([deviceM.deviceType isEqualToNumber:GSHGasSensorDeviceType]) {
            // 气体传感器
            sensorType = GSHGasSensor;
        } else if ([deviceM.deviceType isEqualToNumber:GSHSOSSensorDeviceType]) {
            // 紧急按钮
            sensorType = GSHSOSSensor;
        } else if ([deviceM.deviceType isEqualToNumber:GSHInfrareCurtainDeviceType]) {
            // 红外幕帘
            sensorType = GSHInfrareCurtainSensor;
        } else if ([deviceM.deviceType isEqualToNumber:GSHAudibleVisualAlarmDeviceType]) {
            // 声光报警器
            sensorType = GSHAudibleVisualAlarmSensor;
        } else {
            // 红外人体感应面板
            sensorType = GSHInfrareReactionSensor;
        }
        GSHAlarmSensorSetVC *alarmSensorSetVC = [GSHAlarmSensorSetVC alarmSensorSetVCWithDeviceM:deviceM sensorType:sensorType deviceEditType:deviceEditType];
        if (deviceSetCompleteBlock) {
            alarmSensorSetVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
        }
        [vc.navigationController pushViewController:alarmSensorSetVC animated:YES];
    }
}

// 添加联动 -- 设备选择属性拼接显示字符串
+(NSString *)getDeviceShowStrWithDeviceM:(GSHDeviceM *)deviceM {
    
    NSString *showStr = @"";
    if ([deviceM.deviceType isEqualToNumber:GSHOneWaySwitchDeviceType]) {
        // 一路开关
        NSString *value = deviceM.exts[0].rightValue?deviceM.exts[0].rightValue:deviceM.exts[0].param;
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
        NSString *windSpeedStr;
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([extM.basMeteId isEqualToString:GSHNewWind_SwitchMeteId]) {
                value = extM.rightValue?extM.rightValue:extM.param;
            } else if ([extM.basMeteId isEqualToString:GSHNewWind_WindSpeedMeteId]) {
                NSString *windSpeedValue = extM.rightValue?extM.rightValue:extM.param;
                if ([windSpeedValue isEqualToString:@"1"]) {
                    windSpeedStr = @"低风";
                } else if ([windSpeedValue isEqualToString:@"2"]) {
                    windSpeedStr = @"中风";
                } else if ([windSpeedValue isEqualToString:@"3"]) {
                    windSpeedStr = @"高风";
                }
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
        NSString *windSpeedValue;
        NSString *temperatureValue;
        NSString *operator=@"";
        NSString *modelStr = @"";
        NSString *windSpeedStr = @"";
        NSString *temperatureStr = @"";
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([extM.basMeteId isEqualToString:GSHAirConditioner_SwitchMeteId]) {
                value = extM.rightValue?extM.rightValue:extM.param;
            }
        }
        if (value.integerValue == 0) {
            // 关
            showStr = @"关";
        } else {
            for (GSHDeviceExtM *extM in deviceM.exts) {
                if ([extM.basMeteId isEqualToString:GSHAirConditioner_ModelMeteId]) {
                    modelValue = extM.rightValue?extM.rightValue:extM.param;
                } else if ([extM.basMeteId isEqualToString:GSHAirConditioner_TemperatureMeteId]) {
                    operator = extM.conditionOperator;
                    temperatureValue = extM.rightValue?extM.rightValue:extM.param;
                } else if ([extM.basMeteId isEqualToString:GSHAirConditioner_WindSpeedMeteId]) {
                    windSpeedValue = extM.rightValue?extM.rightValue:extM.param;
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
            
            if (windSpeedValue.integerValue == 1) {
                windSpeedStr = @"低风";
            } else if (windSpeedValue.integerValue == 2) {
                windSpeedStr = @"中风";
            } else if (windSpeedValue.integerValue == 3) {
                windSpeedStr = @"高风";
            }
            
            if (temperatureValue) {
                if (operator.length > 0) {
                    temperatureStr = [NSString stringWithFormat:@"%@%d˚C",operator,[temperatureValue intValue]];
                } else {
                    temperatureStr = [NSString stringWithFormat:@"%d˚C",[temperatureValue intValue]];
                }
            }
            
            NSMutableString *attributeStr = [NSMutableString stringWithString:@"开"];
            NSArray *attributeArr = @[temperatureStr,modelStr,windSpeedStr];
            for (NSString *str in attributeArr) {
                if (str.length > 0) {
                    [attributeStr appendString:[NSString stringWithFormat:@"| %@",str]];
                }
            }
            showStr = (NSString *)attributeStr;
        }
    } else if ([deviceM.deviceType isEqualToNumber:GSHCurtainDeviceType] ||
               [deviceM.deviceType isEqualToNumber:GSHOneWayCurtainDeviceType]) {
        // 窗帘电机 & 一路窗帘开关
        NSString *value = deviceM.exts[0].rightValue?deviceM.exts[0].rightValue:deviceM.exts[0].param;
        NSString *deviceStateStr = @"";
        if (value.intValue == 0) {
            deviceStateStr = @"开";
        } else if (value.intValue == 1) {
            deviceStateStr = @"关";
        } else if (value.intValue == 2) {
            deviceStateStr = @"暂停";
        }
        showStr = deviceStateStr;
        
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
                value = extM.rightValue?extM.rightValue:(extM.param?extM.param:@"");
            }
        }
        if (value.length > 0) {
            if (value.integerValue == 0) {
                // 关
                showStr = @"关";
            } else {
                showStr = @"开";
                for (GSHDeviceExtM *extM in deviceM.exts) {
                    if ([extM.basMeteId isEqualToString:GSHUnderFloor_TemperatureMeteId]) {
                        temperatureValue = extM.rightValue?extM.rightValue:(extM.param?extM.param:@"");
                    }
                }
                if (temperatureValue.length > 0) {
                    temperatureValue = [NSString stringWithFormat:@"%d˚C",[temperatureValue intValue]];
                    showStr = [NSString stringWithFormat:@"开 | %@",temperatureValue];
                }
            }
        }
    } else if ([deviceM.deviceType isEqualToNumber:GSHScenePanelDeviceType]) {
        // 场景面板
        NSArray *arr = @[@"第一路",@"第二路",@"第三路",@"第四路",@"第五路",@"第六路"];
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if (extM.rightValue.integerValue > 0 && extM.rightValue.integerValue < 7) {
                showStr = arr[extM.rightValue.intValue-1];
            } else {
                showStr = @"数据错误";
            }
        }
    } else if ([deviceM.deviceType isEqualToNumber:GSHSocketDeviceType]) {
        // 智能插座
        NSString *openSwitchValue;
        NSString *usbSwitchValue;
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([extM.basMeteId isEqualToString:GSHSocket_SocketSwitchMeteId]) {
                openSwitchValue = extM.rightValue?extM.rightValue:extM.param;
            } else if ([extM.basMeteId isEqualToString:GSHSocket_USBSwitchMeteId]) {
                usbSwitchValue = extM.rightValue?extM.rightValue:extM.param;
            }
        }
        if (openSwitchValue && !usbSwitchValue) {
            showStr = [NSString stringWithFormat:@"插座: %@",openSwitchValue.intValue==1?@"开":@"关"];
        } else if (!openSwitchValue && usbSwitchValue) {
            showStr = [NSString stringWithFormat:@"USB: %@",usbSwitchValue.intValue==1?@"开":@"关"];
        } else if (openSwitchValue && usbSwitchValue) {
            showStr = [NSString stringWithFormat:@"插座: %@ | USB: %@",openSwitchValue.intValue==1?@"开":@"关",usbSwitchValue.intValue==1?@"开":@"关"];
        }
    } else if ([deviceM.deviceType isEqualToNumber:GSHSomatasensorySensorDeviceType]) {
        // 体感传感器 -- 仅在触发条件出现
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([deviceM.deviceModel isEqualToNumber:@(-2)] && [deviceM.deviceSn containsString:@"_"] ) {
                // 组合传感器 --
                if ([extM.basMeteId isEqualToString:[deviceM getBaseMeteIdFromDeviceSn:deviceM.deviceSn]]) {
                    showStr = extM.rightValue.intValue == 1 ? @"告警" : @"正常";
                }
            } else {
                if ([extM.basMeteId isEqualToString:GSHSomatasensorySensor_alarmMeteId]) {
                    showStr = extM.rightValue.intValue == 1 ? @"告警" : @"正常";
                }
            }
        }
    } else if ([deviceM.deviceType isEqualToNumber:GSHGateMagetismSensorDeviceType]) {
        // 门磁 -- 仅在触发条件出现
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([deviceM.deviceModel isEqualToNumber:@(-2)] && [deviceM.deviceSn containsString:@"_"] ) {
                // 组合传感器 --
                if ([extM.basMeteId isEqualToString:[deviceM getBaseMeteIdFromDeviceSn:deviceM.deviceSn]]) {
                    showStr = extM.rightValue.intValue == 1 ? @"被打开" : @"被关闭";
                }
            } else {
                if ([extM.basMeteId isEqualToString:GSHGateMagetismSensor_isOpenedMeteId]) {
                    showStr = extM.rightValue.intValue == 1 ? @"被打开" : @"被关闭";
                }
            }
        }
    } else if ([deviceM.deviceType isEqualToNumber:GSHHumitureSensorDeviceType]) {
        // 温湿度传感器
        NSString *temStr;
        NSString *humStr;
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([extM.basMeteId isEqualToString:GSHHumitureSensor_temMeteId]) {
                temStr = [NSString stringWithFormat:@"温度: %@%@",[extM.conditionOperator isEqualToString:@">"] ? @"高于" : @"低于",extM.rightValue];
            } else if ([extM.basMeteId isEqualToString:GSHHumitureSensor_humMeteId]) {
                humStr = [NSString stringWithFormat:@"湿度: %@%@",[extM.conditionOperator isEqualToString:@">"] ? @"高于" : @"低于",extM.rightValue];
            }
        }
        if (temStr && !humStr) {
            showStr = temStr;
        } else if (!temStr && humStr) {
            showStr = humStr;
        } else {
            showStr = [NSString stringWithFormat:@"%@ | %@",temStr,humStr];
        }
    } else if ([deviceM.deviceType isEqualToNumber:GSHAirBoxSensorDeviceType]) {
        // 空气盒子
        NSString *temStr = @"";
        NSString *humStr = @"";
        NSString *pmStr = @"";
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([extM.basMeteId isEqualToString:GSHAirBoxSensor_temMeteId]) {
                temStr = [NSString stringWithFormat:@"%@%@˚C",[extM.conditionOperator isEqualToString:@">"] ? @"高于" : @"低于",extM.rightValue];
            } else if ([extM.basMeteId isEqualToString:GSHAirBoxSensor_humMeteId]) {
                humStr = [NSString stringWithFormat:@"%@%@%%",[extM.conditionOperator isEqualToString:@">"] ? @"高于" : @"低于",extM.rightValue];
            } else if ([extM.basMeteId isEqualToString:GSHAirBoxSensor_pmMeteId]) {
                pmStr = [self airBoxPmStrWithDeviceExtM:extM];
            }
        }
        
        NSMutableString *attributeStr = [NSMutableString stringWithString:@""];
        NSArray *attributeArr = @[pmStr,temStr,humStr];
        for (NSString *str in attributeArr) {
            if (str.length > 0) {
                [attributeStr appendString:[NSString stringWithFormat:@"%@ | ",str]];
            }
        }
        if (attributeStr.length > 0) {
            attributeStr = [[attributeStr substringToIndex:attributeStr.length-3] mutableCopy];
        }
        showStr = attributeStr;
    }  else if ([deviceM.deviceType isEqualToNumber:GSHWaterLoggingSensorDeviceType]) {
        // 水浸传感器
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([deviceM.deviceModel isEqualToNumber:@(-2)] && [deviceM.deviceSn containsString:@"_"] ) {
                // 组合传感器 --
                if ([extM.basMeteId isEqualToString:[deviceM getBaseMeteIdFromDeviceSn:deviceM.deviceSn]]) {
                    showStr = extM.rightValue.intValue == 1 ? @"告警" : @"正常";
                }
            } else {
                if ([extM.basMeteId isEqualToString:GSHWaterLoggingSensor_alarmMeteId]) {
                    showStr = extM.rightValue.intValue == 1 ? @"告警" : @"正常";
                }
            }
        }
    } else if ([deviceM.deviceType isEqualToNumber:GSHGasSensorDeviceType]) {
        // 气体传感器
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([deviceM.deviceModel isEqualToNumber:@(-2)] && [deviceM.deviceSn containsString:@"_"] ) {
                // 组合传感器 --
                if ([extM.basMeteId isEqualToString:[deviceM getBaseMeteIdFromDeviceSn:deviceM.deviceSn]]) {
                    showStr = extM.rightValue.intValue == 1 ? @"告警" : @"正常";
                }
            } else {
                if ([extM.basMeteId isEqualToString:GSHGasSensor_alarmMeteId]) {
                    showStr = extM.rightValue.intValue == 1 ? @"告警" : @"正常";
                }
            }
        }
    } else if ([deviceM.deviceType isEqualToNumber:GSHSOSSensorDeviceType]) {
        // 紧急按钮
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([deviceM.deviceModel isEqualToNumber:@(-2)] && [deviceM.deviceSn containsString:@"_"] ) {
                // 组合传感器 --
                if ([extM.basMeteId isEqualToString:[deviceM getBaseMeteIdFromDeviceSn:deviceM.deviceSn]]) {
                    showStr = extM.rightValue.intValue == 1 ? @"告警" : @"正常";
                }
            } else {
                if ([extM.basMeteId isEqualToString:GSHSOSSensor_alarmMeteId]) {
                    showStr = extM.rightValue.intValue == 1 ? @"告警" : @"正常";
                }
            }
        }
    } else if ([deviceM.deviceType isEqualToNumber:GSHInfrareCurtainDeviceType]) {
        // 红外幕帘 -- 仅在触发条件出现
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([deviceM.deviceModel isEqualToNumber:@(-2)] && [deviceM.deviceSn containsString:@"_"] ) {
                // 组合传感器 --
                if ([extM.basMeteId isEqualToString:[deviceM getBaseMeteIdFromDeviceSn:deviceM.deviceSn]]) {
                    showStr = extM.rightValue.intValue == 1 ? @"告警" : @"正常";
                }
            } else {
                if ([extM.basMeteId isEqualToString:GSHInfrareCurtain_alarmMeteId]) {
                    showStr = extM.rightValue.intValue == 1 ? @"告警" : @"正常";
                }
            }
        }
    } else if ([deviceM.deviceType isEqualToNumber:GSHAudibleVisualAlarmDeviceType]) {
        // 声光报警器 -- 仅在触发条件出现
        for (GSHDeviceExtM *extM in deviceM.exts) {
            NSString *str = extM.rightValue?extM.rightValue:extM.param;
            if ([deviceM.deviceModel isEqualToNumber:@(-2)] && [deviceM.deviceSn containsString:@"_"] ) {
                // 组合传感器 --
                if ([extM.basMeteId isEqualToString:[deviceM getBaseMeteIdFromDeviceSn:deviceM.deviceSn]]) {
                    showStr = str.intValue == 1 ? @"响铃" : @"正常";
                }
            } else {
                if ([extM.basMeteId isEqualToString:GSHAudibleVisualAlarm_alarmMeteId]) {
                    showStr = str.intValue == 1 ? @"响铃" : @"正常";
                }
            }
        }
    } else if ([deviceM.deviceType isEqualToNumber:GSHInfrareReactionDeviceType]) {
        // 红外人体感应面板 -- 仅在触发条件出现
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([deviceM.deviceModel isEqualToNumber:@(-2)] && [deviceM.deviceSn containsString:@"_"] ) {
                // 组合传感器 --
                if ([extM.basMeteId isEqualToString:[deviceM getBaseMeteIdFromDeviceSn:deviceM.deviceSn]]) {
                    showStr = extM.rightValue.intValue == 1 ? @"告警" : @"正常";
                }
            } else {
                if ([extM.basMeteId isEqualToString:GSHInfrareReaction_alarmMeteId]) {
                    showStr = extM.rightValue.intValue == 1 ? @"告警" : @"正常";
                }
            }
        }
    }
    return showStr;
}

/*
 else if (monitorM.valueString.integerValue>=75 && monitorM.valueString.integerValue<115) {
 // 轻度污染
 str = @"轻度污染";
 } else if (monitorM.valueString.integerValue>=115 && monitorM.valueString.integerValue<150) {
 // 中度污染
 str = @"中度污染";
 } else if (monitorM.valueString.integerValue>=150 && monitorM.valueString.integerValue<250) {
 // 重度污染
 str = @"重度污染";
 } else if (monitorM.valueString.integerValue>=250) {
 // 严重污染
 str = @"严重污染";
 }
 */
+ (NSString *)airBoxPmStrWithDeviceExtM:(GSHDeviceExtM *)deviceExtM {
    NSString *str = @"轻度污染";
    if (deviceExtM.rightValue.integerValue == 35) {
        str = @"优";
    } else if ([deviceExtM.conditionOperator isEqualToString:@"<"] && deviceExtM.rightValue.integerValue == 75) {
        str = @"良";
    } else if ([deviceExtM.conditionOperator isEqualToString:@">"] && deviceExtM.rightValue.integerValue == 75) {
        str = @"轻度污染";
    } else if (deviceExtM.rightValue.integerValue == 115) {
        str = @"中度污染";
    } else if (deviceExtM.rightValue.integerValue == 150) {
        str = @"重度污染";
    } else if (deviceExtM.rightValue.integerValue == 250) {
        str = @"严重污染";
    }
    return str;
}

+ (NSArray *)airBoxPmExtMWithPmStr:(NSString *)pmStr {
    NSMutableArray *arr = [NSMutableArray array];
    GSHDeviceExtM *deviceExtM1 = [[GSHDeviceExtM alloc] init];
    deviceExtM1.basMeteId = GSHAirBoxSensor_pmMeteId;
    if ([pmStr isEqualToString:@"优"]) {
        deviceExtM1.conditionOperator = @"<";
        deviceExtM1.rightValue = @"35";
    } else if ([pmStr isEqualToString:@"良"]) {
        deviceExtM1.conditionOperator = @"<";
        deviceExtM1.rightValue = @"75";
    } else if ([pmStr isEqualToString:@"轻度污染"]) {
        deviceExtM1.conditionOperator = @">";
        deviceExtM1.rightValue = @"75";
    } else if ([pmStr isEqualToString:@"中度污染"]) {
        deviceExtM1.conditionOperator = @">";
        deviceExtM1.rightValue = @"115";
    } else if ([pmStr isEqualToString:@"重度污染"]) {
        deviceExtM1.conditionOperator = @">";
        deviceExtM1.rightValue = @"150";
    } else if ([pmStr isEqualToString:@"严重污染"]) {
        deviceExtM1.conditionOperator = @">";
        deviceExtM1.rightValue = @"250";
    }
    [arr addObject:deviceExtM1];
    
    return arr;
}

// 设备选中时初始值获取
+ (NSArray *)getInitExtsWithDeviceM:(GSHDeviceM *)deviceM deviceEditType:(GSHDeviceVCType)deviceEditType {
    NSMutableArray *exts = [NSMutableArray array];
    if ([deviceM.deviceModel isEqualToNumber:@(-2)] && [deviceM.deviceSn containsString:@"_"]) {
        // 虚拟传感器
        [exts addObject:[self extMWithBasMeteId:[deviceM getBaseMeteIdFromDeviceSn:deviceM.deviceSn] conditionOperator:@"==" rightValue:@"1" deviceEditType:deviceEditType]];
    } else {
        if ([deviceM.deviceType isEqual:GSHOneWaySwitchDeviceType]) {
            // 一路开关
            [exts addObject:[self extMWithBasMeteId:GSHOneWaySwitch_firstMeteId conditionOperator:@"==" rightValue:@"1" deviceEditType:deviceEditType]];
        } else if ([deviceM.deviceType isEqual:GSHTwoWaySwitchDeviceType]) {
            // 二路开关
            for (int i = 0; i < 2; i ++) {
                if (i == 0) {
                    [exts addObject:[self extMWithBasMeteId:GSHTwoWaySwitch_firstMeteId conditionOperator:@"==" rightValue:@"1" deviceEditType:deviceEditType]];
                } else {
                    [exts addObject:[self extMWithBasMeteId:GSHTwoWaySwitch_secondMeteId conditionOperator:@"==" rightValue:@"1" deviceEditType:deviceEditType]];
                }
            }
        } else if ([deviceM.deviceType isEqual:GSHThreeWaySwitchDeviceType]) {
            // 三路开关
            for (int i = 0; i < 3; i ++) {
                if (i == 0) {
                    [exts addObject:[self extMWithBasMeteId:GSHThreeWaySwitch_firstMeteId conditionOperator:@"==" rightValue:@"1" deviceEditType:deviceEditType]];
                } else if (i == 1) {
                    [exts addObject:[self extMWithBasMeteId:GSHThreeWaySwitch_secondMeteId conditionOperator:@"==" rightValue:@"1" deviceEditType:deviceEditType]];
                } else {
                    [exts addObject:[self extMWithBasMeteId:GSHThreeWaySwitch_thirdMeteId conditionOperator:@"==" rightValue:@"1" deviceEditType:deviceEditType]];
                }
            }
        } else if ([deviceM.deviceType isEqual:GSHCurtainDeviceType]) {
            // 窗帘电机
            [exts addObject:[self extMWithBasMeteId:GSHCurtain_SwitchMeteId conditionOperator:@"==" rightValue:@"0" deviceEditType:deviceEditType]];
        } else if ([deviceM.deviceType isEqual:GSHOneWayCurtainDeviceType]) {
            // 一路窗帘开关
            [exts addObject:[self extMWithBasMeteId:GSHOneWayCurtain_SwitchMeteId conditionOperator:@"==" rightValue:@"0" deviceEditType:deviceEditType]];
        } else if ([deviceM.deviceType isEqual:GSHTwoWayCurtainDeviceType]) {
            // 二路窗帘开关
            for (int i = 0; i < 2; i ++) {
                if (i == 0) {
                    [exts addObject:[self extMWithBasMeteId:GSHTwoWayCurtain_OneSwitchMeteId conditionOperator:@"==" rightValue:@"0" deviceEditType:deviceEditType]];
                } else {
                    [exts addObject:[self extMWithBasMeteId:GSHTwoWayCurtain_TwoSwitchMeteId conditionOperator:@"==" rightValue:@"0" deviceEditType:deviceEditType]];
                }
            }
        } else if ([deviceM.deviceType isEqual:GSHAirConditionerDeviceType]) {
            // 空调
            // 制冷模式
            [exts addObject:[self extMWithBasMeteId:GSHAirConditioner_ModelMeteId conditionOperator:@"==" rightValue:@"3" deviceEditType:deviceEditType]];
            if (deviceEditType == GSHDeviceVCTypeAutoTriggerSet) {
                // 联动 -- 触发条件
                // 高于26度
                [exts addObject:[self extMWithBasMeteId:GSHAirConditioner_TemperatureMeteId conditionOperator:@">" rightValue:@"26" deviceEditType:deviceEditType]];
            } else if (deviceEditType == GSHDeviceVCTypeAutoActionSet) {
                // 联动 -- 执行动作
                // 风量
                [exts addObject:[self extMWithBasMeteId:GSHAirConditioner_WindSpeedMeteId conditionOperator:@"==" rightValue:@"1" deviceEditType:deviceEditType]];
                // 26度
                [exts addObject:[self extMWithBasMeteId:GSHAirConditioner_TemperatureMeteId conditionOperator:@"" rightValue:@"26" deviceEditType:deviceEditType]];
                
            }
            [exts addObject:[self extMWithBasMeteId:GSHAirConditioner_SwitchMeteId conditionOperator:@"==" rightValue:@"10" deviceEditType:deviceEditType]];
        } else if ([deviceM.deviceType isEqual:GSHNewWindDeviceType]) {
            // 新风
            // 默认 低风
            [exts addObject:[self extMWithBasMeteId:GSHNewWind_WindSpeedMeteId conditionOperator:@"==" rightValue:@"1" deviceEditType:deviceEditType]];
            // 默认开
            [exts addObject:[self extMWithBasMeteId:GSHNewWind_SwitchMeteId conditionOperator:@"==" rightValue:@"4" deviceEditType:deviceEditType]];
        } else if ([deviceM.deviceType isEqual:GSHUnderFloorDeviceType]) {
            // 地暖
            // 默认 开
            [exts addObject:[self extMWithBasMeteId:GSHUnderFloor_SwitchMeteId conditionOperator:@"==" rightValue:@"10" deviceEditType:deviceEditType]];
            // 默认 20度
            [exts addObject:[self extMWithBasMeteId:GSHUnderFloor_TemperatureMeteId conditionOperator:@"==" rightValue:@"20" deviceEditType:deviceEditType]];
        } else if ([deviceM.deviceType isEqual:GSHSocketDeviceType]) {
            // 插座
            [exts addObject:[self extMWithBasMeteId:GSHSocket_SocketSwitchMeteId conditionOperator:@"==" rightValue:@"1" deviceEditType:deviceEditType]];
        } else if ([deviceM.deviceType isEqual:GSHScenePanelDeviceType]) {
            // 场景面板
            [exts addObject:[self extMWithBasMeteId:GSHScenePanel_FirstMeteId conditionOperator:@"==" rightValue:@"1" deviceEditType:deviceEditType]];
        } else if ([deviceM.deviceType isEqual:GSHHumitureSensorDeviceType]) {
            // 温湿度传感器
            for (int i = 0; i < 2; i ++) {
                if (i == 0) {
                    [exts addObject:[self extMWithBasMeteId:GSHHumitureSensor_temMeteId conditionOperator:@">" rightValue:@"26" deviceEditType:deviceEditType]];
                } else {
                    [exts addObject:[self extMWithBasMeteId:GSHHumitureSensor_humMeteId conditionOperator:@">" rightValue:@"68" deviceEditType:deviceEditType]];
                }
            }
        } else if ([deviceM.deviceType isEqual:GSHSomatasensorySensorDeviceType]) {
            // 人体红外传感器
            [exts addObject:[self extMWithBasMeteId:GSHSomatasensorySensor_alarmMeteId conditionOperator:@"==" rightValue:@"1" deviceEditType:deviceEditType]];
        } else if ([deviceM.deviceType isEqual:GSHGateMagetismSensorDeviceType]) {
            // 门磁
            [exts addObject:[self extMWithBasMeteId:GSHGateMagetismSensor_isOpenedMeteId conditionOperator:@"==" rightValue:@"1" deviceEditType:deviceEditType]];
        } else if ([deviceM.deviceType isEqual:GSHGasSensorDeviceType]) {
            // 气体传感器
            [exts addObject:[self extMWithBasMeteId:GSHGasSensor_alarmMeteId conditionOperator:@"==" rightValue:@"1" deviceEditType:deviceEditType]];
        } else if ([deviceM.deviceType isEqual:GSHWaterLoggingSensorDeviceType]) {
            // 水浸传感器
            [exts addObject:[self extMWithBasMeteId:GSHWaterLoggingSensor_alarmMeteId conditionOperator:@"==" rightValue:@"1" deviceEditType:deviceEditType]];
        } else if ([deviceM.deviceType isEqual:GSHAirBoxSensorDeviceType]) {
            // 空气盒子
            for (int i = 0; i < 3; i ++) {
                if (i == 0) {
                    [exts addObject:[self extMWithBasMeteId:GSHAirBoxSensor_temMeteId conditionOperator:@">" rightValue:@"26" deviceEditType:deviceEditType]];
                } else if(i == 1){
                    [exts addObject:[self extMWithBasMeteId:GSHAirBoxSensor_humMeteId conditionOperator:@">" rightValue:@"68" deviceEditType:deviceEditType]];
                } else {
                    [exts addObject:[self extMWithBasMeteId:GSHAirBoxSensor_pmMeteId conditionOperator:@">" rightValue:@"75" deviceEditType:deviceEditType]];
                }
            }
        } else if ([deviceM.deviceType isEqual:GSHSOSSensorDeviceType]) {
            // 紧急按钮
            [exts addObject:[self extMWithBasMeteId:GSHSOSSensor_alarmMeteId conditionOperator:@"==" rightValue:@"1" deviceEditType:deviceEditType]];
        } else if ([deviceM.deviceType isEqual:GSHInfrareCurtainDeviceType]) {
            // 红外幕帘
            [exts addObject:[self extMWithBasMeteId:GSHInfrareCurtain_alarmMeteId conditionOperator:@"==" rightValue:@"1" deviceEditType:deviceEditType]];
        } else if ([deviceM.deviceType isEqual:GSHAudibleVisualAlarmDeviceType]) {
            // 声光报警器
            [exts addObject:[self extMWithBasMeteId:GSHAudibleVisualAlarm_alarmMeteId conditionOperator:@"==" rightValue:@"1" deviceEditType:deviceEditType]];
        } else if ([deviceM.deviceType isEqual:GSHInfrareReactionDeviceType]) {
            // 红外人体感应面板
            [exts addObject:[self extMWithBasMeteId:GSHInfrareReaction_alarmMeteId conditionOperator:@"==" rightValue:@"1" deviceEditType:deviceEditType]];
        }
    }
    
    return (NSArray *)exts;
}

+ (GSHDeviceExtM *)extMWithBasMeteId:(NSString *)basMeteId
                   conditionOperator:(NSString *)conditionOperator
                          rightValue:(NSString *)rightValue
                      deviceEditType:(GSHDeviceVCType)deviceEditType {
    GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
    extM.basMeteId = basMeteId;
    extM.conditionOperator = conditionOperator;
    if (deviceEditType == GSHDeviceVCTypeAutoTriggerSet) {
        extM.rightValue = rightValue;
    } else {
        extM.param = rightValue;
    }
    return extM;
}


@end
