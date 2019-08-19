//
//  TZMBrokenLineGraphView.h
//  SmartHome
//
//  Created by gemdale on 2018/11/7.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TZMLineGraphViewPointBaseModel :NSObject
@property(nonatomic,assign)CGFloat y;   //0到1，表示在坐标系的纵坐标。
@property(nonatomic,assign)CGFloat x;   //0到1，表示在坐标系的横坐标。
@end

@interface TZMLineGraphBaseViewModel : NSObject
@property(nonatomic,strong)NSArray<TZMLineGraphViewPointBaseModel*> *pointArr; //点必须按X排序
@property(nonatomic,copy)NSString*(^xChangeBlock)(CGFloat x);
-(TZMLineGraphViewPointBaseModel*)pointWithX:(CGFloat)x;//获取离此坐标最近的点,如果在两点正中间可能返回nil;
@end

@interface TZMBrokenLineGraphViewPointModel :TZMLineGraphViewPointBaseModel
@property(nonatomic,assign)CGFloat value;

+(instancetype)pointWithValue:(CGFloat)value y:(CGFloat)y x:(CGFloat)x;
@end
@interface TZMBrokenLineGraphViewModel : TZMLineGraphBaseViewModel
@property(nonatomic,copy)NSString *title; //数量意义
@property(nonatomic,copy)NSString *unitString; //单位
@property(nonatomic,strong)UIColor *lineColor; //线条颜色
@end


@interface TZMThresholdLineGraphViewPointModel :TZMLineGraphViewPointBaseModel
@property(nonatomic,copy)NSString *title; //数量意义
@property(nonatomic,strong)UIColor *lineColor; //线条颜色
+(instancetype)pointWithY:(CGFloat)y x:(CGFloat)x lineColor:(UIColor *)lineColor title:(NSString *)title;;
@end

@interface TZMThresholdLineGraphViewModel : TZMLineGraphBaseViewModel

@end

@interface TZMBrokenLineGraphView : UIView
+(instancetype)wrokenLineGraphViewWithXTitle:(NSString*)xTitle yTitle:(NSString*)yTitle xUnitNumber:(NSInteger)xUnitNumber yUnit:(NSInteger)yUnitNumber;
-(void)refreshWithModels:(NSArray<TZMLineGraphBaseViewModel*>*)models;
@end
