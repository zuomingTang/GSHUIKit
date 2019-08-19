//
//  GSHYingShiDeviceCategoryVC.h
//  SmartHome
//
//  Created by gemdale on 2018/7/30.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    GSHYingShiDeviceCategoryVCTypeValidation,
    GSHYingShiDeviceCategoryVCTypeReset,
} GSHYingShiDeviceCategoryVCType;

@interface GSHYingShiDeviceCategoryVC : UIViewController
+(instancetype)yingShiDeviceCategoryVCWithDevice:(GSHDeviceM*)device title:(NSString*)title image:(UIImage*)image type:(GSHYingShiDeviceCategoryVCType)type;
@end
