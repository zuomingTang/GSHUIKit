//
//  GSHNewWindHandleVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/9/7.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHNewWindHandleVC.h"
#import "UINavigationController+TZM.h"

#import "TZMButton.h"
#import "GSHDeviceEditVC.h"
#import <GSHOpenSDKSoundCode/GSHDeviceM.h>
#import "NSObject+TZM.h"

#define NewWindSwitchKey @"112"    // 开关状态
#define NewWindWindSpeedKey @"111"    // 风速

@interface GSHNewWindHandleVC ()

@property (weak, nonatomic) IBOutlet UIButton *rightNaviButton;
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet TZMButton *switchButton;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;

@property (nonatomic,strong) NSString *deviceId;
@property (nonatomic,strong) GSHDeviceM *deviceM;
//@property (nonatomic,strong) GSHDeviceM *editDeviceM;
@property (nonatomic,strong) NSMutableDictionary *meteIdDic;

@property (assign, nonatomic) GSHDeviceVCType deviceEditType;

@property (nonatomic,strong) NSArray *exts;

@end

@implementation GSHNewWindHandleVC

+ (instancetype)newWindHandleVCWithDeviceM:(GSHDeviceM *)deviceM deviceEditType:(GSHDeviceVCType)deviceEditType {
    GSHNewWindHandleVC *vc = [TZMPageManager viewControllerWithSB:@"GSHNewWindHandleSB" andID:@"GSHNewWindHandleVC"];
    vc.deviceM = deviceM;
    vc.deviceEditType = deviceEditType;
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
        // 设备控制模式 注册通知
        [self observerNotifications];
    }
}

-(void)observerNotifications{
    [self observerNotification:GSHChangeNetworkManagerWebSocketRealDataUpdateNotification];
}

-(void)handleNotifications:(NSNotification *)notification{
    if ([notification.name isEqualToString:GSHChangeNetworkManagerWebSocketRealDataUpdateNotification]) {
        [self notiHandle];
    }
}

-(void)dealloc{
    [self removeNotifications];
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

- (IBAction)switchButtonClick:(UIButton *)button {
    
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        // 设备控制
        __weak typeof(button) weakButton = button;
        @weakify(self)
        if ([self.meteIdDic containsObjectForKey:NewWindSwitchKey]) {
            NSString *meteId = [self.meteIdDic objectForKey:NewWindSwitchKey];
            NSString *value;
            if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
                // 离线控制模式 -- 开关按钮点击首先修改UI
                [self switchButtonClickToRefreshUIWithButton:button];
                value = button.selected ? @"0" : @"4";
            } else {
                value = button.selected ? @"4" : @"0";
            }
            [self controlDeviceWithBasMeteId:meteId value:value successBlock:^() {
                __strong typeof(weakButton) strongButton = weakButton;
                @strongify(self)
                [SVProgressHUD dismiss];
                [self switchButtonClickToRefreshUIWithButton:strongButton];
            }];
        }
    } else {
        // 联动 -- 设备设置
        [self switchButtonClickToRefreshUIWithButton:button];
    }
}

- (void)switchButtonClickToRefreshUIWithButton:(UIButton *)button {
    button.selected = !button.selected;
    if (button.selected) {
        for (int i = 1; i < 4; i ++) {
            UIButton *tmpButton = [self.view viewWithTag:i];
            tmpButton.selected = NO;
        }
    }
    self.backImageView.image = button.selected ? [UIImage imageNamed:@"app_freshair_pic_close"] : [UIImage imageNamed:@"app_freshair_pic_bg"];
    self.iconImageView.image = button.selected ? [UIImage imageNamed:@"newtrend_icon_close"] : [UIImage imageNamed:@"newtrend_icon"];
}

- (IBAction)handleButtonClick:(UIButton *)button {
    
    if (button.selected) {
        return;
    }
    if (self.switchButton.selected) {
        return;
    }
    NSInteger tag = button.tag;
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        // 设备控制
        if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
            // 离线控制模式 -- 开关按钮点击首先修改UI
            [self handleButtonClickToRefreshUIWithButton:button];
        }
        NSString *value = [NSString stringWithFormat:@"%d",(int)tag];
        @weakify(self)
        __weak typeof(button) weakButton = button;
        if ([self.meteIdDic containsObjectForKey:NewWindWindSpeedKey]) {
            NSString *meteId = [self.meteIdDic objectForKey:NewWindWindSpeedKey];
            [self controlDeviceWithBasMeteId:meteId value:value successBlock:^() {
                @strongify(self)
                __strong typeof(weakButton) strongButton = weakButton;
                [self handleButtonClickToRefreshUIWithButton:strongButton];
            }];
        }
    } else {
        // 情景、联动 -- 设备设置
        [self handleButtonClickToRefreshUIWithButton:button];
    }
}

- (void)handleButtonClickToRefreshUIWithButton:(UIButton *)button {
    for (int i = 1; i < 4; i ++) {
        UIButton *tmpButton = [self.view viewWithTag:i];
        tmpButton.selected = NO;
    }
    button.selected = YES;
}

- (IBAction)enterDevice:(id)sender {
    
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
        NSString *meteId = [self.meteIdDic objectForKey:NewWindSwitchKey];
        GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
        extM.basMeteId = meteId;
        if (self.deviceEditType == GSHDeviceVCTypeSceneSet) {
            // scene :  rightValue
            if (self.switchButton.selected) {
                // 关
                extM.rightValue = @"0";
                extM.param = @"关";
            } else {
                // 开
                extM.rightValue = @"4";
                extM.param = @"开";
                for (int i = 1; i < 4; i ++) {
                    UIButton *tmpButton = [self.view viewWithTag:i];
                    if (tmpButton.selected) {
                        // 有风量按钮选中
                        NSString *speedMeteId = [self.meteIdDic objectForKey:NewWindWindSpeedKey];
                        GSHDeviceExtM *speedExtM = [[GSHDeviceExtM alloc] init];
                        speedExtM.basMeteId = speedMeteId;
                        speedExtM.rightValue = [NSString stringWithFormat:@"%d",i];
                        NSString *windSpeedStr = @"";
                        if (i == 1) {
                            windSpeedStr = @"低风";
                        } else if (i == 2) {
                            windSpeedStr = @"中风";
                        } else if (i == 3) {
                            windSpeedStr = @"高风";
                        }
                        speedExtM.param = windSpeedStr;
                        [exts addObject:speedExtM];
                        break;
                    }
                }
            }
        } else  if (self.deviceEditType == GSHDeviceVCTypeAutoTriggerSet) {
            // auto trigger :  operator rightValue
            extM.conditionOperator = @"==";
            if (self.switchButton.selected) {
                // 关
                extM.rightValue = @"0";
                [exts addObject:extM];
            } else {
                // 开
                extM.rightValue = @"4";
                [exts addObject:extM];
                for (int i = 1; i < 4; i ++) {
                    UIButton *tmpButton = [self.view viewWithTag:i];
                    if (tmpButton.selected) {
                        // 有风量按钮选中
                        NSString *speedMeteId = [self.meteIdDic objectForKey:NewWindWindSpeedKey];
                        GSHDeviceExtM *speedExtM = [[GSHDeviceExtM alloc] init];
                        speedExtM.basMeteId = speedMeteId;
                        speedExtM.conditionOperator = @"==";
                        speedExtM.rightValue = [NSString stringWithFormat:@"%d",i];
                        [exts addObject:speedExtM];
                        break;
                    }
                }
            }
        } else  if (self.deviceEditType == GSHDeviceVCTypeAutoActionSet) {
            // auto action :  param
            if (self.switchButton.selected) {
                // 关
                extM.param = @"0";
            } else {
                // 开
                extM.param = @"4";
                for (int i = 1; i < 4; i ++) {
                    UIButton *tmpButton = [self.view viewWithTag:i];
                    if (tmpButton.selected) {
                        // 有风量按钮选中
                        NSString *speedMeteId = [self.meteIdDic objectForKey:NewWindWindSpeedKey];
                        GSHDeviceExtM *speedExtM = [[GSHDeviceExtM alloc] init];
                        speedExtM.basMeteId = speedMeteId;
                        speedExtM.param = [NSString stringWithFormat:@"%d",i];
                        [exts addObject:speedExtM];
                        break;
                    }
                }
            }
        }
        [exts addObject:extM];
        if (self.deviceSetCompleteBlock) {
            self.deviceSetCompleteBlock(exts);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

// 接收到实时数据的通知后的处理方法
- (void)notiHandle {
    NSLog(@"real time data refresh UI");
    [self refreshUI];
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
            [self refreshUI];
            if (self.exts.count > 0) {
                self.deviceM.exts = [self.exts mutableCopy];
            }
            [self refreshUI];
        }
    }];
}

// 设备控制
- (void)controlDeviceWithBasMeteId:(NSString *)basMeteId
                             value:(NSString *)value
                      successBlock:(void(^)(void))successBlock {
    
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeWAN) {
        [SVProgressHUD showWithStatus:@"操作中"];
    }
    [GSHDeviceManager deviceControlWithDeviceId:self.deviceM.deviceId.stringValue deviceSN:self.deviceM.deviceSn familyId:[GSHOpenSDK share].currentFamily.familyId basMeteId:basMeteId value:value block:^(NSError *error) {
        if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeWAN) {
            if (error && self == [UIViewController visibleTopViewController]) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            } else {
                [SVProgressHUD dismiss];
                if (successBlock) {
                    successBlock();
                }
            }
        }
    }];
    
}

- (void)refreshUI {
    
    self.deviceNameLabel.text = self.deviceM.deviceName;
    NSString *meteId = [self.meteIdDic objectForKey:NewWindSwitchKey];
    NSString *windSpeedMeteId = [self.meteIdDic objectForKey:NewWindWindSpeedKey];
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        // 设备控制
        NSDictionary *dic = [self.deviceM realTimeDic];
        id value = [dic objectForKey:meteId];
        if (value) {
            // 开关状态有值
            if ([value intValue] == 0) {
                // 新风 关
                self.switchButton.selected = YES;
                for (int i = 1; i < 4; i ++) {
                    UIButton *tmpButton = [self.view viewWithTag:i];
                    tmpButton.selected = NO;
                }
                self.backImageView.image = [UIImage imageNamed:@"app_freshair_pic_close"];
                self.iconImageView.image = [UIImage imageNamed:@"newtrend_icon_close"];
            } else if ([value intValue] == 4) {
                // 新风 开
                self.switchButton.selected = NO;
                self.backImageView.image = [UIImage imageNamed:@"app_freshair_pic_bg"];
                self.iconImageView.image = [UIImage imageNamed:@"newtrend_icon"];
                id windSpeedValue = [dic objectForKey:windSpeedMeteId];
                if (windSpeedValue) {
                    for (int i = 1; i < 4; i ++) {
                        UIButton *tmpButton = [self.view viewWithTag:i];
                        tmpButton.selected = NO;
                    }
                    if ([windSpeedValue intValue] == 1 || [windSpeedValue intValue] == 2 || [windSpeedValue intValue] == 3) {
                        UIButton *openButton = [self.view viewWithTag:[windSpeedValue intValue]];
                        openButton.selected = YES;
                    }
                }
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
            if (!self.switchButton.selected && self.deviceM.exts.count > 0) {
                // 新风开 且选择有风速
                self.backImageView.image = [UIImage imageNamed:@"app_freshair_pic_bg"];
                self.iconImageView.image = [UIImage imageNamed:@"newtrend_icon"];
                for (GSHDeviceExtM *extM in self.deviceM.exts) {
                    if ([extM.basMeteId isEqualToString:windSpeedMeteId]) {
                        for (int i = 1; i < 4; i ++) {
                            UIButton *tmpButton = [self.view viewWithTag:i];
                            tmpButton.selected = NO;
                        }
                        NSString *value = extM.rightValue?extM.rightValue:(extM.param?extM.param:@"");
                        if (value.length>0) {
                            UIButton *selectSpeedButton = [self.view viewWithTag:value.integerValue];
                            selectSpeedButton.selected = YES;
                        }
                    }
                }
            } else {
                // 关
                self.backImageView.image = [UIImage imageNamed:@"app_freshair_pic_close"];
                self.iconImageView.image = [UIImage imageNamed:@"newtrend_icon_close"];
                for (int i = 1; i < 4; i ++) {
                    UIButton *tmpButton = [self.view viewWithTag:i];
                    tmpButton.selected = NO;
                }
            }
        }
    }
}

@end
