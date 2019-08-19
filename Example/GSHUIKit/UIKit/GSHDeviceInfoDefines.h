//
//  GSHDeviceInfoDefines.h
//  SmartHome
//
//  Created by zhanghong on 2018/11/23.
//  Copyright © 2018 gemdale. All rights reserved.
//


/*
    此文件主要定义设备相关的宏
*/

#ifndef GSHDeviceInfoDefines_h
#define GSHDeviceInfoDefines_h

// 萤石猫眼
#define GSHYingShiMaoYanDeviceType @(15)

// 萤石摄像头
#define GSHYingShiSheXiangTouDeviceType @(16)

// 网关
#define GateWayDeviceType 32767

// 设备在线离线状态属性id
#define GSHDeviceOnLineStateMeteId @"026FFF00DE0001"

// 一路开关
#define GSHOneWaySwitchDeviceType @(0)
#define GSHOneWaySwitch_firstMeteId @"04000000060001"

// 二路开关
#define GSHTwoWaySwitchDeviceType @(1)
#define GSHTwoWaySwitch_firstMeteId @"04000100060001"
#define GSHTwoWaySwitch_secondMeteId @"04000100060002"

// 三路开关
#define GSHThreeWaySwitchDeviceType @(2)
#define GSHThreeWaySwitch_firstMeteId @"04000200060001"
#define GSHThreeWaySwitch_secondMeteId @"04000200060002"
#define GSHThreeWaySwitch_thirdMeteId @"04000200060003"

// 窗帘电机
#define GSHCurtainDeviceType @(515)
#define GSHCurtain_SwitchMeteId @"04020301020001"   // 开关
#define GSHCurtain_PercentMeteId @"03020300080001"  // 百分比

// 一路窗帘开关
#define GSHOneWayCurtainDeviceType @(519)
#define GSHOneWayCurtain_SwitchMeteId @"04020701020001"

// 二路窗帘开关
#define GSHTwoWayCurtainDeviceType @(517)
#define GSHTwoWayCurtain_OneSwitchMeteId @"04020501020001"
#define GSHTwoWayCurtain_TwoSwitchMeteId @"04020501020002"

// 空调
#define GSHAirConditionerDeviceType @(768)
#define GSHAirConditioner_SwitchMeteId @"04030000050002"   // 开关
#define GSHAirConditioner_ModelMeteId @"04030000050001"   // 模式
#define GSHAirConditioner_TemperatureMeteId @"03030000070001"   // 温度
#define GSHAirConditioner_WindSpeedMeteId @"04030000090001"   // 风量

// 空调转换器
#define GSHAirConditionerTranDeviceType @(17476)

// 新风
#define GSHNewWindDeviceType @(7)
#define GSHNewWind_SwitchMeteId @"040007000B0002"   // 开关
#define GSHNewWind_WindSpeedMeteId @"040007000B0001"   // 风量

// 地暖
#define GSHUnderFloorDeviceType @(518)
#define GSHUnderFloor_SwitchMeteId @"04020600060001"   // 开关
#define GSHUnderFloor_TemperatureMeteId  @"03020600110001"   // 温度

// 插座
#define GSHSocketDeviceType @(81)
#define GSHSocket_SocketSwitchMeteId @"04005100060001"  // 插座开关
#define GSHSocket_USBSwitchMeteId @"04005100060002" // USB开关

// 场景面板
#define GSHScenePanelDeviceType @(12)
#define GSHScenePanel_FirstMeteId @"02000C00400001" // 第一路
#define GSHScenePanel_SecondMeteId @"02000C00400002" // 第二路
#define GSHScenePanel_ThirdMeteId @"02000C00400003" // 第三路
#define GSHScenePanel_FourthMeteId @"02000C00400004" // 第四路
#define GSHScenePanel_FifthMeteId @"02000C00400005" // 第五路
#define GSHScenePanel_SixthMeteId @"02000C00400006" // 第六路

// 组合传感器
#define GSHSensorGroupDeviceType @(46)

// 红外转发
#define GSHInfraredControllerDeviceType @(254)

#pragma mark - 传感器
// 温湿度传感器
#define GSHHumitureSensorDeviceType @(770)
#define GSHHumitureSensor_temMeteId @"01030204020001"   // 温度
#define GSHHumitureSensor_humMeteId @"01030204050001"   // 湿度
#define GSHHumitureSensor_electricMeteId @"020302003D0001"   //电量

// 人体红外传感器
#define GSHSomatasensorySensorDeviceType @(263)
#define GSHSomatasensorySensor_alarmMeteId @"02010704060001"    // 告警
#define GSHSomatasensorySensor_electricMeteId @"02010700340001"   //电量

// 门磁传感器
#define GSHGateMagetismSensorDeviceType @(21)
#define GSHGateMagetismSensor_isOpenedMeteId @"02001500150001"  // 被打开
#define GSHGateMagetismSensor_electricMeteId @"02001500310001"   //电量

// 气体传感器
#define GSHGasSensorDeviceType @(40)
#define GSHGasSensor_alarmMeteId @"02002800280001" // 告警
#define GSHGasSensor_electricMeteId @"020028003A0001"   //电量

// 水浸传感器
#define GSHWaterLoggingSensorDeviceType @(42)
#define GSHWaterLoggingSensor_alarmMeteId @"02002A002A0001" // 告警
#define GSHWaterLoggingSensor_electricMeteId @"02002A00370001"   //电量

// 空气盒子
#define GSHAirBoxSensorDeviceType @(45)
#define GSHAirBoxSensor_temMeteId @"01002D04020001"   // 温度
#define GSHAirBoxSensor_humMeteId @"01002D04050001"   // 湿度
#define GSHAirBoxSensor_pmMeteId @"01002D200D0001"   // PM2.5
#define GSHAirBoxSensor_electricMeteId @"01002D200E0001"   //电量百分比

// 紧急按钮
#define GSHSOSSensorDeviceType @(277)
#define GSHSOSSensor_alarmMeteId @"02011500410001"  // 告警

// 红外幕帘
#define GSHInfrareCurtainDeviceType @(47)
#define GSHInfrareCurtain_alarmMeteId @"02002F00F10001" 

// 声光报警器
#define GSHAudibleVisualAlarmDeviceType @(1201)
#define GSHAudibleVisualAlarm_alarmMeteId @"0404B100F20001"

// 红外人体感应面板
#define GSHInfrareReactionDeviceType @(49)
#define GSHInfrareReaction_alarmMeteId @"02003100F30001"

#endif
