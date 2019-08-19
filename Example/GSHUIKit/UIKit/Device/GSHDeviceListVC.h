//
//  GSHDeviceListVC.h
//  SmartHome
//
//  Created by gemdale on 2018/6/4.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GSHOpenSDKSoundCode/GSHDeviceM.h>

@interface GSHDeviceListVCCell : UITableViewCell
@property(nonatomic,strong)GSHDeviceM *model;
@end

@interface GSHDeviceListVC : UIViewController
+(instancetype)deviceListVC;
@end
