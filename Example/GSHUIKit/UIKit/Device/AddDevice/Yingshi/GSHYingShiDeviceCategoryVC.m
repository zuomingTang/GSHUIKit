//
//  GSHYingShiDeviceCategoryVC.m
//  SmartHome
//
//  Created by gemdale on 2018/7/30.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHYingShiDeviceCategoryVC.h"
#import "GSHConfigWifiInfoVC.h"
#import <EZOpenSDKFramework/EZOpenSDKFramework.h>
#import "GSHBlueRoundButton.h"
#import "GSHYingShiDeviceEditVC.h"

@interface GSHYingShiDeviceCategoryVC ()
- (IBAction)touchHelp:(UIButton *)sender;
- (IBAction)touchNext:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *lblText;
@property (weak, nonatomic) IBOutlet UIView *line;
@property (weak, nonatomic) IBOutlet UIButton *btnReset;
@property (weak, nonatomic) IBOutlet GSHBlueRoundButton *btnNext;
@property (strong, nonatomic)GSHDeviceM *device;
@property (copy, nonatomic)NSString *text;
@property (strong, nonatomic)UIImage *image;
@property (assign, nonatomic)GSHYingShiDeviceCategoryVCType type;
@end

@implementation GSHYingShiDeviceCategoryVC

+(instancetype)yingShiDeviceCategoryVCWithDevice:(GSHDeviceM*)device title:(NSString*)title image:(UIImage*)image type:(GSHYingShiDeviceCategoryVCType)type{
    GSHYingShiDeviceCategoryVC *vc = [TZMPageManager viewControllerWithSB:@"GSHAddYingShiDeviceSB" andID:@"GSHYingShiDeviceCategoryVC"];
    vc.device = device;
    vc.text = title;
    vc.image = image;
    vc.type = type;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.lblText.text = self.text;
    self.imageView.image = self.image;
    if (self.type == GSHYingShiDeviceCategoryVCTypeReset) {
        self.line.hidden = YES;
        self.btnReset.hidden = YES;
        self.title = @"重置设备";
    }else{
        self.line.hidden = NO;
        self.btnReset.hidden = NO;
        self.title = @"设备配置";
    }
    
    if (self.device.deviceType.integerValue == 15) {
        //如果是猫眼要修改文案
        self.lblText.text = @"请在智能猫眼上进行一下操作：";
        self.title = @"网络配置";
        self.line.hidden = YES;
        self.btnReset.hidden = YES;
        [self.btnNext setTitle:@"wi-fi已连接好" forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchHelp:(UIButton *)sender {
    UIImage *image;
    if (self.device.deviceType.integerValue == 16) {
        image = [UIImage imageNamed:@"deviceCategroy_yingshi_reset-1"];
    }
    GSHYingShiDeviceCategoryVC *vc = [GSHYingShiDeviceCategoryVC yingShiDeviceCategoryVCWithDevice:self.device title:@"请长按设备Reset键10s，直到指示灯红蓝闪烁，即重置成功" image:image type:GSHYingShiDeviceCategoryVCTypeReset];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)touchNext:(UIButton *)sender {
    if (self.device.deviceType.integerValue == 15) {
        __weak typeof(self)weakSelf = self;
        [SVProgressHUD showWithStatus:@"检测中"];
        [EZOpenSDK probeDeviceInfo:self.device.deviceSn deviceType:nil completion:^(EZProbeDeviceInfo *deviceInfo, NSError *error) {
            [SVProgressHUD dismiss];
            if (deviceInfo.status == 1) {
                GSHYingShiDeviceEditVC *deviceEditVC = [GSHYingShiDeviceEditVC yingShiDeviceEditVCWithDevice:weakSelf.device];
                [weakSelf.navigationController pushViewController:deviceEditVC animated:YES];
            }else{
                if (!error) {
                    [SVProgressHUD showErrorWithStatus:@"设备不在线"];
                }else{
                    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                }
            }
        }];
    }else{
        GSHConfigWifiInfoVC *vc = [GSHConfigWifiInfoVC configWifiInfoVCWithDeviceM:self.device];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
@end
