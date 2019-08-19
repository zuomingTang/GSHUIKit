//
//  GSHDeviceSearchVC.h
//  SmartHome
//
//  Created by gemdale on 2018/6/5.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GSHOpenSDKSoundCode/GSHDeviceM.h>

@interface GSHDeviceSearchVC : UIViewController
+(instancetype)deviceSearchVCWithDeviceCategory:(GSHDeviceCategoryM*)model deviceSn:(NSString *)deviceSn;
@end
