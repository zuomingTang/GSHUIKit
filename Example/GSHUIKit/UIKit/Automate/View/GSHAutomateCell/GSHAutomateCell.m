//
//  GSHAutomateCell.m
//  SmartHome
//
//  Created by zhanghong on 2018/5/9.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHAutomateCell.h"

@interface GSHAutomateCell ()

@property (weak, nonatomic) IBOutlet UILabel *autoNameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *openSwitch;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIImageView *leftConditionImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightConditionImageView;
@property (weak, nonatomic) IBOutlet UIImageView *linkImageView;
@property (weak, nonatomic) IBOutlet UILabel *conditionTypeLabel;

@end

@implementation GSHAutomateCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.backView.layer.cornerRadius = 5.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setAutoCellValueWithOssAutoM:(GSHOssAutoM *)ossAutoM {
    
    self.autoNameLabel.text = ossAutoM.name;
    self.openSwitch.on = [ossAutoM.status intValue];
    self.conditionTypeLabel.text = [ossAutoM.relationType intValue] == 0 ? @"全部" : @"任一";
    if (ossAutoM.type.intValue == 1 || ossAutoM.type.intValue == 2) {
        // 有时间条件
        self.leftConditionImageView.image = [UIImage imageNamed:@"intelligent_icon_timing"];
        if (ossAutoM.type.intValue == 1) {
            // 只有时间
            self.rightConditionImageView.hidden = YES;
            self.linkImageView.hidden = YES;
        } else {
            // 既有时间又有条件
            self.rightConditionImageView.hidden = NO;
            self.linkImageView.hidden = NO;
        }
    } else {
        // 无时间条件
        self.leftConditionImageView.image = [UIImage imageNamed:@"intelligent_icon_equipment"];
        self.rightConditionImageView.hidden = YES;
        self.linkImageView.hidden = YES;
    }
    self.openSwitch.enabled = [GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN ? NO : YES;
}

- (IBAction)openSwitchClick:(UISwitch *)openSwitch {
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
        return;
    }
    if (self.openSwitchClickBlock) {
        self.openSwitchClickBlock(openSwitch);
    }
}

- (BOOL)isContainTimeConditionWithConditionList:(NSArray *)conditionList {
    BOOL isContain = NO;
    for (int i = 0; i < conditionList.count; i ++) {
        GSHAutoTriggerConditionListM *conditionListM = conditionList[i];
        if (conditionListM.getDateTimer.length > 0) {
            isContain = YES;
        }
    }
    return isContain;
}


@end
