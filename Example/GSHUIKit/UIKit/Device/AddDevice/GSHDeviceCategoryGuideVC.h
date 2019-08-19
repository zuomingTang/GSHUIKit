//
//  GSHDeviceCategoryGuideVC.h
//  SmartHome
//
//  Created by gemdale on 2018/6/4.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GSHOpenSDKSoundCode/GSHDeviceM.h>

@interface GSHDeviceCategoryGuideVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *deviceSnLabel;

+(instancetype)deviceCategoryGuideVCWithGategory:(GSHDeviceCategoryM*)model deviceSn:(NSString *)deviceSn;
@end
