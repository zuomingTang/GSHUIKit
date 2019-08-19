//
//  GSHInfraredControllerInfoVC.m
//  SmartHome
//
//  Created by gemdale on 2019/2/21.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHInfraredControllerInfoVC.h"
#import "GSHInfraredControllerTypeVC.h"
#import "GSHInfraredVirtualDeviceTVVC.h"
#import "GSHInfraredVirtualDeviceAirConditionerVC.h"
#import "UIViewController+TZMPageStatusViewEx.h"

@interface GSHInfraredControllerInfoVCCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageviewIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@end

@implementation GSHInfraredControllerInfoVCCell
-(void)setDevice:(GSHKuKongInfraredDeviceM *)device{
    _device = device;
    self.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"deviceCategroy_off_icon_infrared_%@",device.kkDeviceType]];
    self.lblName.text = device.deviceName;
}
@end

@interface GSHInfraredControllerInfoVC ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)GSHDeviceM *device;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)touchAdd:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
@property(nonatomic,strong)NSArray<GSHKuKongInfraredDeviceM*> *subDeviceList;
@end

@implementation GSHInfraredControllerInfoVC

+(instancetype)infraredControllerInfoVCWithDevice:(GSHDeviceM*)device{
    GSHInfraredControllerInfoVC *vc = [TZMPageManager viewControllerWithSB:@"GSHInfraredControllerSB" andID:@"GSHInfraredControllerInfoVC"];
    vc.device = device;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self updateData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    self.title = self.device.deviceName;
    self.btnAdd.hidden = [GSHOpenSDK share].currentFamily.permissions == GSHFamilyMPermissionsMember;
}

-(void)updateData{
    [SVProgressHUD showWithStatus:@"获取设备中"];
    __weak typeof(self)weakSelf = self;
    [GSHInfraredControllerManager getKuKongDeviceListWithParentDeviceId:self.device.deviceId familyId:[GSHOpenSDK share].currentFamily.familyId kkDeviceType:nil deviceSn:nil block:^(NSArray<GSHKuKongInfraredDeviceM *> *list, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }else{
            [SVProgressHUD dismiss];
            weakSelf.subDeviceList = list;
            [weakSelf.tableView reloadData];
            if (weakSelf.subDeviceList.count == 0) {
                [weakSelf showPageStatus:TZMPageStatusNormal image:[UIImage imageNamed:@"blankpage_icon_equipment"] title:nil desc:@"暂无设备" buttonText:nil didClickButtonCallback:nil];
            }
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.subDeviceList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHInfraredControllerInfoVCCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (indexPath.row < self.subDeviceList.count) {
        cell.device = self.subDeviceList[indexPath.row];
    }
    return cell;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHInfraredControllerInfoVCCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIViewController *vc;
    switch (cell.device.kkDeviceType.integerValue) {
        case 1:
            vc = [GSHInfraredVirtualDeviceTVVC tvHandleVCWithDevice:cell.device];
            break;
        case 2:
            vc = [GSHInfraredVirtualDeviceTVVC tvHandleVCWithDevice:cell.device];
            break;
        case 5:
            vc = [GSHInfraredVirtualDeviceAirConditionerVC infraredVirtualDeviceAirConditionerVCWithDevice:cell.device];
            break;
        default:
            break;
    }
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
    return nil;
}

- (IBAction)touchAdd:(UIButton *)sender {
    GSHInfraredControllerTypeVC *vc = [GSHInfraredControllerTypeVC infraredControllerTypeVCWithDevice:self.device];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
