//
//  GSHDeviceSocketHandleVC.h
//  SmartHome
//
//  Created by zhanghong on 2018/9/7.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSHDeviceVC.h"
#import <GSHOpenSDKSoundCode/GSHDeviceM.h>

@interface GSHDeviceSocketHandleVC : GSHDeviceVC

+ (instancetype)deviceSocketHandleVCDeviceM:(GSHDeviceM *)deviceM deviceEditType:(GSHDeviceVCType)deviceEditType;

@property (nonatomic , copy) void (^deviceSetCompleteBlock)(NSArray *exts);

@end
