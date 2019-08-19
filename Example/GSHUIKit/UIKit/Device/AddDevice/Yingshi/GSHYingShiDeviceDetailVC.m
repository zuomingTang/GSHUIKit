//
//  GSHYingShiDeviceDetailVC.m
//  SmartHome
//
//  Created by gemdale on 2018/8/24.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHYingShiDeviceDetailVC.h"
#import "GSHYingShiDeviceCategoryVC.h"
#import "GSHQRCodeScanningVC.h"
#import <EZOpenSDKFramework/EZOpenSDKFramework.h>
#import "GSHYingShiDeviceEditVC.h"

@interface GSHYingShiDeviceDetailVC ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
- (IBAction)touchNext:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (strong, nonatomic)GSHDeviceM *device;
@property (copy, nonatomic)NSString *modelName;
@end

@implementation GSHYingShiDeviceDetailVC

+(instancetype)yingShiDeviceDetailVCWithDevice:(GSHDeviceM*)device modelName:(NSString*)modelName{
    GSHYingShiDeviceDetailVC *vc = [TZMPageManager viewControllerWithSB:@"GSHAddYingShiDeviceSB" andID:@"GSHYingShiDeviceDetailVC"];
    vc.device = device;
    vc.modelName = modelName;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [GSHYingShiManager updataAccessTokenWithBlock:NULL];
    // Do any additional setup after loading the view.
    if (self.device.deviceType.integerValue == 15) {
        self.imageView.image = [UIImage imageNamed:@"deviceCategroy_yingshi_detail-3"];
    }else if (self.device.deviceType.integerValue == 16) {
        self.imageView.image = [UIImage imageNamed:@"deviceCategroy_yingshi_detail-1"];
    }
    self.lblName.text = [NSString stringWithFormat:@"%@(%@)",self.device.deviceModelStr,self.device.deviceSn];
    __weak typeof(self)weakSelf = self;
    [SVProgressHUD showWithStatus:@"检测设备是否可用"];
    [GSHYingShiManager getIsDeviceAddableWithDeviceSerial:self.device.deviceSn modelName:self.modelName familyId:[GSHOpenSDK share].currentFamily.familyId block:^(NSDictionary *data, NSError *error) {
        [SVProgressHUD dismiss];
        if (error) {
            weakSelf.lblContent.text = error.localizedDescription;
            weakSelf.lblContent.hidden = NO;
            weakSelf.btnNext.hidden = YES;
        }else{
            weakSelf.lblContent.hidden = YES;
            weakSelf.btnNext.hidden = NO;
            weakSelf.device.deviceModel = [data numverValueForKey:@"ipcModel" default:nil];
            weakSelf.device.deviceType = [data numverValueForKey:@"deviceType" default:nil];
            weakSelf.device.manufacturer = [data stringValueForKey:@"manufacturer" default:nil];
            weakSelf.device.agreementType = [data stringValueForKey:@"agreementType" default:nil];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchNext:(UIButton *)sender {
    [SVProgressHUD showWithStatus:@""];
    __weak typeof(self)weakSelf = self;
    [SVProgressHUD showWithStatus:@"加载中"];
    [EZOpenSDK probeDeviceInfo:self.device.deviceSn deviceType:nil completion:^(EZProbeDeviceInfo *deviceInfo, NSError *error) {
        [SVProgressHUD dismiss];
        if (deviceInfo.status == 1) {
            GSHYingShiDeviceEditVC *deviceEditVC = [GSHYingShiDeviceEditVC yingShiDeviceEditVCWithDevice:weakSelf.device];
            [weakSelf.navigationController pushViewController:deviceEditVC animated:YES];
        }else{
            UIImage *image;
            if (weakSelf.device.deviceType.integerValue == 15) {
                image = [UIImage imageNamed:@"deviceCategroy_yingshi_guide-3"];
            }else if (weakSelf.device.deviceType.integerValue == 16) {
                image = [UIImage imageNamed:@"deviceCategroy_yingshi_guide-1"];
            }
            GSHYingShiDeviceCategoryVC *vc = [GSHYingShiDeviceCategoryVC yingShiDeviceCategoryVCWithDevice:weakSelf.device title:@"请将设备插上电源，然后耐心等待一分钟，直到指示灯红蓝交替闪烁" image:image type:GSHYingShiDeviceCategoryVCTypeValidation];
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }
    }];
}
@end
