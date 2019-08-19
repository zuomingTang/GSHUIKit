//
//  GSHYingShiDeviceEditVC.m
//  SmartHome
//
//  Created by gemdale on 2019/1/8.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHYingShiDeviceEditVC.h"
#import "GSHPickerView.h"
#import "GSHDeviceListVC.h"
#import "GSHAlertManager.h"
#import "NSString+TZM.h"
#import "GSHDeviceCategoryListVC.h"
#import <EZOpenSDKFramework/EZOpenSDKFramework.h>

@interface GSHYingShiDeviceEditVC ()
@property (weak, nonatomic) IBOutlet UITextField *tfName;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellRoom;
@property (weak, nonatomic) IBOutlet UILabel *lblRoom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lcTrailing;
@property (weak, nonatomic) IBOutlet UILabel *lblXinHao;
@property (weak, nonatomic) IBOutlet UILabel *lblBanBen;
@property (weak, nonatomic) IBOutlet UILabel *lblSn;
@property (weak, nonatomic) IBOutlet UILabel *lblXieYi;
@property (weak, nonatomic) IBOutlet UILabel *lblChangJia;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
- (IBAction)touchDelete:(UIButton *)sender;
- (IBAction)touchSave:(UIButton *)sender;

@property(nonatomic,strong)GSHDeviceM *device;
@property(nonatomic,strong)GSHFloorM *floor;
@property(nonatomic,strong)GSHRoomM *room;

@end

@implementation GSHYingShiDeviceEditVC

+(instancetype)yingShiDeviceEditVCWithDevice:(GSHDeviceM*)device{
    GSHYingShiDeviceEditVC *vc = [TZMPageManager viewControllerWithSB:@"GSHAddYingShiDeviceSB" andID:@"GSHYingShiDeviceEditVC"];
    vc.device = device;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [GSHYingShiManager updataAccessTokenWithBlock:NULL];
    
    GSHFamilyM *family = [GSHOpenSDK share].currentFamily;
    NSArray<GSHFloorM *> * floors = [family filterFloor];
    if (floors.count > 1 || floors.firstObject.rooms.count > 1) {
        self.cellRoom.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (floors.count > 1) {
            self.lblRoom.text = [NSString stringWithFormat:@"%@%@",self.device.floorName?self.device.floorName:@"",self.device.roomName?self.device.roomName:@""];
        }else{
            self.lblRoom.text = [NSString stringWithFormat:@"%@",self.device.roomName?self.device.roomName:@""];
        }
    }else{
        self.cellRoom.accessoryType = UITableViewCellAccessoryNone;
        self.floor = floors.firstObject;
        self.room = self.floor.rooms.firstObject;
        self.lblRoom.text = [NSString stringWithFormat:@"%@",self.device.roomName?self.device.roomName:@""];
    }
    if (self.cellRoom.accessoryType == UITableViewCellAccessoryNone) {
        self.lcTrailing.constant = 15;
    }else{
        self.lcTrailing.constant = 0;
    }
    
    if (!self.device.deviceId) {
        self.tableView.tableFooterView = nil;
    }
    
    self.tfName.text = self.device.deviceName;
    self.lblXinHao.text = self.device.category.deviceModelStr;
    self.lblSn.text = self.device.deviceSn;
    self.lblXieYi.text = self.device.agreementType;
    self.lblChangJia.text = self.device.manufacturer;
    
    [self refreshBanBenUI];
}

-(void)refreshBanBenUI{
    __weak typeof(self)weakSelf = self;
    [SVProgressHUD showWithStatus:@"获取固件版本中"];
    [EZOpenSDK getDeviceVersion:self.device.deviceSn completion:^(EZDeviceVersion *version, NSError *error) {
        [SVProgressHUD dismiss];
        if (error) {
        }else{
            weakSelf.lblBanBen.text = version.currentVersion.length > 0 ? version.currentVersion : @"暂无";
        }
    }];
}

- (IBAction)touchDelete:(UIButton *)sender {
    __weak typeof(self)weakSelf = self;
    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
        if (buttonIndex == 0) {
            [SVProgressHUD showWithStatus:@"删除中"];
            [GSHYingShiManager postDeleteDeviceWithDeviceSerial:weakSelf.device.deviceSn deviceId:weakSelf.device.deviceId.stringValue areaId:weakSelf.device.roomId.stringValue block:^(NSError *error) {
                if (error) {
                    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                }else{
                    [SVProgressHUD showSuccessWithStatus:@"删除成功"];
                    for (UIViewController *vc in weakSelf.navigationController.viewControllers) {
                        if ([vc isKindOfClass:GSHDeviceListVC.class]) {
                            [weakSelf.navigationController popToViewController:vc animated:YES];
                            return;
                        }
                    }
                    [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                }
            }];
        }
    } textFieldsSetupHandler:NULL andTitle:nil andMessage:@"确认删除此设备吗？" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:@"删除" cancelButtonTitle:@"取消" otherButtonTitles:nil];
}

- (IBAction)touchSave:(UIButton *)sender {
    NSString *name = self.tfName.text;
    NSNumber *roomId = nil;
    if(name.length == 0){
        [SVProgressHUD showErrorWithStatus:@"请输入设备名"];
        return;
    }
    if (name.length > 8) {
        [SVProgressHUD showErrorWithStatus:@"名字超过限制长度"];
        return;
    }
    if ([name judgeTheillegalCharacter]) {
        [SVProgressHUD showErrorWithStatus:@"名字不能含特殊字符"];
        return;
    }
    
    if(self.room.roomId.stringValue.length > 0){
        roomId = self.room.roomId;
    }else{
        roomId = self.device.roomId;
    }
    if(!roomId){
        [SVProgressHUD showErrorWithStatus:@"请选择所属房间"];
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    if (!self.device.deviceId) {
        [SVProgressHUD showWithStatus:@"保存中"];
        [GSHYingShiManager postAddDeviceWithIpcName:name familyId:[GSHOpenSDK share].currentFamily.familyId ipcModel:self.device.deviceModel.stringValue areaId:roomId.stringValue validateCode:self.device.validateCode deviceSerial:self.device.deviceSn modelName:self.device.deviceModelStr block:^(GSHDeviceM *device, NSError *error) {
            if (error) {
                [SVProgressHUD dismiss];
                [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                    if (buttonIndex == 1) {
                        [weakSelf touchSave:nil];
                    }
                } textFieldsSetupHandler:NULL andTitle:@"设备添加失败" andMessage:nil image:[UIImage imageNamed:@"app_icon_error_red"] preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"取消" otherButtonTitles:@"重试",nil];
            }else{
                [SVProgressHUD dismiss];
                [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                    if (buttonIndex == 1) {
                        NSMutableArray *arr = [NSMutableArray array];
                        for (UIViewController *vc in weakSelf.navigationController.viewControllers) {
                            [arr addObject:vc];
                            if ([vc isKindOfClass:GSHDeviceCategoryListVC.class]) {
                                break;
                            }
                        }
                        [weakSelf.navigationController setViewControllers:arr animated:YES];
                    }else{
                        [weakSelf.navigationController popToRootViewControllerAnimated:NO];
                    }
                } textFieldsSetupHandler:NULL andTitle:@"设备添加成功" andMessage:nil image:[UIImage imageNamed:@"app_icon_susess"] preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"完成" otherButtonTitles:@"继续添加设备",nil];
            }
        }];
        
    }else{
        [SVProgressHUD showWithStatus:@"修改中"];
        [GSHYingShiManager postUpdateDeviceWithIpcName:name deviceSerial:self.device.deviceSn areaId:self.device.roomId.stringValue newAreaId:self.room.roomId.stringValue block:^(NSError *error) {
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                weakSelf.device.deviceName = name;
                if (weakSelf.floor.floorName.length > 0) {
                    weakSelf.device.floorName = weakSelf.floor.floorName;
                }
                if (weakSelf.room.roomName.length > 0) {
                    weakSelf.device.roomName = weakSelf.room.roomName;
                }
                [SVProgressHUD showSuccessWithStatus:@"修改成功"];
                if (weakSelf.deviceEditSuccessBlock) {
                    weakSelf.deviceEditSuccessBlock(weakSelf.device);
                }
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self)weakSelf = self;
    if (indexPath.row == 0 && indexPath.section == 1) {
        [self.view endEditing:NO];
        NSArray <GSHFloorM*> *floors = [[GSHOpenSDK share].currentFamily filterFloor];
        NSMutableArray *array = [NSMutableArray array];
        if (floors.count > 1) {
            for (GSHFloorM *floor in floors) {
                NSMutableArray<NSString*> *roomArr = [NSMutableArray array];
                for (GSHRoomM *room in floor.rooms) {
                    [roomArr addObject:room.roomName];
                }
                if (floor.floorName) {
                    [array addObject:@{floor.floorName:roomArr}];
                }
            }
        }else{
            for (GSHRoomM *room in floors.firstObject.rooms) {
                [array addObject:room.roomName];
            }
        }
        
        [GSHPickerView showPickerViewWithDataArray:array completion:^(NSString *selectContent , NSArray *selectRowArray) {
            weakSelf.lblRoom.text = selectContent;
            
            if (selectRowArray.count == 2) {
                id floorItem = selectRowArray[0];
                if ([floorItem isKindOfClass:NSNumber.class]) {
                    NSInteger floorRow = ((NSNumber*)floorItem).integerValue;
                    if (floors.count > floorRow) {
                        weakSelf.floor = floors[floorRow];
                        id roomItem = selectRowArray[1];
                        if ([roomItem isKindOfClass:NSNumber.class]) {
                            NSInteger roomRow = ((NSNumber*)roomItem).integerValue;
                            if (weakSelf.floor.rooms.count > roomRow) {
                                weakSelf.room = weakSelf.floor.rooms[roomRow];
                            }
                        }
                    }
                }
            }
            if (selectRowArray.count == 1) {
                weakSelf.floor = floors.firstObject;
                id roomItem = selectRowArray[0];
                if ([roomItem isKindOfClass:NSNumber.class]) {
                    NSInteger roomRow = ((NSNumber*)roomItem).integerValue;
                    if (weakSelf.floor.rooms.count > roomRow) {
                        weakSelf.room = weakSelf.floor.rooms[roomRow];
                    }
                }
            }
        }];
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

@end
