//
//  GSHUnderFloorHeatVC.h
//  SmartHome
//
//  Created by zhanghong on 2018/10/19.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSHDeviceVC.h"


NS_ASSUME_NONNULL_BEGIN

@interface GSHUnderFloorHeatVC : GSHDeviceVC

+ (instancetype)underFloorHeatHandleVCDeviceM:(GSHDeviceM *)deviceM deviceEditType:(GSHDeviceVCType)deviceEditType;

@property (nonatomic , copy) void (^deviceSetCompleteBlock)(NSArray *exts);

@end

NS_ASSUME_NONNULL_END
