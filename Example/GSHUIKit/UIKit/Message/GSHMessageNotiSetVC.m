//
//  GSHMessageNotiSetVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/11/29.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import "GSHMessageNotiSetVC.h"

@interface GSHMessageNotiSetVC ()

@property (nonatomic , strong) GSHMessageM *messageM;

@end

@implementation GSHMessageNotiSetVC {
    NSArray *_cellNameArr;
}

+ (instancetype)messageNotiSetVC {
    return [TZMPageManager viewControllerWithSB:@"GSHMessageSB" andID:@"GSHMessageNotiSetVC"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#F6F7FA"];
    if ([GSHOpenSDK share].currentFamily.permissions == GSHFamilyMPermissionsManager) {
       // 管理员
        _cellNameArr = @[@"系统消息提醒",@"低电量消息提醒",@"场景消息提醒",@"联动消息提醒"];
    } else {
        // 成员
        _cellNameArr = @[@"告警消息提醒",@"系统消息提醒",@"低电量消息提醒",@"场景消息提醒",@"联动消息提醒"];
    }
    [self getMsgConfig];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cellNameArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHMessageNotiCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GSHMessageNotiCell" forIndexPath:indexPath];
    cell.cellNameLabel.text = _cellNameArr[indexPath.row];
    if ([GSHOpenSDK share].currentFamily.permissions == GSHFamilyMPermissionsManager) {
        // 管理员
        if (indexPath.row == 0) {
            cell.notiSwitch.on = self.messageM.systemWarn.integerValue == 1 ? NO : YES;
        } else if (indexPath.row == 1) {
            cell.notiSwitch.on = self.messageM.batteryWarn.integerValue == 1 ? NO : YES;
        } else if (indexPath.row == 2) {
            cell.notiSwitch.on = self.messageM.scenarioWarn.integerValue == 1 ? NO : YES;
        } else if (indexPath.row == 3) {
            cell.notiSwitch.on = self.messageM.automationWarn.integerValue == 1 ? NO : YES;
        }
    } else {
        // 成员
        if (indexPath.row == 0) {
            cell.notiSwitch.on = self.messageM.alarmWarn.integerValue == 1 ? NO : YES;
        } else if (indexPath.row == 1) {
            cell.notiSwitch.on = self.messageM.systemWarn.integerValue == 1 ? NO : YES;
        } else if (indexPath.row == 2) {
            cell.notiSwitch.on = self.messageM.batteryWarn.integerValue == 1 ? NO : YES;
        } else if (indexPath.row == 3) {
            cell.notiSwitch.on = self.messageM.scenarioWarn.integerValue == 1 ? NO : YES;
        } else if (indexPath.row == 4) {
            cell.notiSwitch.on = self.messageM.automationWarn.integerValue == 1 ? NO : YES;
        }
    }
    
    @weakify(self)
    __weak typeof(cell) weakCell = cell;
    cell.switchClickBlock = ^{
        @strongify(self)
        __strong typeof(weakCell) strongCell = weakCell;
        NSString *value = [NSString stringWithFormat:@"%d", !strongCell.notiSwitch.on];
        [self updateMsgConfigWithMsgType:indexPath.row+1 value:value notiSiwtch:strongCell.notiSwitch];
    };
    return cell;
}

#pragma mark - request
// App用户获取消息提醒设置
- (void)getMsgConfig {
    
    [SVProgressHUD showWithStatus:@"请求中"];
    [GSHMessageManager getMsgConfigWithFamilyId:[GSHOpenSDK share].currentFamily.familyId block:^(GSHMessageM *messageM, NSError * _Nonnull error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        } else {
            [SVProgressHUD dismiss];
            self.messageM = messageM;
            [self.tableView reloadData];
        }
    }];
    
}

// App用户修改消息提醒设置
- (void)updateMsgConfigWithMsgType:(NSInteger)msgType value:(NSString *)value notiSiwtch:(UISwitch *)notiSwitch {
    [SVProgressHUD showWithStatus:@"修改中"];
    __weak typeof(notiSwitch) weakNotiSwitch = notiSwitch;
    [GSHMessageManager updateMsgConfigWithFamilyId:[GSHOpenSDK share].currentFamily.familyId msgType:msgType value:value block:^(NSError * _Nonnull error) {
        __strong typeof(weakNotiSwitch) strongNotiSwitch = weakNotiSwitch;
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            strongNotiSwitch.on = !strongNotiSwitch.on;
        } else {
            [SVProgressHUD showSuccessWithStatus:@"修改成功"];
        }
    }];
}



@end


@implementation GSHMessageNotiCell

- (IBAction)notiSwitchClick:(UISwitch *)notiSwitch {
    if (self.switchClickBlock) {
        self.switchClickBlock();
    }
}


@end
