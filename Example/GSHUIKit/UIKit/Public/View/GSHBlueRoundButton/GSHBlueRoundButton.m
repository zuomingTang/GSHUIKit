//
//  GSHBlueRoundButton.m
//  SmartHome
//
//  Created by gemdale on 2018/6/28.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHBlueRoundButton.h"

@implementation GSHBlueRoundButton
-(instancetype)init{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"#1c93ff"];
        self.titleLabel.font = [UIFont systemFontOfSize:17];
        [self setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
        self.layer.cornerRadius = self.frame.size.height / 2;
        self.clipsToBounds = YES;
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"#1c93ff"];
        self.titleLabel.font = [UIFont systemFontOfSize:17];
        [self setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
        self.layer.cornerRadius = self.frame.size.height / 2;
        self.clipsToBounds = YES;
    }
    return self;
}

-(void)setZ_isWhiteGround:(BOOL)z_isWhiteGround{
    _z_isWhiteGround = z_isWhiteGround;
    if (z_isWhiteGround) {
        self.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
        self.titleLabel.font = [UIFont systemFontOfSize:17];
        [self setTitleColor:[UIColor colorWithHexString:@"#1c93ff"] forState:UIControlStateNormal];
        self.layer.cornerRadius = self.frame.size.height / 2;
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor colorWithHexString:@"#1c93ff"].CGColor;
        self.clipsToBounds = YES;
    }
}

-(void)setEnabled:(BOOL)enabled{
    [super setEnabled:enabled];
    if (enabled) {
        if (_z_isWhiteGround) {
            self.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
            [self setTitleColor:[UIColor colorWithHexString:@"#1c93ff"] forState:UIControlStateNormal];
            self.layer.borderColor = [UIColor colorWithHexString:@"#1c93ff"].CGColor;
        }else{
            self.backgroundColor = [UIColor colorWithHexString:@"#1c93ff"];
        }
    }else{
        if (_z_isWhiteGround) {
            self.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
            [self setTitleColor:[UIColor colorWithHexString:@"#dedede"] forState:UIControlStateNormal];
            self.layer.borderColor = [UIColor colorWithHexString:@"#dedede"].CGColor;
        }else{
            self.backgroundColor = [UIColor colorWithHexString:@"#dedede"];
        }
    }
}

@end
