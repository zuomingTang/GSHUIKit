//
//  GSHConfigWifiInfoVC.m
//  SmartHome
//
//  Created by gemdale on 2018/7/18.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHConfigWifiInfoVC.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "GSHYingShiDeviceWifiLinkVC.h"
#import "GSHWebViewController.h"
#import "GSHAlertManager.h"
#import "NSObject+TZM.h"

NSString *const GSHConfigWifiInfoDic = @"GSHConfigWifiInfoDic";

@interface GSHConfigWifiInfoVC ()
@property (weak, nonatomic) IBOutlet UITextField *tfWifiName;
@property (weak, nonatomic) IBOutlet UITextField *tfWifiPassWord;
- (IBAction)changWifi:(UIButton *)sender;
- (IBAction)showPassword:(UIButton *)sender;
- (IBAction)configWifi:(UIButton *)sender;
- (IBAction)touchWhy:(UIButton *)sender;

@property (strong, nonatomic)GSHDeviceM *device;
@property (copy, nonatomic)NSString *mac;
@end

@implementation GSHConfigWifiInfoVC

+(instancetype)configWifiInfoVCWithDeviceM:(GSHDeviceM*)device{
    GSHConfigWifiInfoVC *vc = [TZMPageManager viewControllerWithSB:@"GSHAddYingShiDeviceSB" andID:@"GSHConfigWifiInfoVC"];
    vc.device = device;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self refreshWiFi];
    [self observerNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [self removeNotifications];
}

-(void)observerNotifications{
    [self observerNotification:UIApplicationDidBecomeActiveNotification];
}

-(void)handleNotifications:(NSNotification *)notification{
    if ([notification.name isEqualToString:UIApplicationDidBecomeActiveNotification]) {
        [self refreshWiFi];
    }
}

- (void)refreshWiFi{
    [SVProgressHUD showWithStatus:@"获取wifi信息中"];
    NSArray *interfaces = CFBridgingRelease(CNCopySupportedInterfaces());
    for (NSString *ifnam in interfaces){
        NSDictionary *info = CFBridgingRelease(CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam));
        self.tfWifiName.text = info[@"SSID"];
        self.mac = info[@"BSSID"];
        if (self.tfWifiName.text.length > 0) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSDictionary *dic = [userDefaults dictionaryForKey:GSHConfigWifiInfoDic];
            NSString *password = [dic stringValueForKey:self.tfWifiName.text default:nil];
            self.tfWifiPassWord.text = password;
            [userDefaults synchronize];
            break;
        }
    }
    [SVProgressHUD dismiss];
}

- (IBAction)changWifi:(UIButton *)sender {
    
    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
        
    } textFieldsSetupHandler:NULL andTitle:nil andMessage:@"请在iphone的“设置”-“WI-Fi”中选择或切换一个可用的Wi-Fi热点接入" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:nil otherButtonTitles:@"好",nil];
    
}

- (IBAction)showPassword:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.tfWifiPassWord.secureTextEntry = !sender.selected;
}

- (IBAction)configWifi:(UIButton *)sender {
    if (self.tfWifiName.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"未选择wifi，请点击切换网络并选择要链接的wifi"];
        return;
    }
    GSHYingShiDeviceWifiLinkVC *vc = [GSHYingShiDeviceWifiLinkVC configWifiLinkVCWithDevice:self.device type:GSHYingShiDeviceWifiLinkVCTypeWIFI wifiName:self.tfWifiName.text wifiPassWord:self.tfWifiPassWord.text];
    [self.navigationController pushViewController:vc animated:YES];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[userDefaults dictionaryForKey:GSHConfigWifiInfoDic]];
    if (!dic) {
        dic = [NSMutableDictionary dictionary];
    }
    [dic setValue:self.tfWifiPassWord.text forKey:self.tfWifiName.text];
    [userDefaults setObject:dic forKey:GSHConfigWifiInfoDic];
    [userDefaults synchronize];
}

- (IBAction)touchWhy:(UIButton *)sender {
    NSURL *url = [GSHWebViewController webUrlWithType:GSHAppConfigH5TypeNorouter parameter:nil];
    [self.navigationController pushViewController:[[GSHWebViewController alloc] initWithURL:url] animated:YES];
}
@end
