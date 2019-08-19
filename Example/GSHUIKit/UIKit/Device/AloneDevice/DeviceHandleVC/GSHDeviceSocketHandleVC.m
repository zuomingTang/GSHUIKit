//
//  GSHDeviceSocketHandleVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/9/7.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHDeviceSocketHandleVC.h"
#import "UINavigationController+TZM.h"

#import "GSHDeviceEditVC.h"
#import "NSObject+TZM.h"

#define ElectricQuantityKey @"01005100EF0001"    // 电量
#define PowerKey @"01005100EC0001"    // 功率
#define SwitchMeteIdKey @"04005100060001" // 开关
#define UsbSwitchMeteIdKey @"04005100060002"    // USB开关

@interface GSHDeviceSocketHandleVC ()

@property (nonatomic,strong) NSMutableDictionary *meteIdDic;
@property (nonatomic,strong) GSHDeviceM *deviceM;
@property (nonatomic,strong) NSArray *exts;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *electricQuantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *powerLabel;
@property (weak, nonatomic) IBOutlet UISwitch *openSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *usbSwitch;
@property (assign, nonatomic) GSHDeviceVCType deviceEditType;
@property (weak, nonatomic) IBOutlet UIButton *rightNaviButton;

@property (weak, nonatomic) IBOutlet UIButton *firstCheckButton;
@property (weak, nonatomic) IBOutlet UIButton *usbCheckButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstCheckButtonLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *usbCheckButtonLeading;


@end

@implementation GSHDeviceSocketHandleVC

+ (instancetype)deviceSocketHandleVCDeviceM:(GSHDeviceM *)deviceM deviceEditType:(GSHDeviceVCType)deviceEditType {
    GSHDeviceSocketHandleVC *vc = [TZMPageManager viewControllerWithSB:@"GSHDeviceSocketHandleSB" andID:@"GSHDeviceSocketHandleVC"];
    vc.deviceEditType = deviceEditType;
    vc.deviceM = deviceM;
    vc.exts = deviceM.exts;
    return vc;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tzm_prefersNavigationBarHidden = YES;
    
    NSString *rightNaviButtonTitle = self.deviceEditType == GSHDeviceVCTypeControl ? @"进入设备" : @"确定";
    [self.rightNaviButton setTitle:rightNaviButtonTitle forState:UIControlStateNormal];
    self.rightNaviButton.hidden = ([GSHOpenSDK share].currentFamily.permissions == GSHFamilyMPermissionsMember && self.deviceEditType == GSHDeviceVCTypeControl);
    
    [self getDeviceDetailInfo];
    
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        [self observerNotifications];
    }
    
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        self.firstCheckButton.hidden = YES;
        self.usbCheckButton.hidden = YES;
        self.firstCheckButtonLeading.constant = 0;
        self.usbCheckButtonLeading.constant = 0;
        self.openSwitch.alpha = 1;
        self.usbSwitch.alpha = 1;
    }
    
}

-(void)observerNotifications{
    [self observerNotification:GSHChangeNetworkManagerWebSocketRealDataUpdateNotification];
}

-(void)handleNotifications:(NSNotification *)notification{
    if ([notification.name isEqualToString:GSHChangeNetworkManagerWebSocketRealDataUpdateNotification]) {
        [self refreshUI];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Lazy
- (NSMutableDictionary *)meteIdDic {
    if (!_meteIdDic) {
        _meteIdDic = [NSMutableDictionary dictionary];
    }
    return _meteIdDic;
}

#pragma mark - method

- (IBAction)backButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)enterDeviceButtonClick:(id)sender {
    if (!self.deviceM) {
        [SVProgressHUD showErrorWithStatus:@"设备数据出错"];
        return;
    }
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
            [SVProgressHUD showInfoWithStatus:@"离线环境无法查看"];
            return;
        }
        GSHDeviceEditVC *deviceEditVC = [GSHDeviceEditVC deviceEditVCWithDevice:self.deviceM type:GSHDeviceEditVCTypeEdit];
        @weakify(self)
        deviceEditVC.deviceEditSuccessBlock = ^(GSHDeviceM *deviceM) {
            @strongify(self)
            self.deviceM = deviceM;
            [self refreshUI];
        };
        [self.navigationController pushViewController:deviceEditVC animated:YES];
    } else {
        
        NSMutableArray *exts = [NSMutableArray array];
        
        GSHDeviceExtM *openSwitchExtM = [[GSHDeviceExtM alloc] init];
        openSwitchExtM.basMeteId = SwitchMeteIdKey;
        
        GSHDeviceExtM *usbSwitchExtM = [[GSHDeviceExtM alloc] init];
        usbSwitchExtM.basMeteId = UsbSwitchMeteIdKey;
        
        if (self.deviceEditType == GSHDeviceVCTypeSceneSet) {
            
            openSwitchExtM.rightValue = self.openSwitch.on?@"1":@"0";
            openSwitchExtM.param = self.openSwitch.on?@"开关: 开":@"开关: 关";
            
            usbSwitchExtM.rightValue = self.usbSwitch.on?@"1":@"0";
            usbSwitchExtM.param = self.openSwitch.on?@"USB: 开":@"USB: 关";
            
        } else if (self.deviceEditType == GSHDeviceVCTypeAutoTriggerSet) {
            
            openSwitchExtM.rightValue = self.openSwitch.on?@"1":@"0";
            usbSwitchExtM.rightValue = self.usbSwitch.on?@"1":@"0";
            
        } else if (self.deviceEditType == GSHDeviceVCTypeAutoActionSet) {
            
            openSwitchExtM.param = self.openSwitch.on?@"1":@"0";
            usbSwitchExtM.param = self.usbSwitch.on?@"1":@"0";
        }
        if (self.firstCheckButton.selected) {
            [exts addObject:openSwitchExtM];
        }
        if (self.usbCheckButton.selected) {
            [exts addObject:usbSwitchExtM];
        }
        if (exts.count == 0) {
            [SVProgressHUD showErrorWithStatus:@"请选择插座或USB"];
            return;
        }
        if (self.deviceSetCompleteBlock) {
            self.deviceSetCompleteBlock(exts);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)openSwitchClick:(UISwitch *)sender {
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        NSString *value = [NSString stringWithFormat:@"%d",sender.on];
        if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeWAN) {
            [SVProgressHUD showWithStatus:@"操作中"];
        }
        [GSHDeviceManager deviceControlWithDeviceId:self.deviceM.deviceId.stringValue
                                                   deviceSN:self.deviceM.deviceSn
                                                   familyId:[GSHOpenSDK share].currentFamily.familyId
                                                  basMeteId:SwitchMeteIdKey
                                                      value:value
                                                      block:^(NSError *error) {
              if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeWAN) {
                  if (error && self == [UIViewController visibleTopViewController]) {
                      [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                      sender.on = !sender.on;
                  } else {
                      [SVProgressHUD dismiss];
                  }
              }
        }];
    }
}

- (IBAction)usbSwitchClick:(UISwitch *)sender {
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        NSString *value = [NSString stringWithFormat:@"%d",sender.on];
        if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeWAN) {
            [SVProgressHUD showWithStatus:@"操作中"];
        }
        [GSHDeviceManager deviceControlWithDeviceId:self.deviceM.deviceId.stringValue
                                                   deviceSN:self.deviceM.deviceSn
                                                   familyId:[GSHOpenSDK share].currentFamily.familyId
                                                  basMeteId:UsbSwitchMeteIdKey
                                                      value:value
                                                      block:^(NSError *error) {
            if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeWAN) {
                if (error && self == [UIViewController visibleTopViewController] ) {
                    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                    sender.on = !sender.on;
                } else {
                    [SVProgressHUD dismiss];
                }
            }
        }];
    }
}

- (IBAction)firstCheckButtonClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.openSwitch.alpha = sender.selected ? 1 : 0.5;
    self.openSwitch.enabled = sender.selected;
}

- (IBAction)usbCheckButtonClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.usbSwitch.alpha = sender.selected ? 1 : 0.5;
    self.usbSwitch.enabled = sender.selected;
}

- (void)refreshUI {
    self.deviceNameLabel.text = self.deviceM.deviceName;
    
    NSDictionary *dic = [self.deviceM realTimeDic];
    NSLog(@"dic : %@",dic);
    NSString *electricQuantityValue = [dic objectForKey:ElectricQuantityKey];
    NSString *powerValue = [dic objectForKey:PowerKey];
    self.electricQuantityLabel.text = electricQuantityValue?[NSString stringWithFormat:@"电量: %.2f KWh",electricQuantityValue.floatValue/100.0] : @"电量: 无数据";
    self.powerLabel.text = powerValue?[NSString stringWithFormat:@"功率: %.1f W",powerValue.floatValue/10.0] : @"功率: 无数据";
    
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        
        NSString *switchValue = [dic objectForKey:SwitchMeteIdKey];
        self.openSwitch.on = switchValue.intValue == 0 ? NO : YES;
        NSString *usbSwitchValue = [dic objectForKey:UsbSwitchMeteIdKey];
        self.usbSwitch.on = usbSwitchValue.intValue == 0 ? NO : YES;
    } else {
        if (self.deviceM.exts.count > 0) {
            for (GSHDeviceExtM *extM in self.deviceM.exts) {
                if ([extM.basMeteId isEqualToString:SwitchMeteIdKey]) {
                    if (extM.rightValue) {
                        self.openSwitch.on = extM.rightValue.intValue == 1 ? YES : NO;
                    }
                    if (self.deviceEditType != GSHDeviceVCTypeSceneSet && extM.param) {
                        self.openSwitch.on = extM.param.intValue == 1 ? YES : NO;
                    }
                    self.firstCheckButton.selected = YES;
                    self.openSwitch.alpha = 1;
                } else if ([extM.basMeteId isEqualToString:UsbSwitchMeteIdKey]) {
                    if (extM.rightValue) {
                        self.usbSwitch.on = extM.rightValue.intValue == 1 ? YES : NO;
                    }
                    if (self.deviceEditType != GSHDeviceVCTypeSceneSet && extM.param) {
                        self.usbSwitch.on = extM.param.intValue == 1 ? YES : NO;
                    }
                    self.usbCheckButton.selected = YES;
                    self.usbSwitch.alpha = 1;
                }
            }
        } 
    }
}

#pragma mark - request
// 获取设备详细信息
- (void)getDeviceDetailInfo {
    @weakify(self)
    [SVProgressHUD showWithStatus:@"设备信息获取中"];
    [GSHDeviceManager getDeviceInfoWithFamilyId:[GSHOpenSDK share].currentFamily.familyId deviceId:self.deviceM.deviceId.stringValue block:^(GSHDeviceM *device, NSError *error) {
        @strongify(self)
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [SVProgressHUD dismiss];
            self.deviceM = device;
            for (GSHDeviceAttributeM *attributeM in self.deviceM.attribute) {
                NSString *key = [NSString stringWithFormat:@"%@%@",attributeM.meteType,attributeM.meteIndex];
                [self.meteIdDic setObject:attributeM.basMeteId forKey:key];
            }
            if (self.exts.count > 0) {
                self.deviceM.exts = [self.exts mutableCopy];
            }
            [self refreshUI];
        }
    }];
}

// 设备控制
//- (void)controlDeviceWithBasMeteId:(NSString *)basMeteId
//                             value:(NSString *)value
//                      successBlock:(void(^)(void))successBlock
//{
//
//    [SVProgressHUD showWithStatus:@"操作中"];
//    [GSHDeviceM deviceControlWithDeviceId:self.deviceM.deviceId.stringValue
//                                               deviceSN:self.deviceM.deviceSn
//                                               familyId:[GSHOpenSDK share].currentFamily.familyId
//                                              basMeteId:basMeteId
//                                                  value:value
//                                                  block:^(NSError *error) {
//        if (error) {
//            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
//        } else {
//            [SVProgressHUD dismiss];
//            if (successBlock) {
//                successBlock();
//            }
//        }
//    }];
//}

@end
