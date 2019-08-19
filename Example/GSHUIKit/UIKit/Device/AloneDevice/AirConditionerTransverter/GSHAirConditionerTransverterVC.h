//
//  GSHAirConditionerTransverterVC.h
//  SmartHome
//
//  Created by zhanghong on 2019/5/8.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSHAirConditionerTransverterVCCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;


@end

@interface GSHAirConditionerTransverterVC : UIViewController

+ (instancetype)airConditionerTransverterVCWithDeviceM:(GSHDeviceM *)deviceM;

@end

NS_ASSUME_NONNULL_END
