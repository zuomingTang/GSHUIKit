//
//  GSHYingShiLiXianVC.m
//  SmartHome
//
//  Created by gemdale on 2018/8/29.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHYingShiLiXianVC.h"
#import "GSHYingShiDeviceCategoryVC.h"

@interface GSHYingShiLiXianVC ()
- (IBAction)touchPeiZhi:(UIButton *)sender;
@property (strong, nonatomic)GSHDeviceM *device;
@property (weak, nonatomic) IBOutlet UIView *viewSheXiangJi;
@property (weak, nonatomic) IBOutlet UIView *viewMaoYan;
@end

@implementation GSHYingShiLiXianVC

+(instancetype)yingShiLiXianVCWithDevice:(GSHDeviceM*)device{
    GSHYingShiLiXianVC *vc =  [TZMPageManager viewControllerWithSB:@"GSHYingshiCameraToolSB" andID:@"GSHYingShiLiXianVC"];
    vc.device = device;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.device.deviceType.integerValue == 15) {
        self.viewMaoYan.hidden = NO;
        self.viewSheXiangJi.hidden = YES;
    }else{
        self.viewMaoYan.hidden = YES;
        self.viewSheXiangJi.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchPeiZhi:(UIButton *)sender {
    UIImage *image;
    if (self.device.deviceType.integerValue == 16) {
        image = [UIImage imageNamed:@"deviceCategroy_yingshi_reset-1"];
    }
    GSHYingShiDeviceCategoryVC *vc = [GSHYingShiDeviceCategoryVC yingShiDeviceCategoryVCWithDevice:self.device title:@"请长按设备Reset键10s，直到指示灯红蓝闪烁，即重置成功" image:image type:GSHYingShiDeviceCategoryVCTypeReset];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
