//
//  GSHDeviceListVC.m
//  SmartHome
//
//  Created by gemdale on 2018/6/4.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHDeviceListVC.h"
#import "GSHDeviceCategoryListVC.h"
#import "GSHDeviceEditVC.h"
#import "GSHYingShiDeviceEditVC.h"
#import "GSHAddGWDetailVC.h"
#import "GSHNewWindHandleVC.h"
#import "GSHScenePanelHandleVC.h"
#import "GSHThreeWaySwitchHandleVC.h"

#import "UIView+TZMPageStatusViewEx.h"
#import "UIViewController+TZMPageStatusViewEx.h"

#import "GSHScenePanelEditVC.h"
#import "GSHDeviceInfoDefines.h"
#import "NSObject+TZM.h"

@interface GSHDeviceListVCCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageViewLogo;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblLabel;
@end

@implementation GSHDeviceListVCCell
-(void)setModel:(GSHDeviceM *)model{
    _model = model;
    self.lblName.text = model.deviceName;
    self.lblLabel.text = model.deviceSn;
    
    NSString *imageStr;
    if (model.deviceType.integerValue == 254 && model.deviceModel.integerValue < 0) {
        imageStr = [NSString stringWithFormat:@"deviceCategroy_off_icon_infrared_%d",-[model.deviceModel intValue]];
    }else{
        imageStr = [NSString stringWithFormat:@"deviceCategroy_off_icon-%d",[model.deviceType intValue]];
    }
    self.imageViewLogo.image = [UIImage imageNamed:imageStr];
}
@end

@interface GSHDeviceListVC ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic)NSMutableArray<GSHDeviceM*> *deviceList;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)touchAdd:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *addDeviceButton;
@end

@implementation GSHDeviceListVC

+(instancetype)deviceListVC{
    GSHDeviceListVC *vc = [TZMPageManager viewControllerWithSB:@"GSHDeviceSB" andID:@"GSHDeviceListVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.deviceList = [NSMutableArray array];
    [self reloadData];
    [self observerNotifications];
    self.addDeviceButton.hidden = [GSHOpenSDK share].currentFamily.permissions == GSHFamilyMPermissionsMember;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)dealloc{
    [self removeNotifications];
}

-(void)observerNotifications{
    [self observerNotification:GSHOpenSDKDeviceUpdataNotification];
}

-(void)handleNotifications:(NSNotification *)notification{
    if ([notification.name isEqualToString:GSHOpenSDKDeviceUpdataNotification]) {
        [self reloadData];
    }
}

- (void)reloadData{
    @weakify(self)
    [SVProgressHUD showWithStatus:@"加载设备中"];
    [GSHDeviceManager getDevicesListWithFamilyId:[GSHOpenSDK share].currentFamily.familyId block:^(NSArray<GSHDeviceM *> *list, NSError *error) {
        @strongify(self)
        [self dismissPageStatusView];
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }else{
            [SVProgressHUD dismiss];
            [self.deviceList removeAllObjects];
            [self.deviceList addObjectsFromArray:list];
            [self.tableView reloadData];
            
            if (self.deviceList.count == 0) {
                [self showPageStatus:TZMPageStatusNormal image:[UIImage imageNamed:@"blankpage_icon_equipment"] title:nil desc:@"暂无设备" buttonText:nil didClickButtonCallback:nil];
            }
        }
    }];
}

- (IBAction)touchAdd:(UIButton *)sender {
    GSHDeviceCategoryListVC *vc = [GSHDeviceCategoryListVC deviceCategorylist];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.deviceList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHDeviceListVCCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.accessoryType = [GSHOpenSDK share].currentFamily.permissions ==  GSHFamilyMPermissionsMember ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
    if (self.deviceList.count > indexPath.row) {
        cell.model = self.deviceList[indexPath.row];
    }
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([GSHOpenSDK share].currentFamily.permissions == GSHFamilyMPermissionsMember) return nil;
    if (self.deviceList.count > indexPath.row) {
        GSHDeviceM *deviceM = self.deviceList[indexPath.row];
        if (deviceM.deviceType.integerValue == 15 || deviceM.deviceType.integerValue == 16) {
            // 莹石设备
            GSHYingShiDeviceEditVC *deviceEditVC = [GSHYingShiDeviceEditVC yingShiDeviceEditVCWithDevice:deviceM];
            @weakify(self)
            deviceEditVC.deviceEditSuccessBlock = ^(GSHDeviceM *deviceM) {
                @strongify(self)
                [self.tableView reloadData];
            };
            [self.navigationController pushViewController:deviceEditVC animated:YES];
        }else if (deviceM.deviceType.integerValue == GateWayDeviceType){
            // 网关
            GSHAddGWDetailVC *deviceEditVC = [GSHAddGWDetailVC editGWDetailVCWithDevice:deviceM];
            @weakify(self)
            deviceEditVC.deviceEditSuccessBlock = ^(GSHDeviceM *deviceM) {
                @strongify(self)
                [self.tableView reloadData];
            };
            [self.navigationController pushViewController:deviceEditVC animated:YES];
        }else{
            if ([deviceM.deviceType isEqual: GSHScenePanelDeviceType]) {
                // 场景面板
                GSHScenePanelEditVC *scenePanelEditVC = [GSHScenePanelEditVC scenePanelEditVCWithDeviceM:deviceM type:GSHScenePanelEditTypeEdit];
                scenePanelEditVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:scenePanelEditVC animated:YES];
                return nil;
            }
            GSHDeviceEditVC *deviceEditVC = [GSHDeviceEditVC deviceEditVCWithDevice:deviceM type:GSHDeviceEditVCTypeEdit];
            @weakify(self)
            deviceEditVC.deviceEditSuccessBlock = ^(GSHDeviceM *deviceM) {
                @strongify(self)
                self.deviceList[indexPath.row].deviceName = deviceM.deviceName;
                [self.tableView reloadData];
            };
            [self.navigationController pushViewController:deviceEditVC animated:YES];
        }
    }

    return nil;
}

@end
