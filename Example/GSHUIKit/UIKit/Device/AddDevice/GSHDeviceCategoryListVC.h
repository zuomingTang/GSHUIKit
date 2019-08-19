//
//  GSHDeviceCategoryListVC.h
//  SmartHome
//
//  Created by gemdale on 2018/6/4.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GSHOpenSDKSoundCode/GSHDeviceM.h>

@interface GSHDeviceCategoryListCell : UICollectionViewCell
@property(nonatomic,strong) GSHDeviceCategoryM *model;
@end

@interface GSHDeviceCategoryListVC : UIViewController
+(instancetype)deviceCategorylist;
@end
