//
//  GSHDeviceCategoryGuideVC.m
//  SmartHome
//
//  Created by gemdale on 2018/6/4.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHDeviceCategoryGuideVC.h"
#import "GSHDeviceSearchVC.h"

@interface GSHDeviceCategoryGuideVC ()
@property(nonatomic,strong)GSHDeviceCategoryM *category;
@property (nonatomic,strong) NSString *deviceSn;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewGuide;
- (IBAction)touchNext:(UIButton *)sender;
@end

@implementation GSHDeviceCategoryGuideVC
+(instancetype)deviceCategoryGuideVCWithGategory:(GSHDeviceCategoryM*)model deviceSn:(NSString *)deviceSn {
    GSHDeviceCategoryGuideVC *vc = [TZMPageManager viewControllerWithSB:@"GSHAddDeviceSB" andID:@"GSHDeviceCategoryGuideVC"];
    vc.category = model;
    vc.deviceSn = deviceSn;
//    [vc postDeviceSnToServerWithDeviceSn:vc.deviceSn];
    return vc;
}

-(void)setCategory:(GSHDeviceCategoryM *)category{
    _category = category;
    self.title = category.deviceTypeStr;
    self.imageViewGuide.image = [UIImage imageNamed:[NSString stringWithFormat:@"deviceCategroy_guide_icon-%d",[category.deviceType intValue]]];;
    self.deviceSnLabel.text = self.deviceSn.length > 0 ? [NSString stringWithFormat:@"SN:%@",self.deviceSn] : @"";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.category = self.category;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchNext:(UIButton *)sender {
    GSHDeviceSearchVC *deviceSearchVC = [GSHDeviceSearchVC deviceSearchVCWithDeviceCategory:self.category deviceSn:self.deviceSn.length>0?self.deviceSn:@""];
    NSMutableArray *vcs = [NSMutableArray array];
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:GSHDeviceCategoryGuideVC.class]) {
            break;
        }
        [vcs addObject:vc];
    }
    [vcs addObject:deviceSearchVC];
    [self.navigationController setViewControllers:vcs animated:YES];
}

@end
