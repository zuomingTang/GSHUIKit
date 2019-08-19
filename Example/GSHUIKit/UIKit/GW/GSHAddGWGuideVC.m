//
//  GSHAddGWGuideVC.m
//  SmartHome
//
//  Created by gemdale on 2018/6/28.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHAddGWGuideVC.h"
#import "GSHBlueRoundButton.h"
#import "GSHAddGWSearchVC.h"
#import <AFNetworking.h>

@interface GSHAddGWGuideVC ()
@property (weak, nonatomic) IBOutlet UILabel *lblChang;
- (IBAction)touchNext:(GSHBlueRoundButton *)sender;

@property(strong,nonatomic)GSHFamilyM *family;
@end

@implementation GSHAddGWGuideVC
+(instancetype)addGWGuideVCWithFamily:(GSHFamilyM*)family{
    GSHAddGWGuideVC *vc = [TZMPageManager viewControllerWithSB:@"AddGWSB" andID:@"GSHAddGWGuideVC"];
    vc.family = family;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.lblChang.hidden = self.family.gatewayId.length == 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchNext:(GSHBlueRoundButton *)sender {
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi) {
        [self pushSearchVC];
    } else {
        [SVProgressHUD showErrorWithStatus:@"请切换到wifi环境下搜索网关"];
    }
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];

}

- (void)pushSearchVC {
    [self.navigationController pushViewController:[GSHAddGWSearchVC addGWSearchVCWithFamily:self.family] animated:YES];
}


@end
