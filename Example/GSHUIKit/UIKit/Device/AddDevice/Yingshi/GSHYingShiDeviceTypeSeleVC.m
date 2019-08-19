//
//  GSHYingShiDeviceTypeSeleVC.m
//  SmartHome
//
//  Created by gemdale on 2019/1/3.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHYingShiDeviceTypeSeleVC.h"
#import "GSHBlueRoundButton.h"
#import "GSHYingShiDeviceDetailVC.h"
#import "GSHDeviceInfoDefines.h"

@interface GSHYingShiDeviceTypeSeleVC ()
@property (weak, nonatomic) IBOutlet GSHBlueRoundButton *btnNext;
- (IBAction)touchNext:(GSHBlueRoundButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnSele1;
@property (weak, nonatomic) IBOutlet UIImageView *imageSele1;
@property (weak, nonatomic) IBOutlet UIButton *btnSele2;
@property (weak, nonatomic) IBOutlet UIImageView *imageSele2;
- (IBAction)touchSele:(UIButton *)sender;
@property (strong, nonatomic)GSHDeviceM *device;
@property (copy, nonatomic)NSString *modelName;
@end

@implementation GSHYingShiDeviceTypeSeleVC
+(instancetype)yingShiDeviceDetailVCWithDevice:(GSHDeviceM*)device{
    GSHYingShiDeviceTypeSeleVC *vc = [TZMPageManager viewControllerWithSB:@"GSHAddYingShiDeviceSB" andID:@"GSHYingShiDeviceTypeSeleVC"];
    vc.device = device;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)touchNext:(GSHBlueRoundButton *)sender {
    if (self.modelName.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请选择设备类型"];
        return;
    }
    GSHYingShiDeviceDetailVC *vc = [GSHYingShiDeviceDetailVC yingShiDeviceDetailVCWithDevice:self.device modelName:self.modelName];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)touchSele:(UIButton *)sender {
    if (sender == self.btnSele1) {
        self.imageSele1.highlighted = YES;
        self.imageSele2.highlighted = NO;
        self.device.deviceModel = GSHYingShiSheXiangTouDeviceType;
        self.device.deviceType = GSHYingShiSheXiangTouDeviceType;
        self.device.deviceTypeStr = @"萤石摄像机";
        self.modelName = @"YSC";
    }else{
        self.imageSele1.highlighted = NO;
        self.imageSele2.highlighted = YES;
        self.device.deviceModel = GSHYingShiMaoYanDeviceType;
        self.device.deviceType = GSHYingShiMaoYanDeviceType;
        self.device.deviceTypeStr = @"猫眼";
        self.modelName = @"DP1";
    }
}
@end
