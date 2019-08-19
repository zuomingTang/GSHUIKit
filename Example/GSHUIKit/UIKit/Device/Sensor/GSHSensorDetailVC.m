//
//  GSHSensorDetailVC.m
//  SmartHome
//
//  Created by gemdale on 2018/11/13.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import "GSHSensorDetailVC.h"
#import "UINavigationController+TZM.h"
#import "TZMBrokenLineGraphView.h"
#import "Masonry.h"
#import "UIScrollView+TZMRefreshAndLoadMore.h"
#import "GSHDeviceEditVC.h"
#import "UIView+TZMPageStatusViewEx.h"
#import "GSHDeviceInfoDefines.h"

@interface GSHSensorDetailVCAlarmCell()
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UIView *line;
@property (weak, nonatomic) IBOutlet UILabel *lblText;
@property (weak, nonatomic) IBOutlet UIView *downLine;
@property (nonatomic,strong)GSHSensorAlarmM *alerm;
@end
@implementation GSHSensorDetailVCAlarmCell
+(CGFloat)cellHeightWithModel:(GSHSensorAlarmM *)model cellWidth:(CGFloat)width{
    CGSize size = [model.msgBody sizeForFont:[UIFont systemFontOfSize:14] size:CGSizeMake(width - 100 - 15, 1000) mode:NSLineBreakByCharWrapping];
    return size.height + 17;
}

-(void)setAlerm:(GSHSensorAlarmM *)alerm{
    _alerm = alerm;
    
    self.lblTime.text = [alerm.msgTime componentsSeparatedByString:@" "].lastObject;
    self.lblText.text = alerm.msgBody;
}
@end

@interface GSHSensorDetailVC ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *blackNavbar;
@property (weak, nonatomic) IBOutlet UIView *whiteNavbar;
@property (weak, nonatomic) IBOutlet UIButton *btnWhiteNavbarItem;
@property (weak, nonatomic) IBOutlet UIButton *btnBlackNavbarItem;
@property (weak, nonatomic) IBOutlet UILabel *lblBlackTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblWhiteTitle;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *navbarBg;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *tableHeadView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lcTopViewTop;
@property (weak, nonatomic) IBOutlet UILabel *lblOnlyText;
@property (weak, nonatomic) IBOutlet UIView *viewDouble;
@property (weak, nonatomic) IBOutlet UILabel *lblDoubleTopText;
@property (weak, nonatomic) IBOutlet UILabel *lblDoubleBottonText;
@property (weak, nonatomic) IBOutlet UILabel *lblElectric;
@property (weak, nonatomic) IBOutlet UIView *dateView;

@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UIView *viewPrevious;
@property (weak, nonatomic) IBOutlet UIView *viewBehind;

- (IBAction)back:(UIButton *)sender;
- (IBAction)touchPreviousDay:(UIButton *)sender;
- (IBAction)touchBehindDay:(UIButton *)sender;
- (IBAction)goDevice:(UIButton *)sender;

@property(nonatomic,copy)NSString *familyId;
@property(nonatomic,strong)GSHSensorM *sensor;

@property(nonatomic,strong)CAGradientLayer *gradientLayer;
@property(nonatomic,strong)NSArray<TZMBrokenLineGraphView*> *brokenLineGraphViewList;
@property(nonatomic,assign)NSInteger alermPage;
@property(nonatomic,strong)NSDate *nowDate;
@property(nonatomic,strong)NSDate *launchDate;

@property(nonatomic,assign)CGFloat navbarBgAlpha;

@property(nonatomic,strong)NSArray<GSHSensorAlarmM *> *alarmList;
@property(nonatomic,strong)NSArray<GSHSensorHistoryMonitorM *> *monitorList;
@end

@implementation GSHSensorDetailVC

+(instancetype)sensorDetailVCWithFamilyId:(NSString*)familyId sensor:(GSHSensorM*)sensor{
    GSHSensorDetailVC *vc = [TZMPageManager viewControllerWithSB:@"SensorListSB" andID:@"GSHSensorDetailVC"];
    vc.familyId = familyId;
    vc.sensor = sensor;
    return vc;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    if (self.navbarBgAlpha > 0.2) {
        return UIStatusBarStyleDefault;
    }
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tzm_prefersNavigationBarHidden = YES;
    self.tzm_interactivePopDisabled = YES;
    self.title = self.sensor.deviceName;
    self.lblWhiteTitle.text = self.sensor.deviceName;
    self.lblBlackTitle.text = self.sensor.deviceName;
    self.alermPage = 0;
    self.nowDate = [NSDate date];
    self.launchDate = self.sensor.launchDate;
    self.lblTime.text = [self.nowDate stringWithFormat:@"yyyy-MM-dd EE"];
    [self refreshDateView];
    [self initUI];
    [self refreshRealData];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if ([self.sensor.deviceType isEqualToNumber:GSHAirBoxSensorDeviceType]) {
        self.tableView.tableHeaderView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, self.navbarBg.height + self.tableView.frame.size.width / 375 * 223 + 44 + 5 + 3 * (self.tableView.frame.size.width / 375 * 165 + 5));
    } else if ([self.sensor.deviceType isEqualToNumber:GSHHumitureSensorDeviceType]) {
        self.tableView.tableHeaderView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, self.navbarBg.height + self.tableView.frame.size.width / 375 * 223 + 44 + 5 + 2 * (self.tableView.frame.size.width / 375 * 165 + 5));
    } else {
        // 隐藏曲线图部分
        self.tableView.tableHeaderView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, self.navbarBg.height + self.tableView.frame.size.width / 375 * 223 + 44 + 5);
    }
    
    self.lcTopViewTop.constant = self.navbarBg.height;
    self.gradientLayer.frame = self.bgView.bounds;
    self.tableView.tzm_refreshControl.originalInsetTop = self.navbarBg.height;
    self.tableView.tzm_refreshControl.textColor = [UIColor colorWithRGB:0x282828];
}

-(void)initUI {
    self.btnBlackNavbarItem.hidden = [GSHOpenSDK share].currentFamily.permissions == GSHFamilyMPermissionsMember;
    self.btnWhiteNavbarItem.hidden = [GSHOpenSDK share].currentFamily.permissions == GSHFamilyMPermissionsMember;
    
    //初始化CAGradientlayer对象
    self.gradientLayer = [CAGradientLayer layer];
    //将CAGradientlayer对象添加在我们要设置背景色的视图的layer层
    [self.bgView.layer addSublayer:self.gradientLayer];
    //设置渐变区域的起始和终止位置（范围为0-1）
    self.gradientLayer.startPoint = CGPointMake(0, 0);
    self.gradientLayer.endPoint = CGPointMake(0, 1);
    //设置颜色分割点（范围：0-1）
    self.gradientLayer.locations = @[@(0.0f), @(1.0f)];
    self.gradientLayer.colors = @[(__bridge id)[UIColor colorWithRGB:0x22d02a].CGColor,
                                  (__bridge id)[UIColor colorWithRGB:0x2fbd5f].CGColor];
    
    __weak typeof(self)weakSelf = self;
    NSMutableArray<TZMBrokenLineGraphView*> *list = [NSMutableArray array];
    int count = 0;
    if ([self.sensor.deviceType isEqualToNumber:GSHAirBoxSensorDeviceType]) {
        count = 3;
    } else if ([self.sensor.deviceType isEqualToNumber:GSHHumitureSensorDeviceType]) {
        count = 2;
    }
    
    UIView *previousView = self.dateView;
    for (int i = 0; i < count; i++) {
        TZMBrokenLineGraphView *brokenLineGraphView = [TZMBrokenLineGraphView wrokenLineGraphViewWithXTitle:@"时间" yTitle:nil xUnitNumber:500 yUnit:300];
        brokenLineGraphView.backgroundColor = [UIColor whiteColor];
        [self.tableHeadView addSubview:brokenLineGraphView];
        [brokenLineGraphView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.tableHeadView);
            make.right.equalTo(weakSelf.tableHeadView);
            make.height.equalTo(brokenLineGraphView.mas_width).multipliedBy(165.0 / 375.0);
            make.top.equalTo(previousView.mas_bottom).offset(5);
        }];
        [list addObject:brokenLineGraphView];
        previousView = brokenLineGraphView;
    }
    self.brokenLineGraphViewList = list;
}

-(void)refreshDateView{
    if([[self.nowDate stringWithFormat:@"yyyy-MM-dd"] compare:[[NSDate date] stringWithFormat:@"yyyy-MM-dd"]] == NSOrderedAscending){
        self.viewBehind.hidden = NO;
    }else{
        self.viewBehind.hidden = YES;
    }
    
    if([[self.nowDate stringWithFormat:@"yyyy-MM-dd"] compare:[self.launchDate stringWithFormat:@"yyyy-MM-dd"]] == NSOrderedDescending && [[self.nowDate stringWithFormat:@"yyyy-MM-dd"] compare:[[self.nowDate dateByAddingDays:-30] stringWithFormat:@"yyyy-MM-dd"]] == NSOrderedDescending){
        self.viewPrevious.hidden = NO;
    }else{
        self.viewPrevious.hidden = YES;
    }
    
    self.lblTime.text = [self.nowDate stringWithFormat:@"yyyy-MM-dd EE"];
    [self refreshHistoryData];
}

- (IBAction)back:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)touchPreviousDay:(UIButton *)sender {
    self.nowDate = [self.nowDate dateByAddingDays:-1];
    [self refreshDateView];
}

- (IBAction)touchBehindDay:(UIButton *)sender {
    self.nowDate = [self.nowDate dateByAddingDays:1];
    [self refreshDateView];
}

- (IBAction)goDevice:(UIButton *)sender {
    GSHDeviceM *deviceM = self.sensor;
    GSHDeviceEditVC *deviceEditVC = [GSHDeviceEditVC deviceEditVCWithDevice:deviceM type:GSHDeviceEditVCTypeEdit];
    __weak typeof(self)weakSelf = self;
    deviceEditVC.deviceEditSuccessBlock = ^(GSHDeviceM *deviceM) {
        weakSelf.lblWhiteTitle.text = deviceM.deviceName;
        weakSelf.lblBlackTitle.text = deviceM.deviceName;
        
        weakSelf.sensor.deviceName = deviceM.deviceName;
        if (deviceM.floorName.length > 0) {
            weakSelf.sensor.floorName = deviceM.floorName;
        }
        if (deviceM.roomName.length > 0) {
            weakSelf.sensor.roomName = deviceM.roomName;
        }
    };
    [self.navigationController pushViewController:deviceEditVC animated:YES];
}

- (void)refreshRealData {
    @weakify(self)
    [GSHSensorManager getSensorRealDataWithFamilyId:self.familyId deviceSn:self.sensor.deviceSn block:^(GSHSensorM *sensorM, NSError *error) {
        @strongify(self)
        self.sensor.attributeList = sensorM.attributeList;
        if (sensorM.showAttributeList.count > 1) {
            // 温湿度
            self.lblOnlyText.hidden = YES;
            self.viewDouble.hidden = NO;
            if (sensorM.showAttributeList.count >= 2) {
                if (((GSHSensorMonitorM *)sensorM.showAttributeList[0]).showMeteStr) {
                    self.lblDoubleTopText.text = [NSString stringWithFormat:@"%@%@",((GSHSensorMonitorM *)sensorM.showAttributeList[0]).showMeteStr,((GSHSensorMonitorM *)sensorM.showAttributeList[0]).unit];
                }
                if (((GSHSensorMonitorM *)sensorM.showAttributeList[1]).showMeteStr) {
                    self.lblDoubleBottonText.text = [NSString stringWithFormat:@"%@%@",((GSHSensorMonitorM *)sensorM.showAttributeList[1]).showMeteStr,((GSHSensorMonitorM *)sensorM.showAttributeList[1]).unit];
                }
            }
            self.lblElectric.text = sensorM.electricString;
        } else {
            self.lblOnlyText.hidden = NO;
            self.viewDouble.hidden = YES;
            if (sensorM.showAttributeList.count >= 1) self.lblOnlyText.text = ((GSHSensorMonitorM *)sensorM.showAttributeList[0]).showMeteStr;
            self.lblElectric.text = sensorM.electricString;
        }

        switch (sensorM.grade) {
            case 1:
                // 优
                self.gradientLayer.colors = @[(__bridge id)[UIColor colorWithRGB:0x22d02a].CGColor,
                                              (__bridge id)[UIColor colorWithRGB:0x2fbd5f].CGColor];
                break;
            case 2:
                // 良 正常
                self.gradientLayer.colors = @[(__bridge id)[UIColor colorWithRGB:0x3CA3FF].CGColor,
                                              (__bridge id)[UIColor colorWithRGB:0x507CF7].CGColor];
                break;
            case 3:
                // 轻度污染
                self.gradientLayer.colors = @[(__bridge id)[UIColor colorWithRGB:0xDEE52A].CGColor,
                                              (__bridge id)[UIColor colorWithRGB:0xF2B700].CGColor];
                break;
            case 4:
                // 中度污染
                self.gradientLayer.colors = @[(__bridge id)[UIColor colorWithRGB:0xFEBD07].CGColor,
                                              (__bridge id)[UIColor colorWithRGB:0xF28314].CGColor];
                break;
            case 5:
                // 重度污染 告警
                self.gradientLayer.colors = @[(__bridge id)[UIColor colorWithRGB:0xF5552A].CGColor,
                                              (__bridge id)[UIColor colorWithRGB:0xDA0033].CGColor];
                break;
            case 6:
                // 颜色污染
                self.gradientLayer.colors = @[(__bridge id)[UIColor colorWithRGB:0xD90056].CGColor,
                                              (__bridge id)[UIColor colorWithRGB:0xA7003D].CGColor];
                break;
            default:
                break;
        }
    }];
}

- (void)refreshHistoryData {
    __weak typeof(self)weakSelf = self;
    [SVProgressHUD showWithStatus:@"加载数据中"];
    [GSHSensorManager getSensorHistoryDataWithFamilyId:self.familyId deviceSn:self.sensor.deviceSn deviceType:self.sensor.deviceType.stringValue hisDate:[self.nowDate stringWithFormat:@"yyyy-MM-dd"] block:^(NSArray<GSHSensorHistoryMonitorM *> *monitorList, NSArray<GSHSensorAlarmM *> *alarmList, NSError *error) {
        [SVProgressHUD dismiss];
        if (error) {
            [SVProgressHUD showErrorWithStatus:@"加载失败"];
        }
        weakSelf.monitorList = monitorList;
        weakSelf.alarmList = alarmList;
        
        [weakSelf.tableView reloadData];
        
        if (self.alarmList.count == 0) {
            self.tableView.tableFooterView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.width);
            self.tableView.tableFooterView = self.tableView.tableFooterView;
            [self.tableView.tableFooterView showPageStatus:TZMPageStatusNormal image:[UIImage imageNamed:@"sensorDetailVC_nodata_icon"] title:nil desc:@"暂无记录" buttonText:nil didClickButtonCallback:^(TZMPageStatus status) {
            }];
        }else{
            self.tableView.tableFooterView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 10);
            self.tableView.tableFooterView = self.tableView.tableFooterView;
            [self.tableView.tableFooterView dismissPageStatusView];
        }
        
        if ([weakSelf.sensor.deviceType isEqualToNumber:GSHHumitureSensorDeviceType] ||
            [weakSelf.sensor.deviceType isEqualToNumber:GSHAirBoxSensorDeviceType]) {
            // 温湿度或空气盒子
            for (GSHSensorHistoryMonitorM *model in weakSelf.monitorList) {
                model.lineType = GSHSensorHistoryMonitorMTypeContinuous;
            }
            [weakSelf refreshUI];
        }
        
    }];
}

-(void)refreshUI{
    int index = 0;
    for (GSHSensorHistoryMonitorM *monitor in self.monitorList) {
        TZMBrokenLineGraphViewModel *model = [TZMBrokenLineGraphViewModel new];
        model.title = monitor.meteName;
        model.unitString = monitor.unit;
        model.lineColor = [UIColor colorWithHexString:monitor.lineColor];
        
        NSMutableArray<TZMLineGraphViewPointBaseModel*>*array = [NSMutableArray array];
        CGFloat differenceValue = monitor.maxValue - monitor.minValue;
        CGFloat differenceTime = monitor.endTime - monitor.startTime;
        
        if (monitor.timeValueList.firstObject) {
            GSHSensorHistoryMonitorValueM *value = monitor.timeValueList.firstObject;
            if (fabs(value.time - monitor.startTime) > 1000) {
                [array addObject:[TZMBrokenLineGraphViewPointModel pointWithValue:value.value y:(value.value - monitor.minValue) / differenceValue  x:0]];
            }
        }
        for (GSHSensorHistoryMonitorValueM *value in monitor.timeValueList) {
            [array addObject:[TZMBrokenLineGraphViewPointModel pointWithValue:value.value y:(value.value - monitor.minValue) / differenceValue  x:(value.time - monitor.startTime) / differenceTime]];
        }
        if (monitor.timeValueList.lastObject) {
            GSHSensorHistoryMonitorValueM *value = monitor.timeValueList.lastObject;
            if (fabs(value.time - monitor.endTime) > 1000) {
                [array addObject:[TZMBrokenLineGraphViewPointModel pointWithValue:value.value y:(value.value - monitor.minValue) / differenceValue  x:1]];
            }
        }
        
        model.pointArr = [NSArray arrayWithArray:array];
        model.xChangeBlock = ^NSString *(CGFloat x) {
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:(differenceTime * x + monitor.startTime) / 1000];
            return [date stringWithFormat:@"HH:mm"];
        };
        
        if (self.brokenLineGraphViewList.count > index) {
            [self.brokenLineGraphViewList[index] refreshWithModels:@[model]];
        }
        index++;
    }
}

- (void)tzm_scrollViewRefresh:(UIScrollView *)scrollView refreshControl:(TZMPullToRefresh *)refreshControl{
    [self refreshRealData];
    [self refreshHistoryData];
    [self.tableView.tzm_refreshControl stopIndicatorAnimation];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.alarmList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHSensorDetailVCAlarmCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (indexPath.row < self.alarmList.count) {
        cell.alerm = self.alarmList[indexPath.row];
    }
    cell.line.hidden = indexPath.row == 0;
    cell.downLine.hidden = indexPath.row == self.alarmList.count - 1;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < self.alarmList.count) {
        return [GSHSensorDetailVCAlarmCell cellHeightWithModel:self.alarmList[indexPath.row] cellWidth:tableView.width];
    }
    return 0;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y > 0) {
        self.navbarBgAlpha = (scrollView.contentOffset.y / (self.tableView.frame.size.width / 375 * 223 + self.navbarBg.height)) > 1 ? 1 : (scrollView.contentOffset.y / (self.tableView.frame.size.width / 375 * 223 + self.navbarBg.height));
        self.whiteNavbar.alpha = 1 - self.navbarBgAlpha;
        self.navbarBg.alpha = self.navbarBgAlpha;
        self.blackNavbar.alpha = self.navbarBgAlpha;
    }else if (scrollView.contentOffset.y < 0) {
        self.navbarBgAlpha = (-scrollView.contentOffset.y / self.navbarBg.height) > 1 ? 1 : (-scrollView.contentOffset.y / self.navbarBg.height);
        self.whiteNavbar.alpha = 1 - self.navbarBgAlpha;
        self.navbarBg.alpha = self.navbarBgAlpha;
        self.blackNavbar.alpha = self.navbarBgAlpha;
    }else{
        self.navbarBgAlpha = 0;
        self.whiteNavbar.alpha = 1 - self.navbarBgAlpha;
        self.navbarBg.alpha = self.navbarBgAlpha;
        self.blackNavbar.alpha = self.navbarBgAlpha;
    }
    [self setNeedsStatusBarAppearanceUpdate];
}


@end
