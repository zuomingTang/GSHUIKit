//
//  GSHGateMagnetismSetVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/11/12.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import "GSHGateMagnetismSetVC.h"
#import "UINavigationController+TZM.h"
#import "GSHDeviceInfoDefines.h"

@interface GSHGateMagnetismSetVC ()

@property (weak, nonatomic) IBOutlet UIButton *beOpenedButton;
@property (weak, nonatomic) IBOutlet UIButton *beClosedButton;
@property (nonatomic,strong) GSHDeviceM *deviceM;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;

@end

@implementation GSHGateMagnetismSetVC

+ (instancetype)gateMagnetismSetVCWithDeviceM:(GSHDeviceM *)deviceM {
    GSHGateMagnetismSetVC *vc = [TZMPageManager viewControllerWithSB:@"GSHGateMagnetismSetSB" andID:@"GSHGateMagnetismSetVC"];
    vc.deviceM = deviceM;
    return vc;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    self.tzm_prefersNavigationBarHidden = YES;
    
    self.deviceNameLabel.text = self.deviceM.deviceName;
    
    if (self.deviceM.exts.count > 0) {
        GSHDeviceExtM *extM = self.deviceM.exts[0];
        if (extM.rightValue.intValue == 1) {
            self.beOpenedButton.selected = YES;
            self.beClosedButton.selected = NO;
            self.beOpenedButton.backgroundColor = [UIColor whiteColor];
            self.beClosedButton.backgroundColor = [UIColor clearColor];
        } else {
            self.beOpenedButton.selected = NO;
            self.beClosedButton.selected = YES;
            self.beOpenedButton.backgroundColor = [UIColor clearColor];
            self.beClosedButton.backgroundColor = [UIColor whiteColor];
        }
    } else {
        self.beOpenedButton.selected = YES;
        self.beClosedButton.selected = NO;
        self.beOpenedButton.backgroundColor = [UIColor whiteColor];
        self.beClosedButton.backgroundColor = [UIColor clearColor];
    }
}

#pragma mark - method

- (IBAction)backButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)beOpenedButtonClick:(UIButton *)sender {
    if (sender.selected) {
        return;
    }
    sender.selected = YES;
    self.beClosedButton.selected = NO;
    self.beOpenedButton.backgroundColor = [UIColor whiteColor];
    self.beClosedButton.backgroundColor = [UIColor clearColor];
}

- (IBAction)beClosedButtonClick:(UIButton *)sender {
    if (sender.selected) {
        return;
    }
    self.beOpenedButton.selected = NO;
    sender.selected = YES;
    self.beOpenedButton.backgroundColor = [UIColor clearColor];
    self.beClosedButton.backgroundColor = [UIColor whiteColor];
}

- (IBAction)sureButtonClick:(id)sender {
    NSMutableArray *exts = [NSMutableArray array];
    // 告警
    NSString *triggerMeteId;
    if ([self.deviceM.deviceModel isEqualToNumber:@(-2)] && [self.deviceM.deviceSn containsString:@"_"]) {
        triggerMeteId = [self.deviceM getBaseMeteIdFromDeviceSn:self.deviceM.deviceSn];
    } else {
        triggerMeteId = GSHGateMagetismSensor_isOpenedMeteId;
    }
    NSString *triggerValue = self.beOpenedButton.selected ? @"1" : @"0";
    GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
    extM.basMeteId = triggerMeteId;
    extM.conditionOperator = @"==";
    extM.rightValue = triggerValue;
    [exts addObject:extM];
    if (self.deviceSetCompleteBlock) {
        self.deviceSetCompleteBlock(exts);
    }
    [self.navigationController popViewControllerAnimated:YES];
}



@end
