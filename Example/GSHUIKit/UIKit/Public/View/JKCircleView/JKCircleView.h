//
//  JKCircleView.h
//  JKCircleWidget
//
//  Created by kunge on 16/8/31.
//  Copyright © 2016年 kunge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JKCircleView : UIView

// set min and max range for dial
// default values are 0 to 100

@property int minNum;

@property int maxNum;

@property NSString *units;

@property(nonatomic,strong) NSString *iconName;

//是否可以手动调节进度
@property (nonatomic, assign) CGFloat enableCustom;

//圆环弧度
@property (nonatomic, assign) CGFloat circleRadian;

////起点
//@property (nonatomic, assign) CGFloat startAngle;
//
////终点
//@property (nonatomic, assign) CGFloat endAngle;

@property int flag;

@property (nonatomic,copy) void (^progressChange)(NSString *result,BOOL isSendRequest);

- (id)initWithFrame:(CGRect)frame startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle;

- (void)setProgressWithProgress:(CGFloat)progress isSendRequest:(BOOL)isSendRequest;

- (void)setIsCanSlideTemperature:(BOOL)isCanSlide;

@end
