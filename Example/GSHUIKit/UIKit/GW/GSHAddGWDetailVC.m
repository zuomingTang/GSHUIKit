//
//  GSHAddGWDetailVC.m
//  SmartHome
//
//  Created by gemdale on 2018/6/28.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHAddGWDetailVC.h"
#import "GSHAlertManager.h"
#import "GSHGateWayUpdateVC.h"
#import "UITextField+TZM.h"
#import "LGAlertView.h"
#import "GSHGWSettingVC.h"
#import "IQKeyboardManager.h"

@interface GSHAddGWDetailVCCell()
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblText;
@property (weak, nonatomic) IBOutlet UITextField *tfText;
@end
@implementation GSHAddGWDetailVCCell
@end

@interface GSHAddGWDetailVC ()<UITableViewDelegate,UITableViewDataSource>
- (IBAction)touchSave:(UIButton *)sender;
- (IBAction)touchDelete:(UIButton *)sender;
- (IBAction)touchUpdate:(UIButton *)sender;
- (IBAction)touchReset:(UIButton *)sender;
- (IBAction)touchChange:(UIButton *)sender;
- (IBAction)touchCancel:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *viewUpdate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lcUpdateHeigth;
@property (weak, nonatomic) IBOutlet UIButton *btnReset;
@property (weak, nonatomic) IBOutlet UIButton *btnChange;
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;

@property(strong, nonatomic)UITextField *tfGwName;
@property(strong, nonatomic)GSHFamilyM *family;
@property(strong, nonatomic)GSHGatewayM *gateWayM;
@property(strong, nonatomic)GSHDeviceM *deviceM;
@property(copy, nonatomic)NSString *gwId;
@property(assign, nonatomic)GSHAddGWDetailVCType type;

@property (nonatomic ,strong) GSHGatewayVersionM *gateWayVersionM;

@end

@implementation GSHAddGWDetailVC

+(instancetype)changeGWDetailVCWithGW:(NSString *)gwId family:(GSHFamilyM*)family{
    GSHAddGWDetailVC *vc = [TZMPageManager viewControllerWithSB:@"AddGWSB" andID:@"GSHAddGWDetailVC"];
    vc.family = family;
    vc.gwId = gwId;
    vc.type = GSHAddGWDetailVCTypeChange;
    return vc;
}

+(instancetype)addGWDetailVCWithGW:(NSString *)gwId family:(GSHFamilyM*)family{
    GSHAddGWDetailVC *vc = [TZMPageManager viewControllerWithSB:@"AddGWSB" andID:@"GSHAddGWDetailVC"];
    vc.family = family;
    vc.gwId = gwId;
    vc.type = GSHAddGWDetailVCTypeAdd;
    return vc;
}

+(instancetype)editGWDetailVCWithDevice:(GSHDeviceM*)deviceM{
    GSHAddGWDetailVC *vc = [TZMPageManager viewControllerWithSB:@"AddGWSB" andID:@"GSHAddGWDetailVC"];
    vc.deviceM = deviceM;
    vc.gwId = deviceM.gatewayId.stringValue;
    vc.type = GSHAddGWDetailVCTypeEdit;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.type == GSHAddGWDetailVCTypeAdd) {
        self.tableView.tableFooterView = nil;
    }else if (self.type == GSHAddGWDetailVCTypeEdit) {
        [self getGatewayUpdateInfo];    // 请求网关版本升级信息
        self.btnReset.hidden = NO;
        self.btnCancel.hidden = YES;
        self.btnChange.hidden = YES;
        self.btnDelete.hidden = NO;
    }else if (self.type == GSHAddGWDetailVCTypeChange) {
        self.btnReset.hidden = YES;
        self.btnCancel.hidden = NO;
        self.btnChange.hidden = NO;
        self.btnDelete.hidden = YES;
        self.btnSave.hidden = YES;
    }
    [self getGateWayInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchSave:(UIButton *)sender {

    [self.view endEditing:YES];
    if (!self.gwId || self.gwId.length == 0 || [self.gwId isEqualToString:@"unkonw"]) {
        [SVProgressHUD showErrorWithStatus:@"网关id出错"];
        return;
    }
    NSString *gwName = self.tfGwName.text;
    if (gwName.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入网关名字"];
        return;
    }
    [SVProgressHUD showWithStatus:@"保存中"];
    if (self.type == GSHAddGWDetailVCTypeAdd) {
        @weakify(self)
        [GSHGatewayManager postAddGatewayWithFamilyId:self.family.familyId gatewayId:self.gwId gatewayName:gwName block:^(NSError *error){
            @strongify(self)
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                [SVProgressHUD dismiss];
                self.family.gatewayId = self.gwId;
                [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                    if (buttonIndex == 1) {
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    } else {
                        if (self.navigationController.viewControllers.firstObject) {
                            GSHDeviceCategoryListVC *categoryListVC = [GSHDeviceCategoryListVC deviceCategorylist];
                            categoryListVC.hidesBottomBarWhenPushed = YES;
                            [self.navigationController setViewControllers:@[self.navigationController.viewControllers.firstObject,categoryListVC] animated:YES];
                        }
                    }
                } textFieldsSetupHandler:NULL andTitle:@"网关添加成功" andMessage:@"请添加网关下属的子设备" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:nil otherButtonTitles:@"暂不添加",@"添加设备",nil];
            }
        }];
    }else if (self.type == GSHAddGWDetailVCTypeEdit){
        __weak typeof(self)weakSelf = self;
        [SVProgressHUD showWithStatus:@"修改中"];
        [GSHDeviceManager postUpdateDeviceWithFamilyId:[GSHOpenSDK share].currentFamily.familyId
                                              deviceId:self.gateWayM.deviceId
                                              deviceSn:self.gateWayM.gatewayId
                                            deviceType:self.gateWayM.deviceType
                                                roomId:nil
                                             newRoomId:nil
                                            deviceName:gwName
                                             attribute:nil
                                                 block:^(GSHDeviceM *device, NSError *error) {
                                               if (error) {
                                                   [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                                               }else{
                                                   [SVProgressHUD showSuccessWithStatus:@"修改成功"];
                                                   weakSelf.deviceM.deviceName = gwName;
                                                   if (weakSelf.deviceEditSuccessBlock) {
                                                       weakSelf.deviceEditSuccessBlock(weakSelf.deviceM);
                                                   }
                                                   [weakSelf.navigationController popViewControllerAnimated:YES];
                                               }
                                           }];
    }
}

- (IBAction)touchDelete:(UIButton *)sender {
    // 删除网关
    __weak typeof(self)weakSelf = self;
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
        [[IQKeyboardManager sharedManager] setEnable:YES];
        if (buttonIndex == 0) {
            NSString *password;
            if([alert isKindOfClass:LGAlertView.class]){
                UITextField *tf = (UITextField*)((LGAlertView*)alert).innerView;
                if ([tf isKindOfClass:UITextField.class]) {
                    password = tf.text;
                }
            }
            if (password.length > 0) {
                [SVProgressHUD showWithStatus:@"删除中"];
                [GSHGatewayManager deleteGWWithFamilyId:[GSHOpenSDK share].currentFamily.familyId password:password block:^(NSError *error) {
                    if (error) {
                        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                    }else{
                        [SVProgressHUD showSuccessWithStatus:@"删除成功"];
                        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                    }
                }];
            }else{
                [SVProgressHUD showErrorWithStatus:@"未输入密码"];
            }
        }
    } textFieldsSetupHandler:^(UITextField *textField, NSUInteger index) {
        textField.placeholder = @"请输入登录密码";
        textField.font = [UIFont systemFontOfSize:14];
        textField.backgroundColor = [UIColor colorWithRGB:0xf0f0f0];
        textField.clipsToBounds = YES;
        textField.layer.cornerRadius = 3;
        textField.clearButtonMode = UITextFieldViewModeNever;
        textField.secureTextEntry = YES;
    } andTitle:@"确认删除网关？" andMessage:@"网关下绑定的所有设备将被一并删除" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:@"删除" cancelButtonTitle:@"取消" otherButtonTitles:nil];
}

- (IBAction)touchUpdate:(UIButton *)sender {
    if (!self.gateWayVersionM) {
        return;
    }
    GSHGateWayUpdateVC *updateVC = [GSHGateWayUpdateVC gateWayUpdateVC];
    [self.navigationController pushViewController:updateVC animated:YES];
}

- (IBAction)touchReset:(UIButton *)sender {
    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
        if (buttonIndex == 1) {
            [SVProgressHUD showWithStatus:@"重启网关中"];
            [GSHGatewayManager resetGatewayWithGatewayId:[GSHOpenSDK share].currentFamily.gatewayId block:^(NSError *error) {
                if (error) {
                    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                }else{
                    [SVProgressHUD dismissWithDelay:3];
                }
            }];
        }
    } textFieldsSetupHandler:NULL andTitle:@"确定重启网关吗？" andMessage:@"重启网关中设备将无法控制" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"取消" otherButtonTitles:@"立即重启",nil];
}

- (IBAction)touchChange:(UIButton *)sender {
    __weak typeof(self)weakSelf = self;
    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
        if (buttonIndex == 1) {
            [weakSelf startChange];
        }
    } textFieldsSetupHandler:NULL andTitle:nil andMessage:@"此操作会覆盖当前网关所有数据，需谨慎使用，确认替换" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确认",nil];
}

-(void)startChange{
    __weak typeof(self)weakSelf = self;
    [SVProgressHUD showWithStatus:@"替换中"];
    [GSHGatewayManager changeGatewayWithGatewayId:weakSelf.family.gatewayId newGatewayId:weakSelf.gwId familyId:weakSelf.family.familyId block:^(NSError *error) {
        if (error) {
            [SVProgressHUD dismiss];
            [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                if (buttonIndex == 2) {
                    [weakSelf startChange];
                }
            } textFieldsSetupHandler:NULL andTitle:@"替换失败" andMessage:error.localizedDescription image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"重试" otherButtonTitles:@"取消替换",nil];
        }else{
            [SVProgressHUD showSuccessWithStatus:@"替换成功"];
            [weakSelf.tabBarController setSelectedIndex:0];
            [weakSelf.navigationController popToRootViewControllerAnimated:NO];
        }
    }];
}

- (IBAction)touchCancel:(UIButton *)sender {
    NSMutableArray *array = [NSMutableArray array];
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:GSHGWSettingVC.class]) {
            [array addObject:vc];
            break;
        }
        [array addObject:vc];
    }
    [self.navigationController setViewControllers:array animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }else{
        return 7;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHAddGWDetailVCCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (indexPath.section == 0) {
        cell.tfText.hidden = NO;
        cell.lblText.hidden = YES;
        cell.tfText.tzm_maxLen = 8;
        cell.lblTitle.text = @"网关名称";
        if (self.type == GSHAddGWDetailVCTypeChange) {
            cell.tfText.userInteractionEnabled = NO;
            cell.tfText.text = self.gateWayM.gatewayName;
        }else if (self.type == GSHAddGWDetailVCTypeAdd){
            cell.tfText.userInteractionEnabled = YES;
            cell.tfText.text = @"";
        }else{
            cell.tfText.userInteractionEnabled = YES;
            cell.tfText.text = self.gateWayM.gatewayName;
        }
        self.tfGwName = cell.tfText;
    }else{
        cell.tfText.hidden = YES;
        cell.lblText.hidden = NO;
        if (indexPath.row == 0) {
            cell.lblText.text = self.gateWayM.deviceModelStr.length>0?self.gateWayM.deviceModelStr:@"暂无";
            cell.lblTitle.text = @"设备型号";
        }else if (indexPath.row == 1){
            cell.lblText.text = self.gateWayM.firmwareVersion.length>0?self.gateWayM.firmwareVersion:@"暂无";
            cell.lblTitle.text = @"网关版本";
        }else if (indexPath.row == 2){
            cell.lblText.text = self.gateWayM.coordinatorVersion.length>0?self.gateWayM.coordinatorVersion:@"暂无";
            cell.lblTitle.text = @"协调器版本";
        }else if (indexPath.row == 3){
            cell.lblText.text = self.gateWayM.gatewayId.length>0?self.gateWayM.gatewayId:@"暂无";
            cell.lblTitle.text = @"网关ID";
        }else if (indexPath.row == 4){
            cell.lblText.text = self.gateWayM.gatewayMac.length>0?self.gateWayM.gatewayMac:@"暂无";
            cell.lblTitle.text = @"MAC";
        }else if (indexPath.row == 5){
            cell.lblText.text = self.gateWayM.agreementName.length>0?self.gateWayM.agreementName:@"暂无";
            cell.lblTitle.text = @"协议类型";
        }else if (indexPath.row == 6){
            cell.lblText.text = self.gateWayM.manufacturerName.length>0?self.gateWayM.manufacturerName:@"暂无";
            cell.lblTitle.text = @"厂家";
        }
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

#pragma mark - request

// 获取网关信息
- (void)getGateWayInfo {
    @weakify(self)
    [SVProgressHUD showWithStatus:@"网关信息获取中"];
    NSString *familyId = nil;
    NSString *gwId = nil;
    if (GSHAddGWDetailVCTypeAdd == self.type) {
        gwId = self.gwId;
    }else{
        familyId = [GSHOpenSDK share].currentFamily.familyId;
    }
    [GSHGatewayManager getGatewayWithFamilyId:familyId gatewayId:gwId block:^(GSHGatewayM *gateWayM, NSError *error) {
        @strongify(self)
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        } else {
            [SVProgressHUD dismiss];
            self.gateWayM = gateWayM;
            [self.tableView reloadData];
        }
    }];
}

// 获取网关升级信息
- (void)getGatewayUpdateInfo {
    @weakify(self)
    [GSHGatewayManager getGatewayUpdateMsgWithFamilyId:[GSHOpenSDK share].currentFamily.familyId gatewayId:[GSHOpenSDK share].currentFamily.gatewayId block:^(GSHGatewayVersionM *gateWayVersionM, NSError *error) {
        @strongify(self)
        if (!error) {
            self.gateWayVersionM = gateWayVersionM;
            if (self.gateWayVersionM.updateFlag.intValue == 0 ||
                self.gateWayVersionM.updateFlag.intValue == 3) {
                self.viewUpdate.hidden = NO;
                self.lcUpdateHeigth.constant = 36.f;
            }
        }
    }];
}

@end
