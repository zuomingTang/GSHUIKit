//
//  GSHSensorListVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/6/28.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHSensorListVC.h"
#import "JXMovableCellTableView.h"
#import "PopoverView.h"
#import "UINavigationController+TZM.h"
#import "GSHSensorParametersView.h"
#import "Masonry.h"
#import "GSHSensorDetailVC.h"
#import "UIScrollView+TZMRefreshAndLoadMore.h"
#import "GSHDeviceInfoDefines.h"
#import "NSObject+TZM.h"

@interface GSHSensorCell ()
@property (weak, nonatomic) IBOutlet UILabel *mainNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomLabel;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) GSHSensorParametersView *sensorParametersView;
@property (strong, nonatomic) GSHSensorParametersView *shrinkSensorParametersView;
@end

@implementation GSHSensorCell
-(void)awakeFromNib{
    [super awakeFromNib];
    if (self.sensorParametersView) {
        return;
    }
    self.sensorParametersView = [GSHSensorParametersView sensorParametersViewWithBigFont:[UIFont systemFontOfSize:40 weight:UIFontWeightThin]  littleFont:[UIFont systemFontOfSize:16] space:15 count:3];
    self.shrinkSensorParametersView = [GSHSensorParametersView sensorParametersViewWithBigFont:[UIFont systemFontOfSize:24 weight:UIFontWeightThin]  littleFont:[UIFont systemFontOfSize:14] space:13 count:3];

    [self.mainView addSubview:self.sensorParametersView];
    [self.mainView addSubview:self.shrinkSensorParametersView];
    
    self.shrinkSensorParametersView.hidden= YES;
    self.sensorParametersView.hidden = YES;
    
    __weak typeof(self)weakSelf = self;
    [self.sensorParametersView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.mainView);
    }];
    
    [self.shrinkSensorParametersView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.mainView);
        make.top.equalTo(weakSelf.mainView);
        make.bottom.equalTo(weakSelf.mainView);
        make.width.equalTo(@(44)).priority(1);
    }];
}

-(void)setModel:(GSHSensorM *)model{
    _model = model;
    [self.sensorParametersView refreshWithSensor:model];
    [self.shrinkSensorParametersView refreshWithSensor:model];
    self.mainNameLabel.text = model.deviceName;
    self.roomLabel.text = model.roomName;
}

-(void)showShrink:(BOOL)shrink{
    self.shrinkSensorParametersView.hidden = shrink;
    self.sensorParametersView.hidden = !shrink;
}
@end

@interface GSHSensorListVC () <JXMovableCellTableViewDelegate,JXMovableCellTableViewDataSource>
@property (weak, nonatomic) IBOutlet JXMovableCellTableView *sensorListTableView;
@property (weak, nonatomic) IBOutlet UILabel *lblFloor;
@property (weak, nonatomic) IBOutlet UIImageView *imageFloor;
- (IBAction)backButtonClick:(id)sender;
- (IBAction)chooseFloorButtonClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *viewChangeFloor;
@property (strong, nonatomic)GSHFloorM *floor;
@property (copy, nonatomic) void(^block)(GSHFloorM *floor);
@property (strong, nonatomic)NSMutableArray<PopoverAction*> *actionArray;
@property (assign,nonatomic)NSInteger seleNumber;
@end

@implementation GSHSensorListVC

+ (instancetype)sensorListVCWithFloor:(GSHFloorM*)floor block:(void(^)(GSHFloorM *floor))block{
    GSHSensorListVC *vc = [TZMPageManager viewControllerWithSB:@"SensorListSB" andID:@"GSHSensorListVC"];
    vc.floor = floor;
    vc.block = block;
    return vc;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)setFloor:(GSHFloorM *)floor{
    _floor = floor;
    self.lblFloor.text = floor.floorName;
    if (floor.sensorMsgList) {
        [self.sensorListTableView reloadData];
    }else{
        [self refreshSensor];
    }
    
    self.seleNumber = [[GSHOpenSDK share].currentFamily.floor indexOfObject:floor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tzm_prefersNavigationBarHidden = YES;
    self.viewChangeFloor.hidden = [GSHOpenSDK share].currentFamily.floor.count <= 1;
    if (self.floor) {
        self.floor = self.floor;
    }else{
        self.floor = [GSHOpenSDK share].currentFamily.floor.firstObject;
    }
    [self initActionArray];
    
    [self observerNotifications];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.sensorListTableView reloadData];
}

- (void)initActionArray{
    self.actionArray = [NSMutableArray array];
    for (GSHFloorM *floor in [GSHOpenSDK share].currentFamily.floor) {
        __weak typeof(self)weakSelf = self;
        PopoverAction *action = [PopoverAction actionWithImage:[UIImage imageNamed:@"personal_icon_choice_dan"] title:floor.floorName handler:^(PopoverAction *action) {
            weakSelf.lblFloor.text = floor.floorName;
            weakSelf.floor = floor;
            [UIView animateWithDuration:0.25 animations:^{
                weakSelf.imageFloor.transform =  CGAffineTransformRotate(weakSelf.imageFloor.transform, M_PI);
            }];
        }];
        [self.actionArray addObject:action];
    }
}

-(void)refreshSensor{
    __weak typeof(self)weakSelf = self;
    __weak typeof(GSHFloorM*)weakFloor = self.floor;
    if (self.floor.sensorMsgList.count == 0) {
        [SVProgressHUD showWithStatus:@"加载中"];
    }
    [GSHSensorManager getSensorListWithFamilyId:[GSHOpenSDK share].currentFamily.familyId floorId:weakFloor.floorId.stringValue block:^(NSArray<GSHSensorM *> *list, NSError *error) {
        [SVProgressHUD dismiss];
        [weakSelf.sensorListTableView.tzm_refreshControl stopIndicatorAnimation];
        if (![weakFloor.floorId isEqual:weakSelf.floor.floorId]) {
            if (list.count > 0) {
                weakFloor.sensorMsgList = [NSMutableArray arrayWithArray:list];
            }
            return;
        }
        if (error) {
            [SVProgressHUD showErrorWithStatus:@"获取传感器失败"];
        }else{
            if (list.count > 0) {
                weakFloor.sensorMsgList = [NSMutableArray arrayWithArray:list];
            }else{
                weakFloor.sensorMsgList = nil;
            }
        }
        [weakSelf.sensorListTableView reloadData];
    }];
}

#pragma mark - 通知
-(void)observerNotifications{
    [self observerNotification:GSHChangeNetworkManagerWebSocketRealDataUpdateNotification];
}

-(void)handleNotifications:(NSNotification *)notification {
    [self refreshSensorAfterReceiceRealTimeData];
}

#pragma mark - method

- (IBAction)backButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)chooseFloorButtonClick:(id)sender {
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.25
                     animations:^{
                         weakSelf.imageFloor.transform =  CGAffineTransformRotate(weakSelf.imageFloor.transform, M_PI);
                     } completion:^(BOOL finished) {
                         PopoverView *popoverView = [PopoverView popoverView];
                         popoverView.arrowStyle = PopoverViewArrowStyleTriangle;
                         popoverView.showShade = YES;
                         popoverView.seleNumber = weakSelf.seleNumber;
                         [popoverView showToView:weakSelf.lblFloor isLeftPic:NO withActions:weakSelf.actionArray hideBlock:^{
                             [UIView animateWithDuration:0.25 animations:^{
                                 weakSelf.imageFloor.transform =  CGAffineTransformRotate(weakSelf.imageFloor.transform, M_PI);
                             }];
                         }];
                     }];
}

#pragma mark - UITableViewDataSource
- (void)tzm_scrollViewRefresh:(UIScrollView *)scrollView refreshControl:(TZMPullToRefresh *)refreshControl{
    [self refreshSensor];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.floor.sensorMsgList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHSensorCell *sensorCell = [tableView dequeueReusableCellWithIdentifier:@"sensorCell" forIndexPath:indexPath];
    if (self.floor.sensorMsgList.count > indexPath.row) {
        sensorCell.model = self.floor.sensorMsgList[indexPath.row];
    }
    [sensorCell showShrink:indexPath.row == 0];
    return sensorCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 100.0f;
    }
    return 70.0f;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
        [SVProgressHUD showInfoWithStatus:@"离线环境无法查看"];
        return nil;
    }
    GSHSensorCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self.navigationController pushViewController:[GSHSensorDetailVC sensorDetailVCWithFamilyId:[GSHOpenSDK share].currentFamily.familyId sensor:[cell.model yy_modelCopy]] animated:YES];
    return nil;
}

/**
 *  完成一次从fromIndexPath cell到toIndexPath cell的移动
 */
- (void)tableView:(JXMovableCellTableView *)tableView didMoveCellFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    GSHSensorCell *fromCell = (GSHSensorCell *)[tableView cellForRowAtIndexPath:fromIndexPath];
    GSHSensorCell *toCell = (GSHSensorCell *)[tableView cellForRowAtIndexPath:toIndexPath];
    if (self.floor.sensorMsgList.count > fromIndexPath.row) {
        fromCell.model = self.floor.sensorMsgList[fromIndexPath.row];
        [fromCell showShrink:fromIndexPath.row == 0];
    }
    if (self.floor.sensorMsgList.count > toIndexPath.row) {
        [toCell showShrink:toIndexPath.row == 0];
        toCell.model = self.floor.sensorMsgList[toIndexPath.row];
    }
}

/**
 *  结束移动cell在indexPath
 */
- (void)tableView:(JXMovableCellTableView *)tableView endMoveCellAtIndexPath:(NSIndexPath *)indexPath{
    if (self.block) {
        self.block(self.floor);
    }
    [GSHSensorManager postSensorRankWithFamilyId:[GSHOpenSDK share].currentFamily.familyId floorId:self.floor.floorId.stringValue sensorList:self.floor.sensorMsgList block:^(NSError *error) {
    }];
}

- (NSMutableArray *)dataSourceArrayInTableView:(JXMovableCellTableView *)tableView {
    return [NSMutableArray arrayWithArray:@[self.floor.sensorMsgList]];
}

#pragma mark - 刷新传感器列表状态
- (void)refreshSensorAfterReceiceRealTimeData {
    NSArray *sensorList = [self.floor.sensorMsgList copy];
    for (GSHSensorM *sensorM in sensorList) {
        NSDictionary *dic = [sensorM realTimeDic];
        if (dic) {
            if ([sensorM.deviceType isEqualToNumber:GSHHumitureSensorDeviceType] &&
                ([dic objectForKey:GSHHumitureSensor_temMeteId] || [dic objectForKey:GSHHumitureSensor_humMeteId])) {
                // 温湿度
                for (GSHSensorMonitorM *monitorM in sensorM.attributeList) {
                    if ([monitorM.basMeteId isEqualToString:GSHHumitureSensor_temMeteId]) {
                        monitorM.valueString = [dic objectForKey:GSHHumitureSensor_temMeteId];
                    } else if ([monitorM.basMeteId isEqualToString:GSHHumitureSensor_humMeteId]) {
                        monitorM.valueString = [dic objectForKey:GSHHumitureSensor_humMeteId];
                    }
                }
            } else if ([sensorM.deviceType isEqualToNumber:GSHGateMagetismSensorDeviceType] && [dic objectForKey:GSHGateMagetismSensor_isOpenedMeteId]) {
                // 门磁
                for (GSHSensorMonitorM *monitorM in sensorM.attributeList) {
                    if ([monitorM.basMeteId isEqualToString:GSHGateMagetismSensor_isOpenedMeteId]) {
                        monitorM.valueString = [dic objectForKey:GSHGateMagetismSensor_isOpenedMeteId];
                        break;
                    }
                }
            } else if ([sensorM.deviceType isEqualToNumber:GSHAirBoxSensorDeviceType] && [dic objectForKey:GSHAirBoxSensor_pmMeteId]) {
                // 空气盒子
                for (GSHSensorMonitorM *monitorM in sensorM.attributeList) {
                    if ([monitorM.basMeteId isEqualToString:GSHAirBoxSensor_pmMeteId]) {
                        monitorM.valueString = [dic objectForKey:GSHAirBoxSensor_pmMeteId];
                        break;
                    }
                }
            } else if ([sensorM.deviceType isEqualToNumber:GSHSomatasensorySensorDeviceType] && [dic objectForKey:GSHSomatasensorySensor_alarmMeteId]) {
                // 人体红外
                for (GSHSensorMonitorM *monitorM in sensorM.attributeList) {
                    if ([monitorM.basMeteId isEqualToString:GSHSomatasensorySensor_alarmMeteId]) {
                        monitorM.valueString = [dic objectForKey:GSHSomatasensorySensor_alarmMeteId];
                        break;
                    }
                }
            } else if ([sensorM.deviceType isEqualToNumber:GSHGasSensorDeviceType] && [dic objectForKey:GSHGasSensor_alarmMeteId]) {
                // 气体传感器
                for (GSHSensorMonitorM *monitorM in sensorM.attributeList) {
                    if ([monitorM.basMeteId isEqualToString:GSHGasSensor_alarmMeteId]) {
                        monitorM.valueString = [dic objectForKey:GSHGasSensor_alarmMeteId];
                        break;
                    }
                }
            } else if ([sensorM.deviceType isEqualToNumber:GSHWaterLoggingSensorDeviceType] && [dic objectForKey:GSHWaterLoggingSensor_alarmMeteId]) {
                // 水浸传感器
                for (GSHSensorMonitorM *monitorM in sensorM.attributeList) {
                    if ([monitorM.basMeteId isEqualToString:GSHWaterLoggingSensor_alarmMeteId]) {
                        monitorM.valueString = [dic objectForKey:GSHWaterLoggingSensor_alarmMeteId];
                        break;
                    }
                }
            } else if ([sensorM.deviceType isEqualToNumber:GSHSOSSensorDeviceType] && [dic objectForKey:GSHSOSSensor_alarmMeteId]) {
                // 紧急按钮
                for (GSHSensorMonitorM *monitorM in sensorM.attributeList) {
                    if ([monitorM.basMeteId isEqualToString:GSHSOSSensor_alarmMeteId]) {
                        monitorM.valueString = [dic objectForKey:GSHSOSSensor_alarmMeteId];
                        break;
                    }
                }
            } else if ([sensorM.deviceType isEqualToNumber:GSHInfrareCurtainDeviceType] && [dic objectForKey:GSHInfrareCurtain_alarmMeteId]) {
                // 红外幕帘
                for (GSHSensorMonitorM *monitorM in sensorM.attributeList) {
                    if ([monitorM.basMeteId isEqualToString:GSHInfrareCurtain_alarmMeteId]) {
                        monitorM.valueString = [dic objectForKey:GSHInfrareCurtain_alarmMeteId];
                        break;
                    }
                }
            }
        }
    }
    self.floor.sensorMsgList = [NSMutableArray arrayWithArray:sensorList];
    [self.sensorListTableView reloadData];
}

@end
