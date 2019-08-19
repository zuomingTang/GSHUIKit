//
//  GSHAddAutoVCViewModel.h
//  SmartHome
//
//  Created by zhanghong on 2018/11/26.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSHDeviceVC.h"


NS_ASSUME_NONNULL_BEGIN

@interface GSHAddAutoVCViewModel : NSObject

// 添加联动 -- 跳转设备操作页面
+ (void)jumpToDeviceHandleVCWithVC:(UIViewController *)vc
                           deviceM:(GSHDeviceM *)deviceM
                    deviceEditType:(GSHDeviceVCType)deviceEditType
            deviceSetCompleteBlock:(void(^)(NSArray *exts))deviceSetCompleteBlock;

// 添加联动 -- 设备选择属性拼接显示字符串
+ (NSString *)getDeviceShowStrWithDeviceM:(GSHDeviceM *)deviceM;

+ (NSString *)airBoxPmStrWithDeviceExtM:(GSHDeviceExtM *)deviceExtM;

+ (NSArray *)airBoxPmExtMWithPmStr:(NSString *)pmStr;

// 设备选中时初始值获取
+ (NSArray *)getInitExtsWithDeviceM:(GSHDeviceM *)deviceM deviceEditType:(GSHDeviceVCType)deviceEditType;


@end

NS_ASSUME_NONNULL_END
