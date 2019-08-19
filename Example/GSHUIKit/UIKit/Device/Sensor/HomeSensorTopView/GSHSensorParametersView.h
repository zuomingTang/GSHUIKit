//
//  GSHSensorParametersView.h
//  SmartHome
//
//  Created by gemdale on 2018/11/12.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHSensorParametersView : UIView
@property(nonatomic,assign,readonly)NSInteger count;
+(GSHSensorParametersView*)sensorParametersViewWithBigFont:(UIFont*)bigFont littleFont:(UIFont*)littleFont space:(CGFloat)space count:(NSInteger)count;
-(void)refreshWithSensor:(GSHSensorM*)sensor;
@end
