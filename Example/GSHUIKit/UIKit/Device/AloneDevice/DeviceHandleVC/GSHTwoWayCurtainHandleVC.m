//
//  GSHTwoWayCurtainHandleVC.m
//  SmartHome
//
//  Created by zhanghong on 2019/4/9.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHTwoWayCurtainHandleVC.h"
#import "UINavigationController+TZM.h"
#import "GSHDeviceEditVC.h"
#import "GSHDeviceInfoDefines.h"


@interface GSHTwoWayCurtainHandleVC ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UILabel *curtainNameLabel;

@property (strong, nonatomic) GSHDeviceM *deviceM;
@property (assign, nonatomic) GSHDeviceVCType deviceEditType;
@property (assign, nonatomic) GSHTwoWayCurtainHandleVCType type;
@property (assign, nonatomic) int segmentIndex; // 标识二路窗帘开关 0：一路 ，1：二路
@property (strong, nonatomic) NSMutableDictionary *btnSetDic;
@property (copy, nonatomic) NSString *currentBaseMeteId;
@property (nonatomic,strong) NSArray *exts;

@end

@implementation GSHTwoWayCurtainHandleVC

+ (instancetype)twoWayCurtainHandleVCWithDeviceM:(GSHDeviceM *)deviceM deviceEditType:(GSHDeviceVCType)deviceEditType type:(GSHTwoWayCurtainHandleVCType)type {
    GSHTwoWayCurtainHandleVC *vc = [TZMPageManager viewControllerWithSB:@"GSHTwoWayCurtainHandleSB" andID:@"GSHTwoWayCurtainHandleVC"];
    vc.deviceM = deviceM;
    vc.type = type;
    vc.deviceEditType = deviceEditType;
    vc.exts = deviceM.exts;
    return vc;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tzm_prefersNavigationBarHidden = YES;
    
    self.segmentedControl.selectedSegmentIndex = 0;
    [self.segmentedControl setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRGB:0xffffff alpha:0.1]] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [self.segmentedControl setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil];
    [self.segmentedControl setTitleTextAttributes:dic forState:UIControlStateSelected];
    NSDictionary *dics = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRGB:0xffffff alpha:0.5],NSForegroundColorAttributeName,nil];
    [self.segmentedControl setTitleTextAttributes:dics forState:UIControlStateNormal];
    self.segmentedControl.layer.borderColor = [UIColor colorWithRGB:0xffffff alpha:0.1].CGColor;
    self.segmentedControl.tintColor = [UIColor colorWithRGB:0xffffff alpha:0.1];
    
    NSString *rightNaviButtonTitle = self.deviceEditType == GSHDeviceVCTypeControl ? @"进入设备" : @"确定";
    [self.rightButton setTitle:rightNaviButtonTitle forState:UIControlStateNormal];
    self.rightButton.hidden = ([GSHOpenSDK share].currentFamily.permissions == GSHFamilyMPermissionsMember && self.deviceEditType == GSHDeviceVCTypeControl);
    
    if (self.type == GSHTwoWayCurtainMotorHandleVC) {
        // 窗帘电机
        self.currentBaseMeteId = GSHCurtain_SwitchMeteId;
        self.segmentedControl.hidden = YES;
    } else if (self.type == GSHTwoWayCurtainHandleVCOneWay) {
        // 一路窗帘开关
        self.currentBaseMeteId = GSHOneWayCurtain_SwitchMeteId;
        self.segmentedControl.hidden = YES;
    } else {
        // 二路窗帘开关 -- 进入页面默认是选中一路
        self.currentBaseMeteId = GSHTwoWayCurtain_OneSwitchMeteId;
        self.segmentedControl.hidden = NO;
    }
    
    [self getDeviceDetailInfo];
    
}

- (void)refreshUI {
    
    self.curtainNameLabel.text = self.deviceM.deviceName;
    
    NSString *imageName = nil;
    if (self.type == GSHTwoWayCurtainMotorHandleVC) {
        // 窗帘电机
        imageName = @"equipment_icon_curtain_big";
    } else if (self.type == GSHTwoWayCurtainHandleVCOneWay) {
        // 一路窗帘开关
        imageName = @"equipment_icon_curtain_oneway_big";
    } else {
        // 二路窗帘开关
        imageName = @"equipment_icon_curtain_twoway_big";
        for (GSHDeviceAttributeM *attributeM in self.deviceM.attribute) {
            if ([attributeM.basMeteId isEqualToString:GSHTwoWayCurtain_OneSwitchMeteId]) {
                [self.segmentedControl setTitle:attributeM.meteName forSegmentAtIndex:0];
            } else if ([attributeM.basMeteId isEqualToString:GSHTwoWayCurtain_TwoSwitchMeteId]) {
                [self.segmentedControl setTitle:attributeM.meteName forSegmentAtIndex:1];
            }
        }
    }
    self.mainImageView.image = [UIImage imageNamed:imageName];
    
    if (self.deviceEditType != GSHDeviceVCTypeControl) {
        
        if (self.type == GSHTwoWayCurtainHandleVCTwoWay) {
            // 二路窗帘
            for (GSHDeviceExtM *extM in self.deviceM.exts) {
                NSString *value = extM.rightValue?extM.rightValue:(extM.param?extM.param:@"");
                int index ;
                if (value.integerValue == 0) {
                    index = 1;
                } else if (value.integerValue == 1) {
                    index = 3;
                } else {
                    index = 2;
                }
                if ([extM.basMeteId isEqualToString:GSHTwoWayCurtain_OneSwitchMeteId]) {
                    [self.btnSetDic setObject:@(index) forKey:@(0)];
                }
                if ([extM.basMeteId isEqualToString:GSHTwoWayCurtain_TwoSwitchMeteId]) {
                    [self.btnSetDic setObject:@(index) forKey:@(1)];
                }
            }
        }
        if (self.deviceM.exts.count > 0) {
            for (GSHDeviceExtM *extM in self.deviceM.exts) {
                if ([extM.basMeteId isEqualToString:self.currentBaseMeteId]) {
                    NSString *value = extM.rightValue?extM.rightValue:(extM.param?extM.param:@"");
                    int tag = 1;
                    if (value.intValue == 0) {
                        // 开
                        tag = 1;
                    } else if (value.intValue == 1) {
                        // 关
                        tag = 3;
                    } else {
                        tag = 2;
                    }
                    UIButton *button = [self.view viewWithTag:tag];
                    button.selected = YES;
                }
            }
        }
    }
}

#pragma mark - Lazy
- (NSMutableDictionary *)btnSetDic {
    if (!_btnSetDic) {
        _btnSetDic = [NSMutableDictionary dictionary];
    }
    return _btnSetDic;
}

#pragma mark - method

- (IBAction)backButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)rightButtonClick:(id)sender {
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
        if (self.type == GSHTwoWayCurtainHandleVCTwoWay) {
            if ([self.btnSetDic objectForKey:@(0)]) {
                NSNumber *index = [self.btnSetDic objectForKey:@(0)];
                [exts addObject:[self extMWithButtonTag:index.intValue basMeteId:GSHTwoWayCurtain_OneSwitchMeteId]];
            }
            if ([self.btnSetDic objectForKey:@(1)]) {
                NSNumber *index = [self.btnSetDic objectForKey:@(1)];
                [exts addObject:[self extMWithButtonTag:index.intValue basMeteId:GSHTwoWayCurtain_TwoSwitchMeteId]];
            }
        } else {
            for (NSInteger i = 1; i < 4; i ++) {
                UIButton *button = [self.view viewWithTag:i];
                if (button.selected) {
                    [exts addObject:[self extMWithButtonTag:(int)i basMeteId:self.currentBaseMeteId]];
                    break;
                }
            }
        }
        if (exts.count == 0) {
            [SVProgressHUD showErrorWithStatus:@"请选择一个操作"];
            return;
        }
        
        if (self.deviceSetCompleteBlock) {
            self.deviceSetCompleteBlock(exts);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (GSHDeviceExtM *)extMWithButtonTag:(int)buttonTag basMeteId:(NSString *)basMeteId {
    GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
    extM.basMeteId = basMeteId;
    extM.conditionOperator = @"=";
    NSString *str = @"";
    NSString *value = @"";
    if (buttonTag == 1) {
        // 开
        value = @"0";
        str = @"开";
    } else if (buttonTag == 3) {
        // 关
        value = @"1";
        str = @"关";
    } else if (buttonTag == 2) {
        // 暂停
        value = @"2";
        str = @"暂停";
    }
    if (self.deviceEditType == GSHDeviceVCTypeSceneSet) {
        extM.rightValue = value;
        extM.param = str;
    } else if (self.deviceEditType == GSHDeviceVCTypeAutoTriggerSet) {
        extM.conditionOperator = @"==";
        extM.rightValue = value;
    } else if (self.deviceEditType == GSHDeviceVCTypeAutoActionSet) {
        extM.param = value;
    }
    return extM;
}

- (IBAction)segmentedControlClick:(UISegmentedControl *)segmentedControl {
    self.segmentIndex = (int)segmentedControl.selectedSegmentIndex;
    self.currentBaseMeteId = segmentedControl.selectedSegmentIndex == 0 ? GSHTwoWayCurtain_OneSwitchMeteId : GSHTwoWayCurtain_TwoSwitchMeteId;
    if (self.deviceEditType != GSHDeviceVCTypeControl) {
        for (int i = 1; i < 4; i ++) {
            UIButton *tmpButton = [self.view viewWithTag:i];
            tmpButton.selected = NO;
        }
        if (segmentedControl.selectedSegmentIndex == 0) {
            // 一路
            if ([self.btnSetDic objectForKey:@(0)]) {
                NSNumber *index = [self.btnSetDic objectForKey:@(0)];
                UIButton *btn = [self.view viewWithTag:index.intValue];
                btn.selected = YES;
            }
        } else {
            // 二路
            if ([self.btnSetDic objectForKey:@(1)]) {
                NSNumber *index = [self.btnSetDic objectForKey:@(1)];
                UIButton *btn = [self.view viewWithTag:index.intValue];
                btn.selected = YES;
            }
        }
    }
}

- (IBAction)handleButtonClick:(UIButton *)button {
    // 设备控制
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        NSString *basMeteId = self.currentBaseMeteId;
        NSString *value;
        if (button.tag == 1) {
            // 开
            value = @"0";
        } else if (button.tag == 2) {
            // 停
            value = @"2";
        } else {
            // 关
            value = @"1";
        }
        [self controlCurtainWithBasMeteId:basMeteId value:value failBlock:^(NSError *error) {
            
        } successBlock:^{
            
        }];
    } else {
        for (int i = 1; i < 4; i ++) {
            UIButton *tmpButton = [self.view viewWithTag:i];
            tmpButton.selected = NO;
        }
        button.selected = !button.selected;
        if (self.type == GSHTwoWayCurtainHandleVCTwoWay) {
            // 二路窗帘开关
            int tag = (int)button.tag;
            [self.btnSetDic setObject:@(tag) forKey:@(self.segmentIndex)];
        }
    }
}

#pragma mark - request
// 设备控制
- (void)controlCurtainWithBasMeteId:(NSString *)basMeteId
                              value:(NSString *)value
                          failBlock:(void(^)(NSError *error))failBlock
                       successBlock:(void(^)(void))successBlock {
    
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeWAN) {
        [SVProgressHUD showWithStatus:@"操作中"];
    }
    [GSHDeviceManager deviceControlWithDeviceId:self.deviceM.deviceId.stringValue deviceSN:self.deviceM.deviceSn familyId:[GSHOpenSDK share].currentFamily.familyId basMeteId:basMeteId value:value block:^(NSError *error) {
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
            if (self.exts.count > 0) {
                self.deviceM.exts = [self.exts mutableCopy];
            }
            [self refreshUI];
        }
    }];
}


@end
