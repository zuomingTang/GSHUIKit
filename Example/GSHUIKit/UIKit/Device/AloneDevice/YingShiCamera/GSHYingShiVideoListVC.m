//
//  GSHYingShiVideoListVC.m
//  SmartHome
//
//  Created by gemdale on 2019/5/10.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHYingShiVideoListVC.h"
#import "PGDatePickManager.h"
#import "UIView+TZMPageStatusViewEx.h"
#import "GSHYingShiVideoVC.h"

@interface GSHYingShiVideoListVCCell ()
@property (weak, nonatomic) IBOutlet UILabel *lblStartTime;
@property (weak, nonatomic) IBOutlet UILabel *lblEndTime;
@end
@implementation GSHYingShiVideoListVCCell
-(void)setFile:(EZDeviceRecordFile *)file{
    _file = file;
    self.lblStartTime.text = [file.startTime stringWithFormat:@"HH:mm:ss"];
    self.lblEndTime.text = [file.stopTime stringWithFormat:@"HH:mm:ss"];
}
@end

@interface GSHYingShiVideoListVC ()<UITableViewDelegate,UITableViewDataSource,PGDatePickerDelegate>
@property(nonatomic, strong)EZDeviceInfo *deviceInfo;
@property(nonatomic, strong)NSString *verifyCode;
- (IBAction)touchDate:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray<EZDeviceRecordFile*> *list;
@property (strong, nonatomic) NSDate *beginTime;
@property (strong, nonatomic) NSDate *endTime;
@end

@implementation GSHYingShiVideoListVC

+(instancetype)yingShiVideoListVCWithDeviceInfo:(EZDeviceInfo*)deviceInfo verifyCode:(NSString*)verifyCode{
    GSHYingShiVideoListVC *vc = [TZMPageManager viewControllerWithSB:@"GSHYingshiCameraToolSB" andID:@"GSHYingShiVideoListVC"];
    vc.deviceInfo = deviceInfo;
    vc.verifyCode = verifyCode;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *todaty = [[NSDate new] stringWithFormat:@"yyyyMMdd" timeZone:nil locale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [self updateDate:todaty];
}

-(void)showDateSele{
    PGDatePickManager *datePickManager = [[PGDatePickManager alloc]init];
    PGDatePicker *datePicker = datePickManager.datePicker;
    __weak typeof(self)weakSelf = self;
    datePickManager.cancelButtonMonitor = ^{
        NSString *todaty = [[NSDate new] stringWithFormat:@"yyyyMMdd" timeZone:nil locale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
        [weakSelf updateDate:todaty];
    };
    
    datePicker.delegate = self;
    datePicker.datePickerMode = PGDatePickerModeDate;
    datePicker.isHiddenMiddleText = NO;
    datePicker.middleTextColor = [UIColor clearColor];
    datePicker.maximumDate = [NSDate date];
    datePicker.minimumDate = [NSDate dateWithTimeIntervalSinceNow:-365*24*60*60];
    //设置线条的颜色
    datePicker.lineBackgroundColor = [UIColor colorWithHexString:@"#eaeaea"];
    //设置选中行的字体颜色
    datePicker.textColorOfSelectedRow = [UIColor colorWithHexString:@"#282828"];
    //设置未选中行的字体颜色
    datePicker.textColorOfOtherRow = [UIColor colorWithHexString:@"#999999"];
    //设置半透明的背景颜色
    datePickManager.isShadeBackgroud = YES;
    datePickManager.style = PGDatePickerType1;
    //设置头部的背景颜色
    datePickManager.headerViewBackgroundColor = [UIColor whiteColor];
    datePickManager.headerHeight = 45;
    //设置取消按钮的字体颜色
    datePickManager.cancelButtonTextColor = [UIColor colorWithHexString:@"#999999"];
    //设置取消按钮的字
    datePickManager.cancelButtonText = @"重置";
    //设置取消按钮的字体大小
    datePickManager.cancelButtonFont = [UIFont systemFontOfSize:17];
    //设置确定按钮的字体颜色
    datePickManager.confirmButtonTextColor = [UIColor colorWithHexString:@"#4C90F7"];
    //设置确定按钮的字
    datePickManager.confirmButtonText = @"完成";
    //设置确定按钮的字体大小
    datePickManager.confirmButtonFont = [UIFont systemFontOfSize:17];
    [self presentViewController:datePickManager animated:NO completion:nil];
}

- (void)updateDate:(NSString*)date{
    self.beginTime  = [NSDate dateWithString:[NSString stringWithFormat:@"%@000000",date] format:@"yyyyMMddHHmmss"];
    self.endTime = [NSDate dateWithString:[NSString stringWithFormat:@"%@235959",date] format:@"yyyyMMddHHmmss"];
    if ([self.beginTime isToday]) {
        self.lblDate.text = @"今天";
    }else if ([[self.beginTime dateByAddingDays:1] isToday]){
        self.lblDate.text = @"昨天";
    }else if ([[self.beginTime dateByAddingDays:2] isToday]){
        self.lblDate.text = @"前天";
    }else{
        self.lblDate.text = [self.beginTime stringWithFormat:@"yyyy年M月d日" timeZone:nil locale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    }
    [self refreshVideoList];
}

- (void)refreshVideoList{
    __weak typeof(self)weakSelf = self;
    [SVProgressHUD showWithStatus:@"加载中"];
    [EZOpenSDK searchRecordFileFromDevice:self.deviceInfo.deviceSerial cameraNo:self.deviceInfo.cameraNum beginTime:self.beginTime endTime:self.endTime completion:^(NSArray *deviceRecords, NSError *error) {
        [SVProgressHUD dismiss];
        weakSelf.list = deviceRecords;
        [weakSelf.tableView reloadData];
        if (deviceRecords.count > 0) {
            [weakSelf.tableView dismissPageStatusView];
        }else{
            [weakSelf.tableView showPageStatus:TZMPageStatusNormal image:[UIImage imageNamed:@"blankpage_icon_nodata"] title:nil desc:error.code == 1153445 ? @"当前时间暂无录像" : error.localizedDescription buttonText:[weakSelf.beginTime isToday] ? nil : @"重置筛选" didClickButtonCallback:^(TZMPageStatus status) {
                NSString *todaty = [[NSDate new] stringWithFormat:@"yyyyMMdd" timeZone:nil locale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
                [weakSelf updateDate:todaty];
            }];
        }
    }] ;
}

- (IBAction)touchDate:(UIButton *)sender {
    [self showDateSele];
}

- (void)datePicker:(PGDatePicker *)datePicker didSelectDate:(NSDateComponents *)dateComponents{
    NSString *dayString = [NSString stringWithFormat:@"%04d%02d%02d",(int)(dateComponents.year),(int)(dateComponents.month),(int)(dateComponents.day)];
    [self updateDate:dayString];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.list.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHYingShiVideoListVCCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (self.list.count - indexPath.row - 1 >= 0) {
        cell.file = self.list[self.list.count - indexPath.row - 1];
    }
    return cell;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.list.count - indexPath.row - 1 >= 0) {
        GSHYingShiVideoVC *vc = [GSHYingShiVideoVC yingShiCameraVCWithDeviceSerial:self.deviceInfo.deviceSerial cameraNo:self.deviceInfo.cameraNum recordFileList:self.list seleIndex:indexPath.row verifyCode:self.verifyCode];
        vc.title = @"内存卡录像";
        [self.navigationController pushViewController:vc animated:YES];
    }
    return nil;
}
@end
