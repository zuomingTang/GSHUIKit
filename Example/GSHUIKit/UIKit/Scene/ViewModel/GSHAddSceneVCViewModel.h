//
//  GSHAddSceneVCViewModel.h
//  SmartHome
//
//  Created by zhanghong on 2018/12/18.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSHAddSceneVCViewModel : NSObject

// 添加场景 -- 跳转设备操作页面
+ (void)jumpToDeviceHandleVCWithVC:(UIViewController *)vc
                           deviceM:(GSHDeviceM *)deviceM
            deviceSetCompleteBlock:(void(^)(NSArray *exts))deviceSetCompleteBlock;

// 添加场景 -- 设备选择属性拼接显示字符串
+(NSString *)getDeviceShowStrWithDeviceM:(GSHDeviceM *)deviceM;

// 设备选中时初始值获取
+ (NSArray *)getInitExtsWithDeviceM:(GSHDeviceM *)deviceM;

@end

NS_ASSUME_NONNULL_END
