//
//  GSHSettingVC.m
//  SmartHome
//
//  Created by gemdale on 2018/5/16.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHGWSettingVC.h"
#import "GSHGateWayUpdateVC.h"
#import "UIView+YeeBadge.h"
#import "GSHAlertManager.h"
#import "GSHAddGWGuideVC.h"
#import "GSHGatewayCopyRestoreVC.h"

@interface GSHGWSettingVC ()

@property (nonatomic ,strong) GSHGatewayVersionM *gateWayVersionM;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation GSHGWSettingVC

+(instancetype)settingVC{
    GSHGWSettingVC *vc = [TZMPageManager viewControllerWithSB:@"AddGWSB" andID:@"GSHGWSettingVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.versionLabel.redDotOffset = CGPointMake(0, 2);
    [self.versionLabel ShowBadgeView];
    [self getGatewayUpdateMsg];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//网关备份
- (void)gatewayBackup{
    
}
//获取网关备份
- (void)gatewayGetBackup{
    
}
//检测网关更新
- (void)gatewayCheckVersion{
    
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0){
        GSHGateWayUpdateVC *gateWayUpdateVC = [GSHGateWayUpdateVC gateWayUpdateVC];
        [self.navigationController pushViewController:gateWayUpdateVC animated:YES];
    } else if (indexPath.row == 1){
        [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
            if (buttonIndex == 1) {
                [SVProgressHUD showWithStatus:@"重启网关中"];
                [GSHGatewayManager resetGatewayWithGatewayId:[GSHOpenSDK share].currentFamily.gatewayId block:^(NSError *error) {
                    if (error) {
                        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                    }else{
                        [SVProgressHUD dismissWithDelay:3];
                    }
                }];
            }
        } textFieldsSetupHandler:NULL andTitle:@"确定重启网关吗？" andMessage:@"重启网关中设备将无法控制" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"取消" otherButtonTitles:@"立即重启",nil];
    } else if (indexPath.row == 2){
        [self.navigationController pushViewController:[GSHGatewayCopyRestoreVC gateWayCopyRestoreVC] animated:YES];
    } else if (indexPath.row == 3){
        [self.navigationController pushViewController:[GSHAddGWGuideVC addGWGuideVCWithFamily:[GSHOpenSDK share].currentFamily] animated:YES];
    } else {
        
    }
    return nil;
}

#pragma mark - request
// 获取网关升级信息
- (void)getGatewayUpdateMsg {
    
    @weakify(self)
    [SVProgressHUD showWithStatus:@"网关升级信息获取中"];
    [GSHGatewayManager getGatewayUpdateMsgWithFamilyId:[GSHOpenSDK share].currentFamily.familyId gatewayId:[GSHOpenSDK share].currentFamily.gatewayId block:^(GSHGatewayVersionM *gateWayVersionM, NSError *error) {
        @strongify(self)
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [SVProgressHUD dismiss];
            self.gateWayVersionM = gateWayVersionM;
            self.versionLabel.text = [NSString stringWithFormat:@"版本%@",self.gateWayVersionM.firmwareVersion];
            if (self.gateWayVersionM.updateFlag.intValue == 0 ||
                self.gateWayVersionM.updateFlag.intValue == 3) {
                // 需要升级
                [self.versionLabel ShowBadgeView];
            } else {
                [self.versionLabel hideBadgeView];
            }
        }
    }];
}

@end
