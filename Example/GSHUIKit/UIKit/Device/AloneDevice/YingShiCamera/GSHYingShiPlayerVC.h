//
//  GSHYingShiPlayerVC.h
//  SmartHome
//
//  Created by gemdale on 2019/5/13.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EZOpenSDKFramework/EZOpenSDKFramework.h>

@interface GSHYingShiPlayerVC : UIViewController
+(instancetype)yingShiPlayerVCWithDevice:(GSHDeviceM*)device;
-(void)updateDeviceInfo:(EZDeviceInfo *)deviceInfo;
@property(nonatomic, assign)BOOL isShield;
@end
