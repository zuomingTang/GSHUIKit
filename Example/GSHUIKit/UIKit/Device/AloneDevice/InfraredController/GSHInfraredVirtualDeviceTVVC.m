//
//  GSHInfraredVirtualDeviceTVVC.m
//  SmartHome
//
//  Created by gemdale on 2019/4/8.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHInfraredVirtualDeviceTVVC.h"
#import "GSHAlertManager.h"
#import <TZMOpenLib/UINavigationController+TZM.h>
#import "LGAlertView.h"
#import "GSHTVSeleAlertVC.h"
#import "GSHInfraredControllerEditVC.h"
#import "GSHInfraredControllerTypeVC.h"
#import "GSHInfraredControllerBrandVC.h"

@interface GSHInfraredVirtualDeviceTVVC ()
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnRightNavBtn;
@property (weak, nonatomic) IBOutlet UIButton *btnTVOff;
@property (weak, nonatomic) IBOutlet UIButton *btnHomePage;
- (IBAction)touchBut:(UIButton *)sender;
- (IBAction)touchRigthNavBut:(id)sender;
- (IBAction)touchBack:(id)sender;

@property(nonatomic,strong) GSHKuKongInfraredDeviceM *device;
@property (nonatomic,strong) NSArray<GSHKuKongInfraredDeviceM *> *tvRemoteList;
@end

@implementation GSHInfraredVirtualDeviceTVVC

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

+ (instancetype)tvHandleVCWithDevice:(GSHKuKongInfraredDeviceM *)device{
    GSHInfraredVirtualDeviceTVVC *vc = [TZMPageManager viewControllerWithSB:@"GSHInfraredVirtualDeviceSB" andID:@"GSHInfraredVirtualDeviceTVVC"];
    vc.device = device;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tzm_prefersNavigationBarHidden = YES;
    self.lblTitle.text = self.device.deviceName;
    self.btnTVOff.hidden = self.device.kkDeviceType.integerValue != 1;
//    self.btnHomePage.enabled = self.device.kkDeviceType.integerValue != 1;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.lblTitle.text = self.device.deviceName;
    self.btnRightNavBtn.hidden = [GSHOpenSDK share].currentFamily.permissions == GSHFamilyMPermissionsMember;
}

-(void)showTVRemoteView{
    __weak typeof(self)weakSelf = self;
    GSHTVSeleAlertVC *vc = [GSHTVSeleAlertVC tvSeleAlertVCWithList:self.tvRemoteList seleBlock:^(NSInteger index) {
        if (weakSelf.tvRemoteList.count > index) {
            [weakSelf bingTVWithRemoteId:weakSelf.tvRemoteList[index].remoteId];
        }
    }];
    [vc show];
}

-(void)bingTVWithRemoteId:(NSNumber*)remoteId{
    [SVProgressHUD showWithStatus:@"绑定中"];
    __weak typeof(self)weakSelf = self;
    [GSHInfraredControllerManager postUpdateInfraredDeviceWithFamilyId:[GSHOpenSDK share].currentFamily.familyId deviceSn:self.device.deviceSn bindRemoteId:remoteId deviceName:self.device.deviceName roomId:self.device.roomId newRoomId:nil block:^(NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }else{
            [SVProgressHUD showSuccessWithStatus:@"绑定成功"];
            weakSelf.device.bindRemoteId = remoteId;
        }
    }];
}

- (IBAction)touchRigthNavBut:(id)sender {
    GSHInfraredControllerEditVC *vc = [GSHInfraredControllerEditVC infraredControllerEditVCWithDevice:self.device];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)touchBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)touchBut:(UIButton *)sender {
    if (sender.tag == 1) {
        if (self.device.bindRemoteId.integerValue > 0) {
            [SVProgressHUD showWithStatus:@"控制中"];
            [GSHInfraredControllerManager postKuKongModuleVerifyWithRemoteId:self.device.bindRemoteId deviceSN:self.device.parentDeviceSn familyId:[GSHOpenSDK share].currentFamily.familyId operType:1 deviceTypeId:self.device.kkDeviceType remoteParam:nil keyParam:nil keyId:@(1) block:^(NSError *error) {
                if (error) {
                    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                }else{
                    [SVProgressHUD dismiss];
                }
            }];
        }else{
            __weak typeof(self)weakSelf = self;
            if (self.tvRemoteList) {
                [self showTVRemoteView];
            }else{
                [SVProgressHUD showWithStatus:@"搜索电视机中"];
                [GSHInfraredControllerManager getKuKongDeviceListWithParentDeviceId:self.device.parentDeviceId familyId:[GSHOpenSDK share].currentFamily.familyId kkDeviceType:@(2) deviceSn:nil block:^(NSArray<GSHKuKongInfraredDeviceM *> *list, NSError *error) {
                    if (error) {
                        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                    }else{
                        [SVProgressHUD dismiss];
                        if (list.count == 0) {
                            [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                                if (buttonIndex == 1) {
                                    GSHKuKongDeviceTypeM *type = [GSHKuKongDeviceTypeM new];
                                    type.devicetypeId = @(2);
                                    type.name = @"电视";
                                    
                                    GSHDeviceM *device = [GSHDeviceM new];
                                    device.deviceSn = weakSelf.device.parentDeviceSn;
                                    device.deviceId = weakSelf.device.parentDeviceId;
                                    device.deviceName = weakSelf.device.parentDeviceName;
                                    GSHInfraredControllerBrandVC *vc = [GSHInfraredControllerBrandVC infraredControllerBrandVCWithType:type device:device];
                                    [weakSelf.navigationController pushViewController:vc animated:YES];
                                }
                            } textFieldsSetupHandler:NULL andTitle:nil andMessage:@"无可关联的电视遥控，是否现在创建？" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
                        }else{
                            weakSelf.tvRemoteList = list;
                            [weakSelf showTVRemoteView];
                        }
                    }
                }];
            }
        }
        return;
    }
    NSInteger key = 0;
    if (self.device.kkDeviceType.integerValue != 1) {
        //电视机
        switch (sender.tag) {
            case 2:
                key = 1;
                break;
            case 3:
                key = 45;
                break;
            case 4:
                key = 106;
                break;
            case 5:
                key = 50;
                break;
            case 6:
                key = 51;
                break;
            case 7:
                key = 42;
                break;
            case 8:
                key = 46;
                break;
            case 9:
                key = 49;
                break;
            case 10:
                key = 47;
                break;
            case 11:
                key = 48;
                break;
            case 12:
                key = 43;//电视机没有频道加，用的是机顶盒的ID
                break;
            case 13:
                key = 44;//电视机没有频道减，用的是机顶盒的ID
                break;
            case 14:
                key = 61;
                break;
            case 15:
                key = 66;
                break;
            case 16:
                key = 71;
                break;
            case 17:
                key = 76;
                break;
            case 18:
                key = 81;
                break;
            case 19:
                key = 86;
                break;
            case 20:
                key = 91;
                break;
            case 21:
                key = 96;
                break;
            case 22:
                key = 101;
                break;
            case 23:
                key = 136;
                break;
            case 24:
                key = 56;
                break;
            case 25:
                key = 116;
                break;
            default:
                break;
        }
    }else{
        //机顶盒
        switch (sender.tag) {
            case 2:
                key = 1; //机顶盒电源
                break;
            case 3:
                key = 45;
                break;
            case 4:
                key = 106;
                break;
            case 5:
                key = 50;
                break;
            case 6:
                key = 51;
                break;
            case 7:
                key = 42;
                break;
            case 8:
                key = 46;
                break;
            case 9:
                key = 49;
                break;
            case 10:
                key = 47;
                break;
            case 11:
                key = 48;
                break;
            case 12:
                key = 43;
                break;
            case 13:
                key = 44;
                break;
            case 14:
                key = 61;
                break;
            case 15:
                key = 66;
                break;
            case 16:
                key = 71;
                break;
            case 17:
                key = 76;
                break;
            case 18:
                key = 81;
                break;
            case 19:
                key = 86;
                break;
            case 20:
                key = 91;
                break;
            case 21:
                key = 96;
                break;
            case 22:
                key = 101;
                break;
            case 23:
                key = 136;//机顶盒没有退出，共用电视机的主页
                break;
            case 24:
                key = 56;
                break;
            case 25:
                key = 116;
                break;
            default:
                break;
        }
    }
    [SVProgressHUD showWithStatus:@"控制中"];
    [GSHInfraredControllerManager postKuKongModuleVerifyWithRemoteId:self.device.remoteId deviceSN:self.device.parentDeviceSn familyId:[GSHOpenSDK share].currentFamily.familyId operType:1 deviceTypeId:self.device.kkDeviceType remoteParam:nil keyParam:nil keyId:@(key) block:^(NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }else{
            [SVProgressHUD dismiss];
        }
    }];
}
@end
