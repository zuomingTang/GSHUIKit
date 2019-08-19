//
//  GSHAirConditionerHandleVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/6/6.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHAirConditionerHandleVC.h"
#import "UIView+TZM.h"
#import "UINavigationController+TZM.h"
#import "TZMButton.h"
#import "GSHDeviceEditVC.h"
#import "JKCircleView.h"
#import "NSObject+TZM.h"


#define AirConditionerModelKey @"51"    // 模式
#define AirConditionerWindSpeedKey @"91"    // 风速
#define AirConditionerSwitchKey @"52"   // 开关状态
#define AirConditionerTemperatureKey @"71"  // 温度

@interface GSHAirConditionerHandleVC ()

@property (weak, nonatomic) IBOutlet UIButton *rightNaviButton;
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet TZMButton *switchButton;   // 开关按钮
@property (weak, nonatomic) IBOutlet UIView *temperatureView;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UIButton *subButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UILabel *airConditionerNameLabel;

@property (nonatomic,strong) GSHDeviceM *deviceM;
//@property (nonatomic,strong) GSHDeviceM *editDeviceM;
@property (nonatomic,strong) NSArray *modelValueArray;
@property (nonatomic,strong) NSMutableDictionary *meteIdDic;
@property (nonatomic,strong) JKCircleView *circleView;
@property (nonatomic,assign) CGFloat currentTemperatureValue;

@property (assign, nonatomic) GSHDeviceVCType deviceEditType;
@property (nonatomic,strong) NSArray *exts;

@end

@implementation GSHAirConditionerHandleVC

+ (instancetype)airConditionerHandleVCWithDeviceM:(GSHDeviceM *)deviceM deviceEditType:(GSHDeviceVCType)deviceEditType {
    GSHAirConditionerHandleVC *vc = [TZMPageManager viewControllerWithSB:@"GSHAirConditionerHandleSB" andID:@"GSHAirConditionerHandleVC"];
    vc.deviceM = deviceM;
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

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tzm_prefersNavigationBarHidden = YES;
    
    NSString *rightNaviButtonTitle = self.deviceEditType == GSHDeviceVCTypeControl ? @"进入设备" : @"确定";
    [self.rightNaviButton setTitle:rightNaviButtonTitle forState:UIControlStateNormal];
    self.rightNaviButton.hidden = ([GSHOpenSDK share].currentFamily.permissions == GSHFamilyMPermissionsMember && self.deviceEditType == GSHDeviceVCTypeControl);
    
    self.modelValueArray = @[@"1",@"2",@"3",@"3",@"4",@"8",@"7"];
    
    [self initUI];
    
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
- (void)initUI {
    self.currentTemperatureValue = 26;
    self.temperatureLabel.text = @"26";
    
    self.circleView = [[JKCircleView alloc] initWithFrame:CGRectMake(0, 0, self.temperatureView.frame.size.width, self.temperatureView.frame.size.height) startAngle:-225 endAngle:45];
    self.circleView.minNum = 16;
    self.circleView.maxNum = 32;
    self.circleView.circleRadian = 270;
    self.circleView.enableCustom = YES;

    [self.circleView setProgressWithProgress:(26 - 16) / 16.0 isSendRequest:NO];
    [self.circleView setIsCanSlideTemperature:YES];
    @weakify(self);
    [self.circleView setProgressChange:^(NSString *result, BOOL isSendRequest) {
        @strongify(self)
        self.temperatureLabel.text = result;
        self.currentTemperatureValue = result.floatValue;
        if (self.deviceEditType == GSHDeviceVCTypeControl) {
            if (isSendRequest) {
                // 控制空调温度
                if ([self.meteIdDic containsObjectForKey:AirConditionerTemperatureKey]) {
//                    [SVProgressHUD showWithStatus:@"操作中"];
                    NSString *meteId = [self.meteIdDic objectForKey:AirConditionerTemperatureKey];
//                    @weakify(self)
                    [self controlAirConditionerWithBasMeteId:meteId value:result failBlock:^(NSError *error) {
//                        @strongify(self)
//                        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
//                        self.currentTemperatureValue = [result floatValue];
                    } successBlock:^() {
//                        [SVProgressHUD dismiss];
                    }];
                }
            }
        } else {
//            self.currentTemperatureValue = result.floatValue;
        }
    }];
    [self.temperatureView addSubview:self.circleView];
    
}

#pragma mark - Lazy
- (NSMutableDictionary *)meteIdDic {
    if (!_meteIdDic) {
        _meteIdDic = [NSMutableDictionary dictionary];
    }
    return _meteIdDic;
}

#pragma mark - method
// 返回按钮点击
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
        NSString *meteId = [self.meteIdDic objectForKey:AirConditionerSwitchKey];
        GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
        extM.basMeteId = meteId;
        if (self.switchButton.selected) {
            // 关
            if (self.deviceEditType == GSHDeviceVCTypeSceneSet) {
                extM.rightValue = @"0";
                extM.param = @"关";
            } else {
                extM.param = @"0";
            }
        } else {
            // 开
            if (self.deviceEditType == GSHDeviceVCTypeSceneSet) {
                extM.rightValue = @"10";
                extM.param = @"开";
            } else {
                extM.param = @"10";
            }
            
            for (int i = 4; i < 8; i ++) {
                UIButton *tmpButton = [self.view viewWithTag:i];
                if (tmpButton.selected) {
                    // 有模式按钮选中
                    NSString *modelMeteId = [self.meteIdDic objectForKey:AirConditionerModelKey];
                    GSHDeviceExtM *modelExtM = [[GSHDeviceExtM alloc] init];
                    modelExtM.basMeteId = modelMeteId;
                    if (self.deviceEditType == GSHDeviceVCTypeSceneSet) {
                        modelExtM.rightValue = self.modelValueArray[i-1];
                        NSString *modelStr = @"";
                        if (i == 4) {
                            modelStr = @"制冷模式";
                        } else if (i == 5) {
                            modelStr = @"制热模式";
                        } else if (i == 6) {
                            modelStr = @"除湿模式";
                        } else {
                            modelStr = @"送风模式";
                        }
                        modelExtM.param = modelStr;
                    } else {
                        modelExtM.param = self.modelValueArray[i-1];
                    }
                    [exts addObject:modelExtM];
                    break;
                }
            }
            
            for (int i = 1; i < 4; i ++) {
                UIButton *tmpButton = [self.view viewWithTag:i];
                if (tmpButton.selected) {
                    // 有风量按钮选中
                    NSString *speedMeteId = [self.meteIdDic objectForKey:AirConditionerWindSpeedKey];
                    GSHDeviceExtM *speedExtM = [[GSHDeviceExtM alloc] init];
                    speedExtM.basMeteId = speedMeteId;
                    if (self.deviceEditType == GSHDeviceVCTypeSceneSet) {
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
                    } else {
                        speedExtM.param = [NSString stringWithFormat:@"%d",i];
                    }
                    [exts addObject:speedExtM];
                    break;
                }
            }
            
            GSHDeviceExtM *temperatureExtM = [[GSHDeviceExtM alloc] init];
            NSString *temperatureMeteId = [self.meteIdDic objectForKey:AirConditionerTemperatureKey];
            temperatureExtM.basMeteId = temperatureMeteId;
            if (self.deviceEditType == GSHDeviceVCTypeSceneSet) {
                temperatureExtM.rightValue = [NSString stringWithFormat:@"%d",(int)self.currentTemperatureValue];
                temperatureExtM.param = [NSString stringWithFormat:@"%d˚C",(int)self.currentTemperatureValue];
            } else {
                temperatureExtM.param = [NSString stringWithFormat:@"%d",(int)self.currentTemperatureValue];
            }
            [exts addObject:temperatureExtM];
        }
        [exts addObject:extM];
        if (self.deviceSetCompleteBlock) {
            self.deviceSetCompleteBlock(exts);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

// 减温度按钮点击
- (IBAction)subButtonClick:(id)sender {
    if (self.switchButton.selected) {
        return;
    }
    if (self.currentTemperatureValue > 16) {
        self.currentTemperatureValue --;
        [self.circleView setProgressWithProgress:(self.currentTemperatureValue - 16) / 16.0 isSendRequest:YES];
    }
}

// 加温度按钮点击
- (IBAction)addButtonClick:(id)sender {
    if (self.switchButton.selected) {
        return;
    }
    if (self.currentTemperatureValue < 32) {
        self.currentTemperatureValue ++;
        [self.circleView setProgressWithProgress:(self.currentTemperatureValue - 16) / 16.0 isSendRequest:YES];
    }
}

// 开关按钮点击
- (IBAction)switchButtonClick:(UIButton *)button {
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        // 设备控制
        
        if ([self.meteIdDic containsObjectForKey:AirConditionerSwitchKey]) {
            NSString *meteId = [self.meteIdDic objectForKey:AirConditionerSwitchKey];
            NSString *value;
            if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
                // 离线控制模式 -- 开关按钮点击首先修改UI
                [self switchButtonClickToRefreshUIWithButton:button];
                value = button.selected ? @"0" : @"10";
            } else {
                value = button.selected ? @"10" : @"0";
            }
            __weak typeof(button) weakButton = button;
            @weakify(self)
            [self controlAirConditionerWithBasMeteId:meteId value:value failBlock:^(NSError *error) {

            } successBlock:^() {
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
    if (button.selected) {
        for (int i = 1; i < 8; i ++) {
            UIButton *tmpButton = [self.view viewWithTag:i];
            tmpButton.selected = NO;
        }
    }
    self.backImageView.image = button.selected ? [UIImage imageNamed:@"conditioner_bg_close"] : [UIImage imageNamed:@"conditioner_bg"];
    self.subButton.enabled = button.selected ? NO : YES;
    self.addButton.enabled = button.selected ? NO : YES;
    [self.circleView setIsCanSlideTemperature:!button.selected];
}

// 操作按钮点击
- (IBAction)handleButtonClick:(UIButton *)button {
    
    if (button.selected) {
        return;
    }
    if (self.switchButton.selected) {
        return;
    }
    NSInteger tag = button.tag;
    NSString *value = self.modelValueArray[tag - 1];
    
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        // 设备控制、场景设置
        @weakify(self)
        __weak typeof(button) weakButton = button;
        if (tag <= 7 && tag >= 4) {
            // 空调模式按钮点击
            if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
                // 离线控制模式 -- 开关按钮点击首先修改UI
                for (int i = 4; i < 8; i ++) {
                    UIButton *tmpButton = [self.view viewWithTag:i];
                    tmpButton.selected = NO;
                }
                button.selected = YES;
            }
            if ([self.meteIdDic containsObjectForKey:AirConditionerModelKey]) {
                NSString *meteId = [self.meteIdDic objectForKey:AirConditionerModelKey];
                [self controlAirConditionerWithBasMeteId:meteId value:value failBlock:^(NSError *error) {

                } successBlock:^() {
                    @strongify(self)
                    __strong typeof(weakButton) strongButton = weakButton;
                    for (int i = 4; i < 8; i ++) {
                        UIButton *tmpButton = [self.view viewWithTag:i];
                        tmpButton.selected = NO;
                    }
                    strongButton.selected = YES;
                }];
            }
        } else {
            // 空调风速按钮点击
            if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
                // 离线控制模式 -- 开关按钮点击首先修改UI
                for (int i = 1; i < 4; i ++) {
                    UIButton *tmpButton = [self.view viewWithTag:i];
                    tmpButton.selected = NO;
                }
                button.selected = YES;
            }
            if ([self.meteIdDic containsObjectForKey:AirConditionerWindSpeedKey]) {
                NSString *meteId = [self.meteIdDic objectForKey:AirConditionerWindSpeedKey];
                [self controlAirConditionerWithBasMeteId:meteId value:value failBlock:^(NSError *error) {

                } successBlock:^() {
                    @strongify(self)
                    __strong typeof(weakButton) strongButton = weakButton;
                    for (int i = 1; i < 4; i ++) {
                        UIButton *tmpButton = [self.view viewWithTag:i];
                        tmpButton.selected = NO;
                    }
                    strongButton.selected = YES;
                }];
            }
        }
    } else {
        // 联动 -- 执行动作 -- 设备设置
        if (tag <= 7 && tag >= 4) {
            for (int i = 4; i < 8; i ++) {
                UIButton *tmpButton = [self.view viewWithTag:i];
                tmpButton.selected = NO;
            }
        } else {
            for (int i = 1; i < 4; i ++) {
                UIButton *tmpButton = [self.view viewWithTag:i];
                tmpButton.selected = NO;
            }
        }
        button.selected = YES;
    }
}

// 接收到实时数据的通知后的处理方法
- (void)notiHandle {
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
            if (self.exts.count > 0) {
                self.deviceM.exts = [self.exts mutableCopy];
            }
            [self refreshUI];
        }
    }];
}

// 设备控制
- (void)controlAirConditionerWithBasMeteId:(NSString *)basMeteId
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

- (void)refreshUI {
    
    self.airConditionerNameLabel.text = self.deviceM.deviceName;
    NSString *meteId = [self.meteIdDic objectForKey:AirConditionerSwitchKey];
    NSString *temperatureMeteId = [self.meteIdDic objectForKey:AirConditionerTemperatureKey];
    NSString *windSpeedMeteId = [self.meteIdDic objectForKey:AirConditionerWindSpeedKey];
    NSString *modelMeteId = [self.meteIdDic objectForKey:AirConditionerModelKey];
    
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        // 设备控制
        NSDictionary *dic = [self.deviceM realTimeDic];
        id value = [dic objectForKey:meteId];
        if (value) {
            // 开关状态有值
            [self.circleView setIsCanSlideTemperature:[value intValue] == 0 ? NO : YES];
            if ([value intValue] == 0) {
                // 空调 关
                self.switchButton.selected = YES;
                for (int i = 1; i < 8; i ++) {
                    UIButton *tmpButton = [self.view viewWithTag:i];
                    tmpButton.selected = NO;
                }
                self.backImageView.image = [UIImage imageNamed:@"conditioner_bg_close"];
            } else if ([value intValue] == 10) {
                // 空调 开
                self.switchButton.selected = NO;
                self.backImageView.image = [UIImage imageNamed:@"conditioner_bg"];
                // 温度
                id temperatureValue = [dic objectForKey:temperatureMeteId];
                if (temperatureValue) {
                    [self.circleView setProgressWithProgress:([temperatureValue intValue] - 16) / 16.0 isSendRequest:NO];
                    self.currentTemperatureValue = [temperatureValue floatValue];
                }
                // 风速
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
                // 模式
                id modelValue = [dic objectForKey:modelMeteId];
                if (modelValue) {
                    for (int i = 4; i < 8; i ++) {
                        UIButton *tmpButton = [self.view viewWithTag:i];
                        tmpButton.selected = NO;
                    }
                    if ([modelValue intValue] == 3 || [modelValue intValue] == 4 || [modelValue intValue] == 8 || [modelValue intValue] == 7) {
                        int tag = 4;
                        if ([modelValue intValue] == 4) {
                            tag = 5;
                        } else if ([modelValue intValue] == 8) {
                            tag = 6;
                        } else if ([modelValue intValue] == 7) {
                            tag = 7;
                        } else {
                            tag = 4;
                        }
                        UIButton *openButton = [self.view viewWithTag:tag];
                        openButton.selected = YES;
                    }
                }
            }
        } else {
            [SVProgressHUD showErrorWithStatus:@"websocket 数据出错"];
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
                // 空调开
                self.backImageView.image = [UIImage imageNamed:@"conditioner_bg"];
                [self.circleView setIsCanSlideTemperature:YES];
                for (GSHDeviceExtM *extM in self.deviceM.exts) {
                    if ([extM.basMeteId isEqualToString:modelMeteId]) {
                        // 模式
                        for (int i = 4; i < 8; i ++) {
                            UIButton *tmpButton = [self.view viewWithTag:i];
                            tmpButton.selected = NO;
                        }
                        NSString *modelValue = extM.rightValue?extM.rightValue:(extM.param?extM.param:@"");
                        if (modelValue.length > 0) {
                            if ([modelValue intValue] == 3 ||
                                [modelValue intValue] == 4 ||
                                [modelValue intValue] == 8 ||
                                [modelValue intValue] == 7) {
                                int tag = 4;
                                if ([modelValue intValue] == 4) {
                                    tag = 5;
                                } else if ([modelValue intValue] == 8) {
                                    tag = 6;
                                } else if ([modelValue intValue] == 7) {
                                    tag = 7;
                                } else {
                                    tag = 4;
                                }
                                UIButton *selectModelButton = [self.view viewWithTag:tag];
                                selectModelButton.selected = YES;
                            }
                        }
                    } else if ([extM.basMeteId isEqualToString:windSpeedMeteId]) {
                        // 风速
                        for (int i = 1; i < 4; i ++) {
                            UIButton *tmpButton = [self.view viewWithTag:i];
                            tmpButton.selected = NO;
                        }
                        NSString *windSpeedValue = extM.rightValue?extM.rightValue:(extM.param?extM.param:@"");
                        if (windSpeedValue.length > 0) {
                            UIButton *selectWindSpeedButton = [self.view viewWithTag:windSpeedValue.integerValue];
                            selectWindSpeedButton.selected = YES;
                        }
                    } else if ([extM.basMeteId isEqualToString:temperatureMeteId]) {
                        // 温度
                        NSString *temValue = extM.rightValue?extM.rightValue:(extM.param?extM.param:@"");
                        if (temValue.length > 0) {
                            self.currentTemperatureValue = temValue.floatValue;
                            [self.circleView setProgressWithProgress:(temValue.floatValue-16)/16.0 isSendRequest:NO];
                        }
                    }
                }
            } else {
                // 关
                for (int i = 1; i < 8; i ++) {
                    UIButton *tmpButton = [self.view viewWithTag:i];
                    tmpButton.selected = NO;
                }
                self.backImageView.image = [UIImage imageNamed:@"conditioner_bg_close"];
                self.subButton.enabled = NO;
                self.addButton.enabled = NO;
                [self.circleView setIsCanSlideTemperature:NO];
            }
        }
    }
}


@end
