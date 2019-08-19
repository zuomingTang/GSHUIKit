//
//  GSHUnderFloorHeatVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/10/19.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import "GSHUnderFloorHeatVC.h"
#import "UINavigationController+TZM.h"
#import "TZMButton.h"
#import "GSHDeviceEditVC.h"
#import "NSObject+TZM.h"

#define UnderFloorHeatSwitchKey @"61"    // 开关状态
#define UnderFloorHeatTemperatureKey @"171"    // 温度
#define UnderFloorHeatTemperatureBasMeteId @"03020600110001"    // 地暖温度basMeteId

@interface GSHUnderFloorHeatVC ()

@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *underFloorHeatNameLabel;
@property (weak, nonatomic) IBOutlet TZMButton *switchButton;
@property (weak, nonatomic) IBOutlet UIButton *rightNaviButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *subButton;

@property (nonatomic,assign) __block int currentTemperatureValue;
@property (nonatomic,strong) GSHDeviceM *deviceM;
@property (nonatomic,strong) NSMutableDictionary *meteIdDic;

@property (assign, nonatomic) GSHDeviceVCType deviceEditType;

@property (nonatomic,strong) NSArray *exts;

@end

@implementation GSHUnderFloorHeatVC

+ (instancetype)underFloorHeatHandleVCDeviceM:(GSHDeviceM *)deviceM deviceEditType:(GSHDeviceVCType)deviceEditType {
    GSHUnderFloorHeatVC *vc = [TZMPageManager viewControllerWithSB:@"GSHUnderFloorHeatSB" andID:@"GSHUnderFloorHeatVC"];
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
    
    self.currentTemperatureValue = 16;
    
    [self getDeviceDetailInfo];
    
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        [self observerNotifications];
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

-(void)dealloc{
    [self removeNotifications];
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
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        // 设备控制 -- 进入设备
        if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
            [SVProgressHUD showInfoWithStatus:@"离线环境无法查看"];
            return;
        }
        if (!self.deviceM) {
            [SVProgressHUD showErrorWithStatus:@"设备数据出错"];
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
        // 确定
        NSMutableArray *exts = [NSMutableArray array];
        NSString *meteId = [self.meteIdDic objectForKey:UnderFloorHeatSwitchKey];
        GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
        extM.basMeteId = meteId;
        
        if (self.deviceEditType == GSHDeviceVCTypeSceneSet) {
            // scene :  rightValue
            if (self.switchButton.selected) {
                // 关
                extM.rightValue = @"0";
                extM.param = @"关";
                [exts addObject:extM];
            } else {
                // 开
                extM.rightValue = @"10";
                extM.param = @"开";
                [exts addObject:extM];
                
                GSHDeviceExtM *temperatureExtM = [[GSHDeviceExtM alloc] init];
                temperatureExtM.basMeteId = UnderFloorHeatTemperatureBasMeteId;
                temperatureExtM.rightValue = [NSString stringWithFormat:@"%d",self.currentTemperatureValue];
                extM.param = [NSString stringWithFormat:@"%d˚C",self.currentTemperatureValue];
                [exts addObject:temperatureExtM];
            }
        } else if (self.deviceEditType == GSHDeviceVCTypeAutoTriggerSet) {
            // auto trigger :  operator rightValue
            extM.conditionOperator = @"==";
            if (self.switchButton.selected) {
                // 关
                extM.rightValue = @"0";
                [exts addObject:extM];
            } else {
                // 开
                extM.rightValue = @"10";
                [exts addObject:extM];
                
                GSHDeviceExtM *temperatureExtM = [[GSHDeviceExtM alloc] init];
//                NSString *temperatureMeteId = [self.meteIdDic objectForKey:UnderFloorHeatTemperatureKey];
                temperatureExtM.basMeteId = UnderFloorHeatTemperatureBasMeteId;
                temperatureExtM.conditionOperator = @"==";
                temperatureExtM.rightValue = [NSString stringWithFormat:@"%d",self.currentTemperatureValue];
                [exts addObject:temperatureExtM];
            }
        } else if (self.deviceEditType == GSHDeviceVCTypeAutoActionSet) {
            // auto action :  param
            if (self.switchButton.selected) {
                // 关
                extM.param = @"0";
                [exts addObject:extM];
            } else {
                // 开
                extM.param = @"10";
                [exts addObject:extM];
                
                GSHDeviceExtM *temperatureExtM = [[GSHDeviceExtM alloc] init];
//                NSString *temperatureMeteId = [self.meteIdDic objectForKey:UnderFloorHeatTemperatureKey];
                temperatureExtM.basMeteId = UnderFloorHeatTemperatureBasMeteId;
                temperatureExtM.param = [NSString stringWithFormat:@"%d",self.currentTemperatureValue];
                [exts addObject:temperatureExtM];
            }
        }
        if (self.deviceSetCompleteBlock) {
            self.deviceSetCompleteBlock(exts);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

// 加温度
- (IBAction)upButtonClick:(id)sender {
    if (self.switchButton.selected) {
        return;
    }
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        if (self.currentTemperatureValue < 32) {
            NSString *meteId = UnderFloorHeatTemperatureBasMeteId;
            NSString *value = [NSString stringWithFormat:@"%d",(int)self.currentTemperatureValue+1];
            if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
                [self refreshUIToAddTemperature];
            }
            @weakify(self)
            [self controlUnderFloorHeatWithBasMeteId:meteId value:value failBlock:^(NSError *error) {
                
            } successBlock:^() {
                @strongify(self)
                [self refreshUIToAddTemperature];
            }];
        }
    } else {
        if (self.currentTemperatureValue < 32) {
            [self refreshUIToAddTemperature];
        }
    }
}

// 增温度刷新页面
- (void)refreshUIToAddTemperature {
    self.currentTemperatureValue++;
    self.temperatureLabel.text = [NSString stringWithFormat:@"%d",(int)self.currentTemperatureValue];
    self.addButton.enabled = self.currentTemperatureValue == 32 ? NO : YES;
    self.subButton.enabled = self.currentTemperatureValue == 16 ? NO : YES;
}

// 减温度
- (IBAction)downButtonClick:(id)sender {
    if (self.switchButton.selected) {
        return;
    }
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        if (self.currentTemperatureValue > 16) {
            
            NSString *value = [NSString stringWithFormat:@"%d",(int)self.currentTemperatureValue-1];
            NSString *meteId = UnderFloorHeatTemperatureBasMeteId;
            if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
                [self refreshUIToSubTemperature];
            }
            @weakify(self)
            [self controlUnderFloorHeatWithBasMeteId:meteId value:value failBlock:^(NSError *error) {
                
            } successBlock:^() {
                @strongify(self)
                [self refreshUIToSubTemperature];
            }];
            
        }
    } else {
        if (self.currentTemperatureValue > 16) {
            [self refreshUIToSubTemperature];
        }
    }
}
// 减温度刷新页面
- (void)refreshUIToSubTemperature {
    self.currentTemperatureValue--;
    self.temperatureLabel.text = [NSString stringWithFormat:@"%d",(int)self.currentTemperatureValue];
    self.addButton.enabled = self.currentTemperatureValue == 32 ? NO : YES;
    self.subButton.enabled = self.currentTemperatureValue == 16 ? NO : YES;
}

- (IBAction)switchButtonClick:(UIButton *)button {
    
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        __weak typeof(button) weakButton = button;
        @weakify(self)
        if ([self.meteIdDic containsObjectForKey:UnderFloorHeatSwitchKey]) {
            NSString *meteId = [self.meteIdDic objectForKey:UnderFloorHeatSwitchKey];
            NSString *value;
            if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
                [self switchButtonClickToRefreshUIWithButton:button];
                value = button.selected ? @"0" : @"10";
            } else {
                value = button.selected ? @"10" : @"0";
            }
            [self controlUnderFloorHeatWithBasMeteId:meteId value:value failBlock:^(NSError *error) {
                
            } successBlock:^{
                __strong typeof(weakButton) strongButton = weakButton;
                @strongify(self)
                [self switchButtonClickToRefreshUIWithButton:strongButton];
            }];
        }
    } else {
        [self switchButtonClickToRefreshUIWithButton:button];
    }
}

- (void)switchButtonClickToRefreshUIWithButton:(UIButton *)button {
    button.selected = !button.selected;
    self.backImageView.image = button.selected ? [UIImage imageNamed:@"app_freshair_pic_close"] : [UIImage imageNamed:@"floorheating_bg_sel"];
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
- (void)controlUnderFloorHeatWithBasMeteId:(NSString *)basMeteId
                                     value:(NSString *)value
                                 failBlock:(void(^)(NSError *error))failBlock
                              successBlock:(void(^)(void))successBlock {
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeWAN) {
        [SVProgressHUD showWithStatus:@"操作中"];
    }
    [GSHDeviceManager deviceControlWithDeviceId:self.deviceM.deviceId.stringValue
                                               deviceSN:self.deviceM.deviceSn
                                               familyId:[GSHOpenSDK share].currentFamily.familyId
                                              basMeteId:basMeteId
                                                  value:value
                                                  block:^(NSError *error) {
        if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeWAN) {
            if (error && self == [UIViewController visibleTopViewController]) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                if (failBlock) {
                    failBlock(error);
                }
            } else {
                [SVProgressHUD dismiss];
                if (successBlock) {
                    successBlock();
                }
            }
        }
    }];
}

// 设备控制
//- (void)controlDeviceWithBasMeteId:(NSString *)basMeteId
//                             value:(NSString *)value
//                      successBlock:(void(^)(void))successBlock {
//
//    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeWAN) {
//        [SVProgressHUD showWithStatus:@"操作中"];
//    }
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

#pragma mark -  刷新UI
- (void)refreshUI {
    
    self.underFloorHeatNameLabel.text = self.deviceM.deviceName;
    NSString *meteId = [self.meteIdDic objectForKey:UnderFloorHeatSwitchKey];
    NSString *temperatureMeteId = UnderFloorHeatTemperatureBasMeteId;
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        NSDictionary *dic = [self.deviceM realTimeDic];
        id value = [dic objectForKey:meteId];
        if (value) {
            // 开关状态有值
            if ([value intValue] == 0) {
                // 地暖 关
                self.switchButton.selected = YES;
                self.backImageView.image = [UIImage imageNamed:@"app_freshair_pic_close"];
            } else if ([value intValue] == 10) {
                // 地暖 开
                self.switchButton.selected = NO;
                self.backImageView.image = [UIImage imageNamed:@"floorheating_bg_sel"];
            }
            id temperatureValue = [dic objectForKey:temperatureMeteId];
            if (temperatureValue) {
                self.currentTemperatureValue = [temperatureValue floatValue];
                self.temperatureLabel.text = [NSString stringWithFormat:@"%d",[temperatureValue intValue]];
            }
        } else {
            [SVProgressHUD showErrorWithStatus:@"websocket数据出错"];
        }
    } else {
        if (self.deviceM.exts.count > 0) {
            for (GSHDeviceExtM *extM in self.deviceM.exts) {
                if ([extM.basMeteId isEqualToString:meteId]) {
                    if (extM.rightValue) {
                        self.switchButton.selected = [extM.rightValue isEqualToString:@"0"] ? YES : NO;
                    }
                    if (self.deviceEditType != GSHDeviceVCTypeSceneSet && extM.param) {
                        self.switchButton.selected = [extM.param isEqualToString:@"0"] ? YES : NO;
                    }
                }
            }
            if (!self.switchButton.selected && self.deviceM.exts.count > 1) {
                self.backImageView.image = [UIImage imageNamed:@"floorheating_bg_sel"];
                for (GSHDeviceExtM *extM in self.deviceM.exts) {
                    if ([extM.basMeteId isEqualToString:temperatureMeteId]) {
                        NSString *value = extM.rightValue?extM.rightValue:(extM.param?extM.param:@"");
                        if (value.length>0) {
                            self.currentTemperatureValue = [value intValue];
                            self.temperatureLabel.text = [NSString stringWithFormat:@"%d",[value intValue]];
                            self.addButton.enabled = self.currentTemperatureValue == 32 ? NO : YES;
                            self.subButton.enabled = self.currentTemperatureValue == 16 ? NO : YES;
                        }
                    }
                }
            } else {
                self.backImageView.image = [UIImage imageNamed:@"app_freshair_pic_close"];
                self.currentTemperatureValue = 16.0;
                self.temperatureLabel.text = @"16";
                self.subButton.enabled = NO;
            }
        } else {
            self.currentTemperatureValue = 16.0;
            self.temperatureLabel.text = @"16";
            self.subButton.enabled = NO;
        }
    }
}

@end
