//
//  JKCircleView.m
//  JKCircleWidget
//
//
//  Created by kunge on 16/8/31.
//  Copyright © 2016年 kunge. All rights reserved.
//

#define   DEGREES_TO_RADIANS(degrees)  ((M_PI * degrees)/ 180)
#define CATProgressStartAngle     (-225)
#define CATProgressEndAngle       (45)

#import "JKCircleView.h"
#import <math.h>
#import <QuartzCore/QuartzCore.h>

@interface JKCircleView () <UIGestureRecognizerDelegate>
{
    UIPanGestureRecognizer *panGesture;
}

// dial appearance
@property CGFloat dialRadius;

// background circle appeareance
@property CGFloat outerRadius;  // don't set this unless you want some squarish appearance
@property CGFloat arcRadius; // must be less than the outerRadius since view clips to bounds
@property CGFloat arcThickness;
@property CGPoint trueCenter;
@property UILabel *numberLabel;
@property UIImageView *iconImage;

@property int currentNum;
@property double angle;
@property UIView *circle;

@property (nonatomic, strong) CAShapeLayer *trackLayer;
@property (nonatomic, strong) CAShapeLayer *progressLayer;

//进度 [0...1]
@property(nonatomic,assign) CGFloat progress;

@property(nonatomic,assign) BOOL isCanSlide;

@end

@implementation JKCircleView


# pragma mark view appearance setup

- (id)initWithFrame:(CGRect)frame startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle {
    self = [super initWithFrame:frame];
    if(self) {
        // overall view settings
        self.userInteractionEnabled = YES;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        
        // setting default values
        self.minNum = 0;
        self.maxNum = 100;
        self.currentNum = self.minNum;
        self.units = @"";
        self.iconName = @"";
        
        // determine true center of view for calculating angle and setting up arcs
        CGFloat width = frame.size.width;
        CGFloat height = frame.size.height;
        self.trueCenter = CGPointMake(width/2, height/2);
        
        // radii settings
        self.dialRadius = 10;
        self.arcRadius = 80;
        self.outerRadius = MIN(width, height)/2;
        self.arcThickness = 6.0;
        
        _trackLayer = [CAShapeLayer layer];
        _trackLayer.frame = self.bounds;
        _trackLayer.fillColor = [UIColor clearColor].CGColor;
        _trackLayer.strokeColor = [UIColor blackColor].CGColor;
        _trackLayer.opacity = 0.2;//背景圆环的背景透明度
        _trackLayer.lineCap = kCALineCapRound;
        [self.layer addSublayer:_trackLayer];
        
        self.arcRadius = MIN(self.arcRadius, self.outerRadius - self.dialRadius);
        UIBezierPath *path=[UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
                                                          radius:self.arcRadius startAngle:DEGREES_TO_RADIANS(startAngle) endAngle:DEGREES_TO_RADIANS(endAngle) clockwise:YES];//-210到30的path
        _trackLayer.path = path.CGPath;
        _trackLayer.lineWidth = self.arcThickness;
        
        //2.进度轨道
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.frame = self.bounds;
        _progressLayer.fillColor = [[UIColor clearColor] CGColor];
        _progressLayer.strokeColor = [UIColor whiteColor].CGColor;//!!!不能用clearColor
        _progressLayer.lineCap = kCALineCapRound;
        _progressLayer.strokeEnd = 0.0;
        [self.layer addSublayer:_progressLayer];
        
        self.arcRadius = MIN(self.arcRadius, self.outerRadius - self.dialRadius);

       
        UIBezierPath *path1=[UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2) radius:self.arcRadius startAngle:DEGREES_TO_RADIANS(startAngle) endAngle:DEGREES_TO_RADIANS(endAngle) clockwise:YES];//-210到30的path

        _progressLayer.path = path1.CGPath;
        _progressLayer.lineWidth = self.arcThickness;
        
        CGPoint newCenter = CGPointMake(width/2, height/2);
        newCenter.y += self.arcRadius * sin(M_PI/180 * (45));
        newCenter.x += self.arcRadius * cos(M_PI/180 * (135));
        
        self.circle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        self.circle.userInteractionEnabled = YES;
        self.circle.layer.cornerRadius = 14;
        self.circle.backgroundColor = [UIColor whiteColor];
        self.circle.center = newCenter;
        [self addSubview: self.circle];
        
        // pan gesture detects circle dragging
        panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect {

}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    
    
    self.arcRadius = MIN(self.arcRadius, self.outerRadius - self.dialRadius);
    
    // label
    self.numberLabel.text = [NSString stringWithFormat:@"%d %@", self.currentNum, self.units];
    
    self.iconImage.image = [UIImage imageNamed:self.iconName];
    
//    [self moveCircleToAngle:0];
    
}

# pragma mark move circle in response to pan gesture
- (void)moveCircleToAngle:(double)angle isSendRequest:(BOOL)isSendRequest {
    self.angle = angle;

    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGPoint newCenter = CGPointMake(width/2, height/2);

    newCenter.y += self.arcRadius * sin(M_PI/180 * (angle - 225));
    newCenter.x += self.arcRadius * cos(M_PI/180 * (angle - 225));
    self.circle.center = newCenter;
    self.currentNum = self.minNum + (self.maxNum - self.minNum)*(angle/self.circleRadian) + 0.5;
    NSLog(@"currentNum : %d",self.currentNum);
    self.numberLabel.text = [NSString stringWithFormat:@"%d %@˚C", self.currentNum, self.units];
    self.iconImage.image = [UIImage imageNamed:self.iconName];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [CATransaction setAnimationDuration:1];

    _progressLayer.strokeEnd = angle/self.circleRadian;
    if (self.progressChange) {
        self.progressChange([NSString stringWithFormat:@"%d",self.currentNum],isSendRequest);
    }
    [CATransaction commit];
    
}

- (void)setProgressWithProgress:(CGFloat)progress isSendRequest:(BOOL)isSendRequest {
    _progress = progress;
    NSLog(@"progress : %f",progress);
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [CATransaction setAnimationDuration:1];
    progress = progress < 0.0 ? 0.0 : progress;
    progress = progress > 1.0 ? 1.0 : progress;
    _progressLayer.strokeEnd=progress;
    
    CGPoint newCenter = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    
    newCenter.y += self.arcRadius * sin(M_PI/180 * (self.circleRadian * progress - 225));
    newCenter.x += self.arcRadius * cos(M_PI/180 * (self.circleRadian * progress - 225));
    self.circle.center = newCenter;
    
    self.currentNum = self.minNum + (self.maxNum - self.minNum)*progress;
    self.numberLabel.text = [NSString stringWithFormat:@"%d %@˚C", self.currentNum, self.units];
    if (self.progressChange) {
        self.progressChange([NSString stringWithFormat:@"%d",self.currentNum],isSendRequest);
    }
    [CATransaction commit];
}

-(void)setEnableCustom:(CGFloat)enableCustom{
    _enableCustom = enableCustom;
    if (_enableCustom) {
        self.circle.userInteractionEnabled = YES;
        self.circle.hidden = NO;
        [self addGestureRecognizer:panGesture];
    }else{
        self.circle.userInteractionEnabled = NO;
        self.circle.hidden = YES;
        [self removeGestureRecognizer:panGesture];
    }
}

- (void)setIsCanSlideTemperature:(BOOL)isCanSlide {
    self.isCanSlide = isCanSlide;
}

# pragma mark detect pan and determine angle of pan location vs. center of circular revolution

- (void)handlePan:(UIPanGestureRecognizer *)pv {
    
    if (!self.isCanSlide) {
        return;
    }
    CGPoint translation = [pv locationInView:self];
    CGFloat x_displace = translation.x - self.trueCenter.x;
    CGFloat y_displace = -1.0*(translation.y - self.trueCenter.y);
    double radius = pow(x_displace, 2) + pow(y_displace, 2);
    radius = pow(radius, .5);
    
    double angle = 180/M_PI*asin(x_displace/radius);
    
    if (x_displace > 0 && y_displace < 0){
        angle = 180 - angle;
    }
    else if (x_displace < 0){
        if(y_displace > 0){
            angle = 360.0 + angle;
        }
        else if(y_displace <= 0){
            angle = 180 - angle;
        }
    }
    angle = angle - 225;
    if (angle < 0) {
        angle += 360;
    }
    NSLog(@"angle : %f",angle);
    BOOL isSendRequest = NO;
    if (pv.state == UIGestureRecognizerStateEnded) {
        isSendRequest = YES;
    }
    if (angle <= self.circleRadian) {
        [self moveCircleToAngle:angle isSendRequest:isSendRequest];
    } else {
        [self moveCircleToAngle:self.circleRadian isSendRequest:isSendRequest];
    }
    
}


@end
