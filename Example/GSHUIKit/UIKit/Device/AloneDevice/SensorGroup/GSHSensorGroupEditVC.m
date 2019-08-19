//
//  GSHSensorGroupEditVC.m
//  SmartHome
//
//  Created by gemdale on 2018/12/27.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import "GSHSensorGroupEditVC.h"
#import "GSHPickerView.h"
#import "NSString+TZM.h"
#import "GSHSensorGroupVC.h"

@interface GSHSensorGroupEditVC ()
@property (weak, nonatomic) IBOutlet UITextField *textF;
@property (weak, nonatomic) IBOutlet UILabel *lblRoom;
@property (weak, nonatomic) IBOutlet UILabel *lblDeviceType;
@property (weak, nonatomic) IBOutlet UILabel *lblSn;
@property (weak, nonatomic) IBOutlet UILabel *lblXieYi;
@property (weak, nonatomic) IBOutlet UILabel *lblChangJia;
- (IBAction)touchSave:(UIButton *)sender;

@property (strong,nonatomic)GSHDeviceCategoryM *category;
@property (nonatomic,strong)GSHSensorM *sensor;
@property(nonatomic,strong)GSHFloorM *floor;
@property(nonatomic,strong)GSHRoomM *room;

@end

@implementation GSHSensorGroupEditVC
+ (instancetype)sensorGroupEditVCWithSensor:(GSHSensorM *)sensor category:(GSHDeviceCategoryM*)category{
    GSHSensorGroupEditVC *vc = [TZMPageManager viewControllerWithSB:@"GSHSensorGroupSB" andID:@"GSHSensorGroupEditVC"];
    vc.sensor = sensor;
    vc.category = category;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self refreshUI];
}

-(void)refreshUI{
    self.lblSn.text = self.sensor.deviceSn;
    self.lblXieYi.text = self.sensor.agreementType;
    self.lblChangJia.text = self.sensor.manufacturer;
    if (self.sensor.deviceType.intValue == -2) {
        self.lblRoom.text = nil;
        self.lblDeviceType.text = self.category.deviceTypeStr;
        self.textF.text = nil;
    }else{
        self.lblDeviceType.text = self.sensor.deviceTypeStr;
        self.textF.text = self.sensor.deviceName;
        
        GSHFamilyM *family = [GSHOpenSDK share].currentFamily;
        NSArray<GSHFloorM *> * floors = [family filterFloor];
        if (floors.count > 1) {
            self.lblRoom.text = [NSString stringWithFormat:@"%@%@",self.sensor.floorName ? self.sensor.floorName : @"",self.sensor.roomName ? self.sensor.roomName : @""];
        }else{
            self.lblRoom.text = [NSString stringWithFormat:@"%@",self.sensor.roomName ? self.sensor.roomName : @""];
        }
    }
}

- (IBAction)touchSave:(UIButton *)sender {
    NSNumber *roomId = self.room.roomId ? self.room.roomId : self.sensor.roomId;
    NSNumber *deviceType = self.category.deviceType ? self.category.deviceType : self.sensor.deviceType;
    NSString *deviceName = self.textF.text;
    
    if(deviceName.length == 0){
        [SVProgressHUD showErrorWithStatus:@"请输入设备名"];
        return;
    }
    if ([deviceName judgeTheillegalCharacter]) {
        [SVProgressHUD showErrorWithStatus:@"名字不能含特殊字符"];
        return;
    }
    
    if((!roomId) || roomId.integerValue == -2){
        [SVProgressHUD showErrorWithStatus:@"请选择所属房间"];
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    [SVProgressHUD showWithStatus:@"绑定中"];
    [GSHSensorManager postSensorGroupUpdataWithFamilyId:[GSHOpenSDK share].currentFamily.familyId deviceId:self.sensor.deviceId.stringValue deviceType:deviceType.stringValue roomId:roomId.stringValue deviceName:deviceName block:^(NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }else{
            [SVProgressHUD showSuccessWithStatus:@"绑定成功"];
            weakSelf.sensor.roomId = roomId;
            weakSelf.sensor.roomName = weakSelf.room.roomName;
            weakSelf.sensor.floorName = weakSelf.floor.floorName;
            weakSelf.sensor.floorId = weakSelf.floor.floorId;
            weakSelf.sensor.deviceName = deviceName;
            weakSelf.sensor.deviceType = deviceType;
            weakSelf.sensor.deviceTypeStr = weakSelf.category.deviceTypeStr;
            
            NSMutableArray<UIViewController*> *vcs = [NSMutableArray array];
            for (UIViewController *vc in weakSelf.navigationController.viewControllers) {
                [vcs addObject:vc];
                if ([vc isKindOfClass:GSHSensorGroupVC.class]) {
                    [weakSelf.navigationController setViewControllers:vcs animated:YES];
                    break;
                }
            }
        }
    }];
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row != 1) {
        return nil;
    }
    __weak typeof(self)weakSelf = self;
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
    return nil;
}

@end
