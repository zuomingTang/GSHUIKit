//
//  SVIndefiniteAnimatedView.m
//  SVProgressHUD, https://github.com/SVProgressHUD/SVProgressHUD
//
//  Copyright (c) 2014-2018 Guillaume Campagna. All rights reserved.
//

#import "SVIndefiniteAnimatedView.h"
#import "SVProgressHUD.h"

@interface SVIndefiniteAnimatedView ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation SVIndefiniteAnimatedView

- (void)willMoveToSuperview:(UIView*)newSuperview {
    if (newSuperview) {
        [self layoutAnimatedLayer];
    } else {
        [_imageView removeFromSuperview];
        _imageView = nil;
    }
}

- (void)layoutAnimatedLayer {
    
    CALayer *layer = self.imageView.layer;
    [self.layer addSublayer:layer];
    
    CGFloat widthDiff = CGRectGetWidth(self.bounds) - CGRectGetWidth(layer.bounds);
    CGFloat heightDiff = CGRectGetHeight(self.bounds) - CGRectGetHeight(layer.bounds);
    layer.position = CGPointMake(CGRectGetWidth(self.bounds) - CGRectGetWidth(layer.bounds) / 2 - widthDiff / 2, CGRectGetHeight(self.bounds) - CGRectGetHeight(layer.bounds) / 2 - heightDiff / 2);
}

-(UIImageView *)imageView{
    if(!_imageView) {
        _imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        _imageView.image = [UIImage imageNamed:@"SVProgressHUD_loading"];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        animation.fromValue = (id) 0;
        animation.toValue = @(M_PI*2);
        animation.duration = 1;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        animation.removedOnCompletion = NO;
        animation.repeatCount = INFINITY;
        animation.fillMode = kCAFillModeForwards;
        animation.autoreverses = NO;
        [_imageView.layer addAnimation:animation forKey:@"rotate"];
    }
    return _imageView;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if (_imageView) {
        _imageView.frame = CGRectMake(0, 0, self.size.width, self.size.height);
    }
}

- (void)setFrame:(CGRect)frame {
    if(!CGRectEqualToRect(frame, super.frame)) {
        [super setFrame:frame];
        if(self.superview) {
            [self layoutAnimatedLayer];
        }
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(36, 36);
}

@end
