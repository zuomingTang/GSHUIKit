//
//  TZMBrokenLineGraphView.m
//  SmartHome
//
//  Created by gemdale on 2018/11/7.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import "TZMBrokenLineGraphView.h"
#import "Masonry.h"

@interface TZMLineGraphViewPointBaseModel()
@end
@implementation TZMLineGraphViewPointBaseModel
@end

@interface TZMLineGraphBaseViewModel()
@property(nonatomic,weak)UILabel *label;
@property(nonatomic,weak)UIView *dot;
@property(nonatomic,weak)MASConstraint *dotBottomConstraint;
@end
@implementation TZMLineGraphBaseViewModel
//找到最近的一个点,切这个点的x坐标小于等于x
-(TZMLineGraphViewPointBaseModel*)pointWithLessThanOrEqualX:(CGFloat)x{
    if (self.pointArr.count < 3) {
        if (self.pointArr.count == 1) {
            return self.pointArr.firstObject;
        }else if (self.pointArr.count == 2){
            if (self.pointArr.lastObject.x <= x) {
                return self.pointArr.lastObject;
            }else{
                return self.pointArr.firstObject;
            }
        }else{
            return nil;
        }
    }else{
        NSInteger index = [self integerWithStartIndex:0 endIndex:self.pointArr.count - 1 x:x];
        if (index == 0) {
            return self.pointArr.firstObject;
        }else{
            if (self.pointArr[index].x <= x) {
                return self.pointArr[index];
            }else{
                return self.pointArr[index - 1];
            }
        }
    }
    return nil;
}

//找到最近的一个点
-(TZMLineGraphViewPointBaseModel*)pointWithX:(CGFloat)x{
    if (self.pointArr.count < 3) {
        if (self.pointArr.count == 1) {
            return self.pointArr.firstObject;
        }else if (self.pointArr.count == 2){
            return [self pointWithX:x point1:self.pointArr.firstObject point2:self.pointArr.lastObject];
        }else{
            return nil;
        }
    }else{
        NSInteger index = [self integerWithStartIndex:0 endIndex:self.pointArr.count - 1 x:x];
        if (index == 0) {
            return self.pointArr.firstObject;
        }else{
            return [self pointWithX:x point1:self.pointArr[index - 1] point2:self.pointArr[index]];
        }
    }
    return nil;
}

-(TZMLineGraphViewPointBaseModel*)pointWithX:(CGFloat)x point1:(TZMLineGraphViewPointBaseModel*)point1 point2:(TZMLineGraphViewPointBaseModel*)point2{
    CGFloat difference = fabs(point1.x - x) - fabs(point2.x - x);
    if (difference > 0) {
        return point2;
    }else{
        return point1;
    }
}

//找所有点中比x大的最小数位置，startIndex必须小于等于endIndex
-(NSInteger)integerWithStartIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex x:(CGFloat)x{
    if (startIndex == endIndex) {
        return endIndex;
    }if (endIndex - startIndex == 1) {
        if (self.pointArr[startIndex].x > x) {
            return startIndex;
        }else{
            return endIndex;
        }
    }else{
        NSInteger index = (startIndex + endIndex) / 2;
        CGFloat indexX = self.pointArr[index].x;
        if (indexX > x) {
            return [self integerWithStartIndex:startIndex endIndex:index x:x];
        }else{
            return [self integerWithStartIndex:index endIndex:endIndex x:x];
        }
    }
    return 0;
};
@end

@interface TZMBrokenLineGraphViewModel ()
@end
@implementation TZMBrokenLineGraphViewModel
@end
@interface TZMBrokenLineGraphViewPointModel ()
@end
@implementation TZMBrokenLineGraphViewPointModel
+(instancetype)pointWithValue:(CGFloat)value y:(CGFloat)y x:(CGFloat)x{
    TZMBrokenLineGraphViewPointModel *model = [TZMBrokenLineGraphViewPointModel new];
    model.x = x;
    model.y = y;
    model.value = value;
    return model;
}
@end

@interface TZMThresholdLineGraphViewPointModel()
@end
@implementation TZMThresholdLineGraphViewPointModel
+(instancetype)pointWithY:(CGFloat)y x:(CGFloat)x lineColor:(UIColor *)lineColor title:(NSString *)title{
    TZMThresholdLineGraphViewPointModel *model = [TZMThresholdLineGraphViewPointModel new];
    model.x = x;
    model.y = y;
    model.lineColor = lineColor;
    model.title = title;
    return model;
}
@end
@interface TZMThresholdLineGraphViewModel()
@property(nonatomic,weak)UIView *line;
@end
@implementation TZMThresholdLineGraphViewModel
@end

@interface TZMBrokenLineGraphView ()
@property(nonatomic,copy)NSString *xString; //横坐标
@property(nonatomic,copy)NSString *yString; //纵坐标
@property(nonatomic,strong)NSNumber *xNumber;  // 横坐标有多少档
@property(nonatomic,strong)NSNumber *yNumber;  // 纵坐标有多少档
@property(nonatomic,strong)NSArray<TZMLineGraphBaseViewModel*>*models;

@property(nonatomic,assign)CGFloat axisLineWidth;   //轴线粗
@property(nonatomic,assign)CGFloat dashLineWidth;   //虚线线粗
@property(nonatomic,assign)UIEdgeInsets coordinateAxisEdge;   //坐标边距

@property(nonatomic,assign)CGFloat agoTouchX;

@property(nonatomic,strong)UIView *topView;
@property(nonatomic,strong)UIView *snapshootLine;
@property(nonatomic,strong)UILabel *lblTime;
@property(nonatomic,weak)MASConstraint *lineLeftConstraint;
@end

@implementation TZMBrokenLineGraphView
+(instancetype)wrokenLineGraphViewWithXTitle:(NSString*)xTitle yTitle:(NSString*)yTitle xUnitNumber:(NSInteger)xUnitNumber yUnit:(NSInteger)yUnitNumber{
    TZMBrokenLineGraphView *view = [[TZMBrokenLineGraphView alloc] initWithXTitle:xTitle yTitle:yTitle xUnitNumber:xUnitNumber yUnit:yUnitNumber];
    return view;
}

-(instancetype)initWithXTitle:(NSString*)xTitle yTitle:(NSString*)yTitle xUnitNumber:(NSInteger)xUnitNumber yUnit:(NSInteger)yUnitNumber{
    self = [super init];
    if (self) {
        self.xString = xTitle;
        self.yString = yTitle;
        self.xNumber = @(xUnitNumber);
        self.yNumber = @(yUnitNumber);
        self.axisLineWidth = 0.5;
        self.dashLineWidth = 0.5;
        self.coordinateAxisEdge = UIEdgeInsetsMake(49, 15, 26.5, 15);
        
        self.topView = [UIView new];
        [self addSubview:self.topView];
        
        __weak typeof(self)weakSelf = self;
        [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(@(0));
            make.top.equalTo(weakSelf).offset(0);
            make.width.equalTo(@(100)).priority(1);
            make.height.equalTo(@(44));
        }];
        
        self.lblTime = [UILabel new];
        self.lblTime.text = @"时间";
        self.lblTime.font = [UIFont systemFontOfSize:12];
        self.lblTime.textColor = [UIColor colorWithRGB:0x222222];
        
        self.snapshootLine = [UIView new];
        [self addSubview:self.snapshootLine];
        self.snapshootLine.backgroundColor = [UIColor colorWithRGB:0xff0000];
        self.snapshootLine.clipsToBounds = NO;
        [self.snapshootLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf).offset(weakSelf.coordinateAxisEdge.top);
            make.bottom.equalTo(weakSelf).offset(-weakSelf.coordinateAxisEdge.bottom);
            make.width.equalTo(@(0.5));
            weakSelf.lineLeftConstraint = make.left.equalTo(@(0.5)).offset(weakSelf.coordinateAxisEdge.left);
        }];
    }
    return self;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    CGFloat x = (touchPoint.x - self.coordinateAxisEdge.left) / (self.layer.width - self.coordinateAxisEdge.left - self.coordinateAxisEdge.right);
    [self changeSnapshootWithX:x];
}

//-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [super touchesMoved:touches withEvent:event];
//    UITouch *touch = [touches anyObject];
//    CGPoint touchPoint = [touch locationInView:self];
//    CGFloat x = (touchPoint.x - self.coordinateAxisEdge.left) / (self.layer.width - self.coordinateAxisEdge.left - self.coordinateAxisEdge.right);
//    [self changeSnapshootWithX:x];
//}
//移动
-(void)changeSnapshootWithX:(CGFloat)x{
    TZMBrokenLineGraphViewModel *brokenLine;
    for (TZMLineGraphBaseViewModel *model in self.models) {
        if ([model isKindOfClass:TZMBrokenLineGraphViewModel.class]) {
            brokenLine = (TZMBrokenLineGraphViewModel*)model;
        }
    }
    //如果有折线图 就不能连续
    if (brokenLine) {
        TZMLineGraphViewPointBaseModel *point = [brokenLine pointWithX:x];
        if (!point) {
            return;
        }
        if (point.x == self.agoTouchX) {
        }else{
            self.agoTouchX = point.x;
            self.lineLeftConstraint.offset(self.coordinateAxisEdge.left + self.agoTouchX * (self.layer.width - self.coordinateAxisEdge.left - self.coordinateAxisEdge.right));
        }
    } else {
        self.agoTouchX = x < 0 ? 0 : (x > 1 ? 1 : x);
        self.lineLeftConstraint.offset(self.coordinateAxisEdge.left + self.agoTouchX * (self.layer.width - self.coordinateAxisEdge.left - self.coordinateAxisEdge.right));
    }
    CGFloat yLen = (self.layer.height - self.coordinateAxisEdge.bottom - self.coordinateAxisEdge.top);
    for (TZMLineGraphBaseViewModel *model in self.models) {
        if ([model isKindOfClass:TZMBrokenLineGraphViewModel.class]) {
            TZMBrokenLineGraphViewPointModel *point = (TZMBrokenLineGraphViewPointModel*)[model pointWithX:self.agoTouchX];
            TZMBrokenLineGraphViewModel *bModel = (TZMBrokenLineGraphViewModel*)model;
            if (fabs(point.x - self.agoTouchX) < 0.00001) {
                bModel.dot.hidden = NO;
                bModel.label.text = [NSString stringWithFormat:@"%@：%d%@",bModel.title ? bModel.title : @"",(int)point.value,bModel.unitString ? bModel.unitString : @""];
                if (bModel.dotBottomConstraint) {
                    bModel.dotBottomConstraint.offset(-(point.y * yLen) + 4.5);
                }
            }else{
                bModel.label.text = bModel.title;
                bModel.dot.hidden = YES;
            }
        }else if ([model isKindOfClass:TZMThresholdLineGraphViewModel.class]) {
            TZMThresholdLineGraphViewPointModel *point = (TZMThresholdLineGraphViewPointModel*)[model pointWithLessThanOrEqualX:self.agoTouchX];
            TZMThresholdLineGraphViewModel *tModel = (TZMThresholdLineGraphViewModel*)model;
            tModel.dot.hidden = NO;
            tModel.label.text = point.title;
            tModel.line.backgroundColor = point.lineColor;
            if (tModel.dotBottomConstraint) {
                tModel.dotBottomConstraint.offset(-(point.y * yLen) + 4.5);
            }
        }
    }
    if (self.models.firstObject.xChangeBlock) {
        self.lblTime.text = self.models.firstObject.xChangeBlock(self.agoTouchX);
    }
}

-(void)refreshWithModels:(NSArray<TZMLineGraphBaseViewModel*>*)models{
    self.models = models;
    [self refreshView];
    [self setNeedsDisplay];
}

//画图例
-(void)refreshView{
    [self.topView removeAllSubviews];
    [self.snapshootLine removeAllSubviews];
    __weak UIView *weakTopView = self.topView;
    __weak UIView *previousView;
    [self.topView addSubview:self.lblTime];
    [self.lblTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(@(0));
        make.left.equalTo(weakTopView).offset(0);
        make.width.equalTo(@(0)).priority(1);
        make.height.equalTo(@(0)).priority(1);
    }];
    previousView = self.lblTime;
    
    for (TZMLineGraphBaseViewModel *model in self.models) {
        UIView *line = [UIView new];
        if ([model isKindOfClass:TZMBrokenLineGraphViewModel.class]) {
            line.backgroundColor = ((TZMBrokenLineGraphViewModel*)model).lineColor;
        }else if ([model isKindOfClass:TZMThresholdLineGraphViewModel.class]) {
            ((TZMThresholdLineGraphViewModel*)model).line = line;
        }
        [self.topView addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(@(0));
            make.left.equalTo(previousView.mas_right).offset(15);
            make.width.equalTo(@(10));
            make.height.equalTo(@(2.5));
        }];
        previousView = line;
        
        UILabel *lable = [UILabel new];
        if ([model isKindOfClass:TZMBrokenLineGraphViewModel.class]) {
            lable.text = ((TZMBrokenLineGraphViewModel*)model).title;
        }else if ([model isKindOfClass:TZMThresholdLineGraphViewModel.class]) {
            
        }
        lable.font = [UIFont systemFontOfSize:12];
        lable.textColor = [UIColor colorWithRGB:0x222222];
        [self.topView addSubview:lable];
        [lable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(@(0));
            make.left.equalTo(previousView.mas_right).offset(4);
            make.width.equalTo(@(0)).priority(1);
            make.height.equalTo(@(0)).priority(1);
        }];
        previousView = lable;
        model.label = lable;
        
        UIView *dot = [UIView new];
        dot.backgroundColor = [UIColor colorWithRGB:0xff0000];
        dot.clipsToBounds = YES;
        dot.layer.cornerRadius = 4.5;
        dot.layer.borderWidth = 0.5;
        dot.layer.borderColor = [UIColor whiteColor].CGColor;
        [self.snapshootLine addSubview:dot];
        __weak TZMLineGraphBaseViewModel *weakModel = model;
        [dot mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(@(0));
            weakModel.dotBottomConstraint = make.bottom.equalTo(@(0)).offset(0);
            make.width.equalTo(@(9));
            make.height.equalTo(@(9));
        }];
    }
    [previousView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakTopView).offset(0);
    }];
}

-(void)drawRect:(CGRect)rect{
    [self drawRectCoordinateAxis];
    [self drawRectBrokenLineGraph];
    [self changeSnapshootWithX:1];
}

//画线
-(void)drawRectBrokenLineGraph{
    for (TZMLineGraphBaseViewModel *model in self.models) {
        if ([model isKindOfClass:TZMBrokenLineGraphViewModel.class]) {
            UIBezierPath *brokenLine = [UIBezierPath bezierPath];
            brokenLine.lineWidth = 3;
            brokenLine.lineCapStyle = kCGLineCapSquare;
            brokenLine.lineJoinStyle = kCGLineJoinRound;
            
            CGFloat xLen = (self.layer.width - self.coordinateAxisEdge.left - self.coordinateAxisEdge.right);
            CGFloat yLen = (self.layer.height - self.coordinateAxisEdge.bottom - self.coordinateAxisEdge.top);
            for (TZMBrokenLineGraphViewPointModel *point in model.pointArr) {
                if (brokenLine.isEmpty) {
                    [brokenLine moveToPoint:CGPointMake(point.x * xLen + self.coordinateAxisEdge.left, (self.layer.height - self.coordinateAxisEdge.bottom) - point.y * yLen)];
                }else{
                    [brokenLine addLineToPoint:CGPointMake(point.x * xLen + self.coordinateAxisEdge.left, (self.layer.height - self.coordinateAxisEdge.bottom) - point.y * yLen)];
                }
            }
            [((TZMBrokenLineGraphViewModel*)model).lineColor set];
            [brokenLine stroke];
        }else if ([model isKindOfClass:TZMThresholdLineGraphViewModel.class]) {
            TZMThresholdLineGraphViewPointModel *previousPoint;
            UIBezierPath *previousPath;
            CGFloat xLen = (self.layer.width - self.coordinateAxisEdge.left - self.coordinateAxisEdge.right);
            CGFloat yLen = (self.layer.height - self.coordinateAxisEdge.bottom - self.coordinateAxisEdge.top);
            for (TZMThresholdLineGraphViewPointModel *point in model.pointArr) {
                NSLog(@"x:%f",point.x * xLen + self.coordinateAxisEdge.left);
                
                previousPath = [UIBezierPath bezierPath];
                previousPath.lineWidth = 3;
                previousPath.lineCapStyle = kCGLineCapRound;
                previousPath.lineJoinStyle = kCGLineJoinMiter;
                [point.lineColor set];
                if (!previousPoint) {
                    [previousPath moveToPoint:CGPointMake(self.coordinateAxisEdge.left, (self.layer.height - self.coordinateAxisEdge.bottom) - point.y * yLen)];
                }else{
                    [previousPath moveToPoint:CGPointMake(previousPoint.x * xLen + self.coordinateAxisEdge.left, (self.layer.height - self.coordinateAxisEdge.bottom) - point.y * yLen)];
                }
                [previousPath addLineToPoint:CGPointMake(point.x * xLen + self.coordinateAxisEdge.left, (self.layer.height - self.coordinateAxisEdge.bottom) - point.y * yLen)];
                [previousPath stroke];
                previousPoint = point;
            }
        }
    }
}
//画坐标系
-(void)drawRectCoordinateAxis{
    if (self.xString) {
        UIBezierPath *xline = [UIBezierPath bezierPath];
        xline.lineWidth = self.axisLineWidth;
        [xline moveToPoint:CGPointMake(self.coordinateAxisEdge.left, self.layer.height - self.coordinateAxisEdge.bottom)];
        [xline addLineToPoint:CGPointMake(self.layer.width - self.coordinateAxisEdge.right, self.layer.height - self.coordinateAxisEdge.bottom)];
        
        UIColor *color = [UIColor colorWithRGB:0xBFBFBF];
        [color set];
        [xline stroke];
        
        CGSize size = [self.xString sizeForFont:[UIFont systemFontOfSize:12] size:CGSizeMake(1000, 16.5) mode:NSLineBreakByWordWrapping];
        [self.xString drawInRect:CGRectMake(self.layer.width - self.coordinateAxisEdge.right - 3.5 - size.width, self.layer.height - self.coordinateAxisEdge.bottom + 4.5, size.width, 16.5) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12], NSForegroundColorAttributeName : [UIColor colorWithRGB:0x999999]}];
    }
    
    if (self.yString) {
        UIBezierPath *yline = [UIBezierPath bezierPath];
        yline.lineWidth = self.axisLineWidth;
        [yline moveToPoint:CGPointMake(self.coordinateAxisEdge.left, self.coordinateAxisEdge.top)];
        [yline addLineToPoint:CGPointMake(self.coordinateAxisEdge.left, self.layer.height - self.coordinateAxisEdge.bottom)];
        
        UIColor *color = [UIColor colorWithRGB:0xBFBFBF];
        [color set];
        [yline stroke];
        
        CGSize size = [self.yString sizeForFont:[UIFont systemFontOfSize:12] size:CGSizeMake(1000, 16.5) mode:NSLineBreakByWordWrapping];
        [self.yString drawInRect:CGRectMake(self.coordinateAxisEdge.left + 4.5, 3.5, size.width, 16.5) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12], NSForegroundColorAttributeName : [UIColor colorWithRGB:0x999999]}];
    }
    
    CGFloat dashStyle[] = {1.5, 1.5};
    for (int i = 0; i < 6; i++) {
        UIBezierPath *dashLine = [UIBezierPath bezierPath];
        dashLine.lineWidth = self.dashLineWidth;
        [dashLine moveToPoint:CGPointMake(self.coordinateAxisEdge.left, self.coordinateAxisEdge.top + i * (self.layer.height - self.coordinateAxisEdge.bottom - self.coordinateAxisEdge.top) / 6.0)];
        [dashLine addLineToPoint:CGPointMake(self.layer.width - self.coordinateAxisEdge.right, self.coordinateAxisEdge.top + i * (self.layer.height - self.coordinateAxisEdge.bottom - self.coordinateAxisEdge.top) / 6.0)];
        [dashLine setLineDash:dashStyle count:2 phase:0];
        
        UIColor *color = [UIColor colorWithRGB:0xe9e9e9];
        [color set];
        [dashLine stroke];
    }
}


@end
