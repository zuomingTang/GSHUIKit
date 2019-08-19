//
//  GSHThreeWaySwitchHandleVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/6/6.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHThreeWaySwitchHandleVC.h"
#import "UIView+TZM.h"
#import "UINavigationController+TZM.h"
#import "GSHDeviceEditVC.h"
#import <GSHOpenSDKSoundCode/GSHDeviceM.h>
#import "NSObject+TZM.h"


@interface GSHThreeWaySwitchHandleVC ()

@property (nonatomic,strong) GSHDeviceM *deviceM;
//@property (nonatomic,strong) GSHDeviceM *editDeviceM;

@property (weak, nonatomic) IBOutlet UIButton *rightNaviButton;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@property (weak, nonatomic) IBOutlet UIView *firstSwitchView;
@property (weak, nonatomic) IBOutlet UILabel *firstSwitchNameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *firstSwitch;
@property (weak, nonatomic) IBOutlet UIButton *firstCheckButton;

@property (weak, nonatomic) IBOutlet UIView *secondSwitchView;
@property (weak, nonatomic) IBOutlet UILabel *secondSwitchNameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *secondSwitch;
@property (weak, nonatomic) IBOutlet UIButton *secondCheckButton;

@property (weak, nonatomic) IBOutlet UIView *thirdSwitchView;
@property (weak, nonatomic) IBOutlet UILabel *thirdSwitchNameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *thirdSwitch;
@property (weak, nonatomic) IBOutlet UIButton *thirdCheckButton;

@property (weak, nonatomic) IBOutlet UILabel *switchNameLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstCheckButtonLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secondCheckButtonLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *thirdCheckButtonLeading;

@property (assign, nonatomic) GSHDeviceVCType deviceEditType;
@property (nonatomic,strong) NSArray *exts;

@end

@implementation GSHThreeWaySwitchHandleVC

+ (instancetype)threeWaySwitchHandleVCWithDeviceM:(GSHDeviceM*)deviceM deviceEditType:(GSHDeviceVCType)deviceEditType {
    GSHThreeWaySwitchHandleVC *vc = [TZMPageManager viewControllerWithSB:@"GSHThreeWaySwitchHandleSB" andID:@"GSHThreeWaySwitchHandleVC"];
    vc.deviceM = deviceM;
    vc.deviceEditType = deviceEditType;
    vc.exts = deviceM.exts;
    return vc;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - init

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tzm_prefersNavigationBarHidden = YES;
    
    [self layoutUI];
    
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

#pragma mark - UI
- (void)layoutUI {
    
    if (self.switchType == SwitchHandleVCTypeOneWay) {
        // 一路智能开关
        self.firstSwitchView.hidden = YES;
        self.secondSwitchView.hidden = YES;
        self.thirdSwitchView.hidden = NO;
        self.switchNameLabel.text = @"一路开关";
        self.iconImageView.image = [UIImage imageNamed:@"equipment_icon_oneswitch_export"];
    } else if (self.switchType == SwitchHandleVCTypeTwoWay) {
        // 二路智能开关
        self.firstSwitchView.hidden = YES;
        self.secondSwitchView.hidden = NO;
        self.thirdSwitchView.hidden = NO;
        self.switchNameLabel.text = @"二路开关";
        self.iconImageView.image = [UIImage imageNamed:@"equipment_icon_twoswitch_export"];
    } else if (self.switchType == SwitchHandleVCTypeThreeWay) {
        // 三路智能开关
        self.firstSwitchView.hidden = NO;
        self.secondSwitchView.hidden = NO;
        self.thirdSwitchView.hidden = NO;
        self.switchNameLabel.text = @"三路开关";
        self.iconImageView.image = [UIImage imageNamed:@"equipment_icon_threeswitch_export"];
    }
    
    NSString *rightNaviButtonTitle = self.deviceEditType == GSHDeviceVCTypeControl ? @"进入设备" : @"确定";
    [self.rightNaviButton setTitle:rightNaviButtonTitle forState:UIControlStateNormal];
    self.rightNaviButton.hidden = ([GSHOpenSDK share].currentFamily.permissions == GSHFamilyMPermissionsMember && self.deviceEditType == GSHDeviceVCTypeControl);
    
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        self.firstCheckButton.hidden = YES;
        self.secondCheckButton.hidden = YES;
        self.thirdCheckButton.hidden = YES;
        self.firstCheckButtonLeading.constant = 0;
        self.secondCheckButtonLeading.constant = 0;
        self.thirdCheckButtonLeading.constant = 0;
        self.firstSwitch.alpha = 1;
        self.secondSwitch.alpha = 1;
        self.thirdSwitch.alpha = 1;
    }
    
}

- (void)refreshUI {
    
    self.switchNameLabel.text = self.deviceM.deviceName;
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        // 设备控制
        NSDictionary *dic = [self.deviceM realTimeDic];
        if (self.switchType == SwitchHandleVCTypeOneWay) {
            // 一路智能开关
            if (self.deviceM.attribute.count > 0) {
                GSHDeviceAttributeM *attributeM = (GSHDeviceAttributeM *)self.deviceM.attribute[0];
                self.thirdSwitchNameLabel.text = attributeM.meteName;
                id value = [dic objectForKey:attributeM.basMeteId];
                self.thirdSwitch.on = value ? [value intValue] : 0;
                self.thirdSwitch.tag = 1;
            }
        } else if (self.switchType == SwitchHandleVCTypeTwoWay) {
            // 二路智能开关
            if (self.deviceM.attribute.count > 1) {
                for (GSHDeviceAttributeM *attributeM in self.deviceM.attribute) {
                    id value = [dic objectForKey:attributeM.basMeteId];
                    if (attributeM.meteIndex.intValue == 1) {
                        self.secondSwitchNameLabel.text = attributeM.meteName;
                        self.secondSwitch.on = value ? [value intValue] : 0;
                        self.secondSwitch.tag = 1;
                    } else if (attributeM.meteIndex.intValue == 2) {
                        self.thirdSwitchNameLabel.text = attributeM.meteName;
                        self.thirdSwitch.on = value ? [value intValue] : 0;
                        self.thirdSwitch.tag = 2;
                    }
                }
            }
        } else if (self.switchType == SwitchHandleVCTypeThreeWay) {
            // 三路智能开关
            if (self.deviceM.attribute.count > 2) {
                for (GSHDeviceAttributeM *attributeM in self.deviceM.attribute) {
                    id value = [dic objectForKey:attributeM.basMeteId];
                    if (attributeM.meteIndex.intValue == 1) {
                        self.firstSwitchNameLabel.text = attributeM.meteName;
                        self.firstSwitch.on = value ? [value intValue] : 0;
                        self.firstSwitch.tag = 1;
                    } else if (attributeM.meteIndex.intValue == 2) {
                        self.secondSwitchNameLabel.text = attributeM.meteName;
                        self.secondSwitch.on = value ? [value intValue] : 0;
                        self.secondSwitch.tag = 2;
                    } else if (attributeM.meteIndex.intValue == 3) {
                        self.thirdSwitchNameLabel.text = attributeM.meteName;
                        self.thirdSwitch.on = value ? [value intValue] : 0;
                        self.thirdSwitch.tag = 3;
                    }
                }
            }
        }
    } else {
        if (self.switchType == SwitchHandleVCTypeOneWay) {
            // 一路智能开关
            if (self.deviceM.attribute.count > 0) {
                GSHDeviceAttributeM *attributeM = (GSHDeviceAttributeM *)self.deviceM.attribute[0];
                self.thirdSwitchNameLabel.text = attributeM.meteName;
                self.thirdSwitch.tag = 1;
            }
        } else if (self.switchType == SwitchHandleVCTypeTwoWay) {
            // 二路智能开关
            if (self.deviceM.attribute.count > 1) {
                for (GSHDeviceAttributeM *attributeM in self.deviceM.attribute) {
                    if (attributeM.meteIndex.intValue == 1) {
                        self.secondSwitchNameLabel.text = attributeM.meteName;
                        self.secondSwitch.tag = 1;
                    } else if (attributeM.meteIndex.intValue == 2) {
                        self.thirdSwitchNameLabel.text = attributeM.meteName;
                        self.thirdSwitch.tag = 2;
                    }
                }
            }
        } else if (self.switchType == SwitchHandleVCTypeThreeWay) {
            // 三路智能开关
            if (self.deviceM.attribute.count > 2) {
                for (GSHDeviceAttributeM *attributeM in self.deviceM.attribute) {
                    if (attributeM.meteIndex.intValue == 1) {
                        self.firstSwitchNameLabel.text = attributeM.meteName;
                        self.firstSwitch.tag = 1;
                    } else if (attributeM.meteIndex.intValue == 2) {
                        self.secondSwitchNameLabel.text = attributeM.meteName;
                        self.secondSwitch.tag = 2;
                    } else if (attributeM.meteIndex.intValue == 3) {
                        self.thirdSwitchNameLabel.text = attributeM.meteName;
                        self.thirdSwitch.tag = 3;
                    }
                }
            }
        }
    }
}

#pragma mark - method
- (IBAction)backButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)switchButtonClick:(UISwitch *)gshSwitch {
    
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        // 设备控制
        NSInteger tag = gshSwitch.tag;
        if (self.deviceM.attribute.count >= tag && tag > 0) {
            GSHDeviceAttributeM *attributeM;
            for (GSHDeviceAttributeM *tmpAttributeM in self.deviceM.attribute) {
                if (tmpAttributeM.meteIndex.intValue == tag) {
                    attributeM = tmpAttributeM;
                }
            }
            if (!attributeM) {
                return;
            }
            if([GSHWebSocketClient shared].networkType == GSHNetworkTypeWAN) {
                [SVProgressHUD showWithStatus:@"操作中"];
            }
            NSString *value = [NSString stringWithFormat:@"%d",gshSwitch.on];
            @weakify(self)
            [GSHDeviceManager deviceControlWithDeviceId:self.deviceM.deviceId.stringValue deviceSN:self.deviceM.deviceSn familyId:[GSHOpenSDK share].currentFamily.familyId basMeteId:attributeM.basMeteId value:value block:^(NSError *error) {
                @strongify(self)
                if([GSHWebSocketClient shared].networkType == GSHNetworkTypeWAN) {
                    if (error && self == [UIViewController visibleTopViewController]) {
                        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                        gshSwitch.on = !gshSwitch.on;
                    } else {
                        [SVProgressHUD dismiss];
                    }
                }
            }];
        } else {
            [SVProgressHUD showErrorWithStatus:@"服务器数据错误"];
        }
    }
}

- (IBAction)enterDeviceEdit:(id)sender {

    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        // 设备控制 -- 进入设备
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
        // 确定
        NSMutableArray *exts = [NSMutableArray array];
        
        if (self.deviceEditType == GSHDeviceVCTypeSceneSet) {
            // scene set :  rightValue
            if (self.switchType == SwitchHandleVCTypeOneWay) {
                // 一路智能开关
                if (self.thirdCheckButton.selected) {
                    // 选中
                    if (self.deviceM.attribute.count > 0) {
                        GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
                        GSHDeviceAttributeM *attributeM = (GSHDeviceAttributeM *)self.deviceM.attribute[0];
                        extM.basMeteId = attributeM.basMeteId;
                        extM.rightValue = [NSString stringWithFormat:@"%d",self.thirdSwitch.on];
                        NSString *switchStr = self.thirdSwitch.on ? @"开" : @"关";
                        extM.param = [NSString stringWithFormat:@"一路%@",switchStr];
                        [exts addObject:extM];
                    }
                } else {
                    [SVProgressHUD showErrorWithStatus:@"请选中开关按钮"];
                    return;
                }
            } else if (self.switchType == SwitchHandleVCTypeTwoWay) {
                // 二路开关
                if (self.deviceM.attribute.count > 1) {
                    for (GSHDeviceAttributeM *attributeM in self.deviceM.attribute) {
                        if (attributeM.meteIndex.intValue == 1 && self.secondCheckButton.selected) {
                            GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
                            extM.basMeteId = attributeM.basMeteId;
                            extM.rightValue = [NSString stringWithFormat:@"%d",self.secondSwitch.on];
                            NSString *switchStr = self.secondSwitch.on ? @"开" : @"关";
                            extM.param = [NSString stringWithFormat:@"一路%@",switchStr];
                            [exts addObject:extM];
                        } else if (attributeM.meteIndex.intValue == 2 && self.thirdCheckButton.selected) {
                            GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
                            extM.basMeteId = attributeM.basMeteId;
                            extM.rightValue = [NSString stringWithFormat:@"%d",self.thirdSwitch.on];
                            NSString *switchStr = self.thirdSwitch.on ? @"开" : @"关";
                            extM.param = [NSString stringWithFormat:@"二路%@",switchStr];
                            [exts addObject:extM];
                        }
                    }
                    if (exts.count == 0) {
                        [SVProgressHUD showErrorWithStatus:@"请选中开关按钮"];
                        return;
                    }
                }
            } else if (self.switchType == SwitchHandleVCTypeThreeWay) {
                // 三路开关
                if (self.deviceM.attribute.count > 2) {
                    for (GSHDeviceAttributeM *attributeM in self.deviceM.attribute) {
                        if (attributeM.meteIndex.intValue == 1 && self.firstCheckButton.selected) {
                            GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
                            extM.basMeteId = attributeM.basMeteId;
                            extM.rightValue = [NSString stringWithFormat:@"%d",self.firstSwitch.on];
                            NSString *switchStr = self.firstSwitch.on ? @"开" : @"关";
                            extM.param = [NSString stringWithFormat:@"一路%@",switchStr];
                            [exts addObject:extM];
                        } else if (attributeM.meteIndex.intValue == 2 && self.secondCheckButton.selected) {
                            GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
                            extM.basMeteId = attributeM.basMeteId;
                            extM.rightValue = [NSString stringWithFormat:@"%d",self.secondSwitch.on];
                            NSString *switchStr = self.secondSwitch.on ? @"开" : @"关";
                            extM.param = [NSString stringWithFormat:@"二路%@",switchStr];
                            [exts addObject:extM];
                        } else if (attributeM.meteIndex.intValue == 3 && self.thirdCheckButton.selected) {
                            GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
                            extM.basMeteId = attributeM.basMeteId;
                            extM.rightValue = [NSString stringWithFormat:@"%d",self.thirdSwitch.on];
                            NSString *switchStr = self.thirdSwitch.on ? @"开" : @"关";
                            extM.param = [NSString stringWithFormat:@"三路%@",switchStr];
                            [exts addObject:extM];
                        }
                    }
                    if (exts.count == 0) {
                        [SVProgressHUD showErrorWithStatus:@"请选中开关按钮"];
                        return;
                    }
                }
            }
        } else if (self.deviceEditType == GSHDeviceVCTypeAutoTriggerSet) {
            // auto trigger :  operator rightValue
            if (self.switchType == SwitchHandleVCTypeOneWay) {
                // 一路智能开关
                if (self.deviceM.attribute.count > 0) {
                    if (self.thirdCheckButton.selected) {
                        GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
                        GSHDeviceAttributeM *attributeM = (GSHDeviceAttributeM *)self.deviceM.attribute[0];
                        extM.basMeteId = attributeM.basMeteId;
                        extM.conditionOperator = @"==";
                        extM.rightValue = [NSString stringWithFormat:@"%d",self.thirdSwitch.on];
                        [exts addObject:extM];
                    } else {
                        [SVProgressHUD showErrorWithStatus:@"请选中开关按钮"];
                        return;
                    }
                }
            } else if (self.switchType == SwitchHandleVCTypeTwoWay) {
                // 二路开关
                if (self.deviceM.attribute.count > 1) {
                    for (GSHDeviceAttributeM *attributeM in self.deviceM.attribute) {
                        if (attributeM.meteIndex.intValue == 1 && self.secondCheckButton.selected) {
                            GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
                            extM.basMeteId = attributeM.basMeteId;
                            extM.conditionOperator = @"==";
                            extM.rightValue = [NSString stringWithFormat:@"%d",self.secondSwitch.on];
                            [exts addObject:extM];
                        } else if (attributeM.meteIndex.intValue == 2 && self.thirdCheckButton.selected) {
                            GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
                            extM.basMeteId = attributeM.basMeteId;
                            extM.conditionOperator = @"==";
                            extM.rightValue = [NSString stringWithFormat:@"%d",self.thirdSwitch.on];
                            [exts addObject:extM];
                        }
                    }
                    if (exts.count == 0) {
                        [SVProgressHUD showErrorWithStatus:@"请选中开关按钮"];
                        return;
                    }
                }
            } else if (self.switchType == SwitchHandleVCTypeThreeWay) {
                // 三路开关
                if (self.deviceM.attribute.count > 2) {
                    for (GSHDeviceAttributeM *attributeM in self.deviceM.attribute) {
                        if (attributeM.meteIndex.intValue == 1 && self.firstCheckButton.selected) {
                            GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
                            extM.basMeteId = attributeM.basMeteId;
                            extM.conditionOperator = @"==";
                            extM.rightValue = [NSString stringWithFormat:@"%d",self.firstSwitch.on];
                            [exts addObject:extM];
                        } else if (attributeM.meteIndex.intValue == 2 && self.secondCheckButton.selected) {
                            GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
                            extM.basMeteId = attributeM.basMeteId;
                            extM.conditionOperator = @"==";
                            extM.rightValue = [NSString stringWithFormat:@"%d",self.secondSwitch.on];
                            [exts addObject:extM];
                        } else if (attributeM.meteIndex.intValue == 3 && self.thirdCheckButton.selected) {
                            GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
                            extM.basMeteId = attributeM.basMeteId;
                            extM.conditionOperator = @"==";
                            extM.rightValue = [NSString stringWithFormat:@"%d",self.thirdSwitch.on];
                            [exts addObject:extM];
                        }
                    }
                    if (exts.count == 0) {
                        [SVProgressHUD showErrorWithStatus:@"请选中开关按钮"];
                        return;
                    }
                }
            }
        } else if (self.deviceEditType == GSHDeviceVCTypeAutoActionSet) {
            // auto action :  param
            if (self.switchType == SwitchHandleVCTypeOneWay) {
                // 一路智能开关
                if (self.deviceM.attribute.count > 0) {
                    if (self.thirdCheckButton.selected) {
                        GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
                        GSHDeviceAttributeM *attributeM = (GSHDeviceAttributeM *)self.deviceM.attribute[0];
                        extM.basMeteId = attributeM.basMeteId;
                        extM.param = [NSString stringWithFormat:@"%d",self.thirdSwitch.on];
                        [exts addObject:extM];
                    } else {
                        [SVProgressHUD showErrorWithStatus:@"请选中开关按钮"];
                        return;
                    }
                }
            } else if (self.switchType == SwitchHandleVCTypeTwoWay) {
                // 二路开关
                if (self.deviceM.attribute.count > 1) {
                    for (GSHDeviceAttributeM *attributeM in self.deviceM.attribute) {
                        if (attributeM.meteIndex.intValue == 1 && self.secondCheckButton.selected) {
                            GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
                            extM.basMeteId = attributeM.basMeteId;
                            extM.param = [NSString stringWithFormat:@"%d",self.secondSwitch.on];
                            [exts addObject:extM];
                        } else if (attributeM.meteIndex.intValue == 2 && self.thirdCheckButton.selected) {
                            GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
                            extM.basMeteId = attributeM.basMeteId;
                            extM.param = [NSString stringWithFormat:@"%d",self.thirdSwitch.on];
                            [exts addObject:extM];
                        }
                    }
                    if (exts.count == 0) {
                        [SVProgressHUD showErrorWithStatus:@"请选中开关按钮"];
                        return;
                    }
                }
            } else if (self.switchType == SwitchHandleVCTypeThreeWay) {
                // 三路开关
                if (self.deviceM.attribute.count > 2) {
                    for (GSHDeviceAttributeM *attributeM in self.deviceM.attribute) {
                        if (attributeM.meteIndex.intValue == 1 && self.firstCheckButton.selected) {
                            GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
                            extM.basMeteId = attributeM.basMeteId;
                            extM.param = [NSString stringWithFormat:@"%d",self.firstSwitch.on];
                            [exts addObject:extM];
                        } else if (attributeM.meteIndex.intValue == 2 && self.secondCheckButton.selected) {
                            GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
                            extM.basMeteId = attributeM.basMeteId;
                            extM.param = [NSString stringWithFormat:@"%d",self.secondSwitch.on];
                            [exts addObject:extM];
                        } else if (attributeM.meteIndex.intValue == 3 && self.thirdCheckButton.selected) {
                            GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
                            extM.basMeteId = attributeM.basMeteId;
                            extM.param = [NSString stringWithFormat:@"%d",self.thirdSwitch.on];
                            [exts addObject:extM];
                        }
                    }
                    if (exts.count == 0) {
                        [SVProgressHUD showErrorWithStatus:@"请选中开关按钮"];
                        return;
                    }
                }
            }
        }
        if (self.deviceSetCompleteBlock) {
            self.deviceSetCompleteBlock(exts);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

// 接收到实时数据的通知后的处理方法
- (void)notiHandle {
    [self refreshUI];
}

- (IBAction)firstCheckButtonClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.firstSwitch.alpha = sender.selected ? 1 : 0.5;
    self.firstSwitch.enabled = sender.selected ? YES : NO;
}

- (IBAction)secondCheckButtonClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.secondSwitch.alpha = sender.selected ? 1 : 0.5;
    self.secondSwitch.enabled = sender.selected ? YES : NO;
}

- (IBAction)thirdCheckButtonClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.thirdSwitch.alpha = sender.selected ? 1 : 0.5;
    self.thirdSwitch.enabled = sender.selected ? YES : NO;
}

#pragma mark - request
// 获取设备详细信息
- (void)getDeviceDetailInfo {
    @weakify(self)
    [SVProgressHUD showWithStatus:@"请求中"];
    [GSHDeviceManager getDeviceInfoWithFamilyId:[GSHOpenSDK share].currentFamily.familyId deviceId:self.deviceM.deviceId.stringValue block:^(GSHDeviceM *device, NSError *error) {
        @strongify(self)
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [SVProgressHUD dismiss];
            self.deviceM = device;
            [self refreshUI];
            if (self.exts.count > 0) {
                self.deviceM.exts = [self.exts mutableCopy];
                [self refreshSwitchOpenStatus];
            }
        }
    }];
}

// 改变开关状态
- (void)refreshSwitchOpenStatus {
    if (self.switchType == SwitchHandleVCTypeOneWay) {
        // 一路智能开关
        GSHDeviceExtM *extM = self.deviceM.exts[0];
        self.thirdSwitch.on = extM.rightValue?[extM.rightValue intValue]:(extM.param?[extM.param intValue]:0);
        self.thirdCheckButton.selected = YES;
        self.thirdSwitch.alpha = 1;
    } else if (self.switchType == SwitchHandleVCTypeTwoWay) {
        // 二路智能开关
        for (GSHDeviceExtM *extM in self.deviceM.exts) {
            if ([extM.basMeteId isEqualToString:@"04000100060001"]) {
                // 一路
                self.secondSwitch.on = extM.rightValue?[extM.rightValue intValue]:(extM.param?[extM.param intValue]:0);
                self.secondCheckButton.selected = YES;
                self.secondSwitch.alpha = 1;
            } else if ([extM.basMeteId isEqualToString:@"04000100060002"]) {
                // 二路
                self.thirdSwitch.on = extM.rightValue?[extM.rightValue intValue]:(extM.param?[extM.param intValue]:0);
                self.thirdCheckButton.selected = YES;
                self.thirdSwitch.alpha = 1;
            }
        }
    } else if (self.switchType == SwitchHandleVCTypeThreeWay) {
        // 三路智能开关
        for (GSHDeviceExtM *extM in self.deviceM.exts) {
            if ([extM.basMeteId isEqualToString:@"04000200060001"]) {
                // 一路
                self.firstSwitch.on = extM.rightValue?[extM.rightValue intValue]:(extM.param?[extM.param intValue]:0);
                self.firstCheckButton.selected = YES;
                self.firstSwitch.alpha = 1;
            } else if ([extM.basMeteId isEqualToString:@"04000200060002"]) {
                // 二路
                self.secondSwitch.on = extM.rightValue?[extM.rightValue intValue]:(extM.param?[extM.param intValue]:0);
                self.secondCheckButton.selected = YES;
                self.secondSwitch.alpha = 1;
            } else if ([extM.basMeteId isEqualToString:@"04000200060003"]) {
                // 三路
                self.thirdSwitch.on = extM.rightValue?[extM.rightValue intValue]:(extM.param?[extM.param intValue]:0);
                self.thirdCheckButton.selected = YES;
                self.thirdSwitch.alpha = 1;
            }
        }
    }
}

@end
