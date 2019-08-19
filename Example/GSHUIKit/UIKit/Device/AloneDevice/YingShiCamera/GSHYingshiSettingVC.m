//
//  GSHYingshiSettingVC.m
//  SmartHome
//
//  Created by gemdale on 2019/5/17.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHYingshiSettingVC.h"
#import "GSHHuoDongJianCeSettingVC.h"
#import "GSHYingShiAlarmSoundModeVC.h"

@interface GSHYingshiSettingVC ()
@property (weak, nonatomic) IBOutlet UILabel *lblActivity;
- (IBAction)touchActivity:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIView *viewActivity;
@property (weak, nonatomic) IBOutlet UIView *viewActivityHelp;

@property (weak, nonatomic) IBOutlet UILabel *lblPrompt;
- (IBAction)touchPrompt:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIView *viewPrompt;
@property (weak, nonatomic) IBOutlet UIView *viewPromptHelp;

- (IBAction)touchFollow:(UISwitch *)sender;
@property (weak, nonatomic) IBOutlet UIView *viewFollow;
@property (weak, nonatomic) IBOutlet UIView *viewFollowHelp;
@property (weak, nonatomic) IBOutlet UISwitch *switchFollow;

- (IBAction)touchDisturbing:(UISwitch *)sender;
@property (weak, nonatomic) IBOutlet UISwitch *switchDisturbing;

@property(nonatomic,strong)NSMutableDictionary *ipc;
@property(nonatomic,strong)GSHDeviceM *device;
@end

@implementation GSHYingshiSettingVC

+(instancetype)yingshiSettingVCWithIPC:(NSMutableDictionary*)ipc device:(GSHDeviceM*)device{
    GSHYingshiSettingVC *vc =  [TZMPageManager viewControllerWithSB:@"GSHYingshiCameraToolSB" andID:@"GSHYingshiSettingVC"];
    vc.ipc = ipc;
    vc.device = device;
    return vc;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refrshUI];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)refrshUI{
    NSNumber *isDefence = [self.ipc numverValueForKey:@"isDefence" default:nil];
    if (isDefence) {
        self.viewActivity.hidden = NO;
        self.viewActivityHelp.hidden = NO;
        self.lblActivity.text = isDefence.intValue == 0 ? @"关闭" : @"开启";
    }else{
        self.viewActivity.hidden = YES;
        self.viewActivityHelp.hidden = YES;
    }
    
    NSNumber *alarmSoundMode = [self.ipc numverValueForKey:@"alarmSoundMode" default:nil];
    if (alarmSoundMode && alarmSoundMode.intValue >= 0) {
        self.viewPrompt.hidden = NO;
        self.viewPromptHelp.hidden = NO;
        switch (alarmSoundMode.intValue) {
            case GSHYingShiCameraMAlarmSoundModeTiShi:
                self.lblPrompt.text = @"提示音";
                break;
            case GSHYingShiCameraMAlarmSoundModeGaoJing:
                self.lblPrompt.text = @"告警音";
                break;
            case GSHYingShiCameraMAlarmSoundModeJingYin:
                self.lblPrompt.text = @"静音";
                break;
            default:
                self.lblPrompt.text = @"";
                break;
        }
    }else{
        self.viewPrompt.hidden = YES;
        self.viewPromptHelp.hidden = YES;
    }
    
    NSNumber *mobileStatus = [self.ipc numverValueForKey:@"mobileStatus" default:nil];
    if (mobileStatus) {
        self.viewFollow.hidden = NO;
        self.viewFollowHelp.hidden = NO;
        self.switchFollow.on = mobileStatus.intValue == 1;
    }else{
        self.viewFollow.hidden = YES;
        self.viewFollowHelp.hidden = YES;
    }
    
    NSNumber *disturbState = [self.ipc numverValueForKey:@"disturbState" default:nil];
    self.switchDisturbing.on = disturbState.intValue == 1;
}

- (IBAction)touchActivity:(UIButton *)sender {
    GSHHuoDongJianCeSettingVC *vc = [GSHHuoDongJianCeSettingVC huoDongJianCeSettingVCWithDevice:self.device ipc:self.ipc];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)touchPrompt:(UIButton *)sender{
    GSHYingShiAlarmSoundModeVC *vc = [GSHYingShiAlarmSoundModeVC yingShiAlarmSoundModeVCWithIPC:self.ipc device:self.device];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)touchFollow:(UISwitch *)sender {
    __weak typeof(self)weakSelf = self;
    [SVProgressHUD showWithStatus:@"设置中"];
    BOOL on = sender.on;
    [GSHYingShiManager postDeviceMobileStatusWithDeviceSerial:weakSelf.device.deviceSn on:on block:^(NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            sender.on = !on;
        }else{
            [SVProgressHUD dismiss];
            [weakSelf.ipc setValue:on ? @(1) : @(0) forKey:@"mobileStatus"];
        }
    }];
}
- (IBAction)touchDisturbing:(UISwitch *)sender{
    __weak typeof(self)weakSelf = self;
    [SVProgressHUD showWithStatus:@"设置中"];
    BOOL on = sender.on;
    [GSHYingShiManager postDisturbStateWithDeviceSerial:weakSelf.device.deviceSn on:on block:^(NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            sender.on = !on;
        }else{
            [SVProgressHUD dismiss];
            [weakSelf.ipc setValue:on ? @(1) : @(0) forKey:@"disturbState"];
        }
    }];
}
@end
