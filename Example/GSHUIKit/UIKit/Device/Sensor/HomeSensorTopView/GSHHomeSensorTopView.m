//
//  GSHHomeSensorTopView.m
//  SmartHome
//
//  Created by gemdale on 2018/11/12.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import "GSHHomeSensorTopView.h"
#import "UIView+TZM.h"
#import "Masonry.h"
#import "XXNibBridge.h"
#import "GSHSensorParametersView.h"
#import "GSHSensorListVC.h"
#import "MarqueeLabel.h"

@interface GSHHomeSensorTopView() <XXNibBridge>
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UILabel *lblMainName;
@property (weak, nonatomic) IBOutlet UILabel *lblMainRoom;
@property (weak, nonatomic) IBOutlet MarqueeLabel *lblOtherDevice;
- (IBAction)touchGoSensorList:(UIButton *)sender;
@property (strong, nonatomic) GSHSensorParametersView *sensorParametersView;
@end

@implementation GSHHomeSensorTopView

-(void)awakeFromNib{
    [super awakeFromNib];
    if (self.sensorParametersView) {
        return;
    }
    self.sensorParametersView = [GSHSensorParametersView sensorParametersViewWithBigFont:[UIFont systemFontOfSize:40]  littleFont:[UIFont systemFontOfSize:16] space:10 count:3];
    [self.mainView addSubview:self.sensorParametersView];
    
    __weak typeof(self)weakSelf = self;
    [self.sensorParametersView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.mainView);
    }];
    
}


-(void)setSensorList:(NSArray<GSHSensorM *> *)sensorList{
    _sensorList = sensorList;
    GSHSensorM *firstSensor = sensorList.firstObject;
    [self.sensorParametersView refreshWithSensor:sensorList.firstObject];
    self.lblMainName.text = firstSensor.deviceName;
    self.lblMainRoom.text = firstSensor.roomName;
    NSMutableString *string = [NSMutableString string];
    for (int i = 1; i < sensorList.count; i++) {
        GSHSensorM *sensor = sensorList[i];
        if (string.length > 0) {
            [string appendFormat:@" | %@",sensor.monitorString];
        }else{
            [string appendFormat:@"%@",sensor.monitorString];
        }
    }
    self.lblOtherDevice.text = string;
    if ([GSHOpenSDK share].currentFamily.permissions == GSHFamilyMPermissionsManager) {
        // 管理员
        [self.defenceStateButton setImage:[UIImage imageNamed:@"homepage_icon_protection"] forState:UIControlStateNormal];
        [self.defenceStateButton setImage:[UIImage imageNamed:@"homepage_icon_removal"] forState:UIControlStateSelected];
    } else {
        // 成员
        [self.defenceStateButton setImage:[UIImage imageNamed:@"homepage_icon_protection_disable"] forState:UIControlStateNormal];
        [self.defenceStateButton setImage:[UIImage imageNamed:@"homepage_icon_removal_disable"] forState:UIControlStateSelected];
    }
    // 离线控制模式下，隐藏首页布撤防按钮
    self.defenceStateButton.hidden = [GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN ? YES : NO;
}

- (IBAction)touchGoSensorList:(UIButton *)sender {
    __weak typeof(self)weakSelf = self;
    GSHSensorListVC *vc = [GSHSensorListVC sensorListVCWithFloor:self.floor block:^(GSHFloorM *floor) {
        if ([weakSelf.floor.floorId isKindOfClass:NSNumber.class]) {
            if ([floor.floorId isEqualToNumber:weakSelf.floor.floorId]) {
                weakSelf.sensorList = floor.sensorMsgList;
            }
        }
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)defenceStateButtonClick:(id)sender {
    if (self.defenceStateButtonClickBlock) {
        self.defenceStateButtonClickBlock();
    }
}

@end
