//
//  GSHDeviceVC.h
//  SmartHome
//
//  Created by gemdale on 2019/7/16.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, GSHDeviceVCType) {
    GSHDeviceVCTypeControl  = 0,  // 设备控制
    GSHDeviceVCTypeSceneSet   = 1,  // 情景设置
    GSHDeviceVCTypeAutoTriggerSet  = 2, //  联动 -- 触发条件 -- 设备状态设置
    GSHDeviceVCTypeAutoActionSet  = 3 //  联动 -- 执行动作 -- 设备状态设置
};

@interface GSHDeviceVC : UIViewController

@property (copy , nonatomic) NSString *backImageNameStr;    // 背景图片名字

@end
