//
//  GSHSceneCell.m
//  SmartHome
//
//  Created by zhanghong on 2018/5/9.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHSceneCell.h"

@implementation GSHSceneCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

    
}

- (IBAction)deleteButtonClick:(id)sender {
    if (self.deleteButtonClickBlock) {
        self.deleteButtonClickBlock();
    }
}


@end
