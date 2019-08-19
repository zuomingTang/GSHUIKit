//
//  GSHYingShiCameraVC.h
//  SmartHome
//
//  Created by gemdale on 2018/7/12.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GSHOpenSDKSoundCode/GSHDeviceM.h>

@interface GSHYingShiCameraVCGaoJingCell : UITableViewCell
@property(nonatomic,strong)GSHYingShiGaoJingM *model;
@end

@interface GSHYingShiCameraVCDoorBellCell : UITableViewCell
@property(nonatomic,strong)GSHYingShiGaoJingM *model;
@end

@interface GSHYingShiCameraVC : UIViewController
+(instancetype)yingShiCameraVCWithDevice:(GSHDeviceM*)device;
@end
