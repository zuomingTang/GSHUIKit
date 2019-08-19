//
//  GSHHomeSensorTopView.h
//  SmartHome
//
//  Created by gemdale on 2018/11/12.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHHomeSensorTopView : UIView
@property(nonatomic,strong)NSArray<GSHSensorM*> *sensorList;
@property(nonatomic,strong)GSHFloorM *floor;

@property (weak, nonatomic) IBOutlet UIButton *defenceStateButton;

@property (copy, nonatomic) void(^defenceStateButtonClickBlock)(void);

@end
