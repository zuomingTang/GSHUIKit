//
//  GSHDefenseAddVC.m
//  SmartHome
//
//  Created by zhanghong on 2019/6/5.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHDefenseAddVC.h"
#import "GSHDefenseMeteChooseVC.h"
#import "GSHDefensePlanChooseVC.h"
#import "UINavigationController+TZM.h"
#import "GSHAlertManager.h"
#import "GSHDefenseMessageVC.h"

@implementation GSHDefenseSetOneCell

@end

@interface GSHDefenseAddVC () <UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) GSHDefenseDeviceTypeM *defenseDeviceTypeM;
@property (strong, nonatomic) GSHDefenseInfoM *defenseInfoM;
@property (weak, nonatomic) IBOutlet UITableView *defenseSetTableView;
@property (assign, nonatomic) BOOL isAlter;
@property (strong, nonatomic) NSString *typeName;

@end

@implementation GSHDefenseAddVC

+(instancetype)defenseAddVCWithDefenseDeviceTypeM:(GSHDefenseDeviceTypeM *)defenseDeviceTypeM typeName:(NSString *)typeName {
    GSHDefenseAddVC *vc = [TZMPageManager viewControllerWithSB:@"GSHDefenseSB" andID:@"GSHDefenseAddVC"];
    vc.defenseDeviceTypeM = defenseDeviceTypeM;
    vc.typeName = typeName;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getDefenseInfo];
}

- (BOOL)shouldHoldBackButtonEvent {
    return YES;
}

- (BOOL)canPopViewController {
    if (self.isAlter) {
        [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
            if (buttonIndex == 1) {
                [self saveDefenseInfo];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        } textFieldsSetupHandler:NULL andTitle:nil andMessage:@"是否保存已做的修改?" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"不保存" otherButtonTitles:@"保存",nil];
        return NO;
    }
    return YES;
}

#pragma mark - Action
// 消息按钮点击
- (IBAction)msgButtonClick:(id)sender {
    GSHDefenseMessageVC *defenseMessageVC = [[GSHDefenseMessageVC alloc] initWithTitle:self.typeName deviceType:self.defenseInfoM.deviceType];
    [self.navigationController pushViewController:defenseMessageVC animated:YES];
}

#pragma mark - Request
// 获取防御规则配置
- (void)getDefenseInfo {
    
    @weakify(self)
    [SVProgressHUD showWithStatus:@"请求中"];
    [GSHDefenseInfoManager getDefenseWithFamilyId:[GSHOpenSDK share].currentFamily.familyId
                                 deviceType:self.defenseDeviceTypeM.deviceType
                                      block:^(GSHDefenseInfoM * _Nonnull infoM, NSError * _Nonnull error) {
        @strongify(self)
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [SVProgressHUD dismiss];
            self.defenseInfoM = infoM;
            [self.defenseSetTableView reloadData];
            if (self.defenseInfoM.templateId) {
                // 有防御时间计划
                [self refreshTimeShowView];
            }
        }
    }];
}

- (void)saveDefenseInfo {
    
    if (self.defenseInfoM.reportLevel.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请设置告警等级"];
        return;
    }
    
    NSMutableArray *arr = [NSMutableArray array];
    for (GSHDefenseDeviceMeteM *meteM in self.defenseInfoM.deviceMeteList) {
        if (meteM.status.integerValue == 1) {
            [arr addObject:meteM.basMeteId];
        }
    }
    if (arr.count == 0) {
        [SVProgressHUD showErrorWithStatus:@"请设置至少一个告警项"];
        return;
    }
    if (!self.defenseInfoM.templateId) {
        [SVProgressHUD showErrorWithStatus:@"请设置防御计划"];
        return;
    }
    @weakify(self)
    [SVProgressHUD showWithStatus:@"保存中"];
    [GSHDefenseInfoManager setDefenseWithFamilyId:[GSHOpenSDK share].currentFamily.familyId deviceMeteList:arr defenseInfoM:self.defenseInfoM block:^(NSError * _Nonnull error) {
        @strongify(self)
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        } else {
            [SVProgressHUD showSuccessWithStatus:@"保存成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return self.defenseInfoM.deviceMeteList.count;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    GSHDefenseSetOneCell *oneCell = [tableView dequeueReusableCellWithIdentifier:@"oneCell" forIndexPath:indexPath];
    oneCell.backgroundColor = indexPath.section == 1 ? [UIColor clearColor] : [UIColor whiteColor];
    if (indexPath.section == 0) {
        oneCell.typeNameLabel.text = @"告警等级";
        oneCell.typeValueLabel.text = self.defenseInfoM.reportName?self.defenseInfoM.reportName:@"";
        oneCell.lineView.hidden = YES;
    } else if (indexPath.section == 1) {
        GSHDefenseDeviceMeteM *deviceMeteM = self.defenseInfoM.deviceMeteList[indexPath.row];
        oneCell.typeNameLabel.text = deviceMeteM.meteName;
        oneCell.typeValueLabel.text = deviceMeteM.status.integerValue == 0 ? @"撤防" : @"布防";
        oneCell.lineView.hidden = indexPath.row == self.defenseInfoM.deviceMeteList.count-1 ? YES : NO;
    } else {
        oneCell.typeNameLabel.text = @"防御计划";
        oneCell.typeValueLabel.text = self.defenseInfoM.templateName.length>0?self.defenseInfoM.templateName:@"";
        oneCell.lineView.hidden = YES;
    }
    return oneCell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHDefenseSetOneCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    __weak typeof(cell) weakCell = cell;
    
    if (indexPath.section == 0) {
        // 告警等级
        GSHDefenseMeteChooseVC *chooseVC = [GSHDefenseMeteChooseVC defenseMeteChooseVCWithTitle:@"告警等级" flag:2 selectValue:self.defenseInfoM.reportName?self.defenseInfoM.reportName:@""];
        @weakify(self)
        chooseVC.chooseBlock = ^(NSString * _Nonnull reportLevel, NSString * _Nonnull reportName) {
            @strongify(self)
            __strong typeof(weakCell) strongCell = weakCell;
            strongCell.typeValueLabel.text = reportName;
            self.defenseInfoM.reportName = reportName;
            self.defenseInfoM.reportLevel = reportLevel;
            self.isAlter = YES;
        };
        [self.navigationController pushViewController:chooseVC animated:YES];
    } else if (indexPath.section == 2) {
        // 防御计划
        @weakify(self)
        GSHDefensePlanChooseVC *chooseVC = [GSHDefensePlanChooseVC defensePlanChooseVCWithSelectTemplateId:self.defenseInfoM.templateId];
        chooseVC.chooseBlock = ^(GSHDefensePlanM * _Nonnull planM) {
            @strongify(self)
            __strong typeof(weakCell) strongCell = weakCell;
            strongCell.typeValueLabel.text = planM.templateName;
            self.defenseInfoM.templateId = planM.templateId;
            self.isAlter = YES;
            [self refreshTimeShowViewWithGSHDefensePlanM:planM];
        };
        chooseVC.updateSuccessBlock = ^(GSHDefensePlanM * _Nonnull planM) {
            @strongify(self)
            if ([planM.templateId isEqualToString:self.defenseInfoM.templateId]) {
                self.defenseInfoM.templateName = planM.templateName;
                self.defenseInfoM.monTime = planM.monTime;
                self.defenseInfoM.tueTime = planM.tueTime;
                self.defenseInfoM.wedTime = planM.wedTime;
                self.defenseInfoM.thuTime = planM.thuTime;
                self.defenseInfoM.friTime = planM.friTime;
                self.defenseInfoM.sauTime = planM.sauTime;
                self.defenseInfoM.sunTime = planM.sunTime;
                [self refreshTimeShowViewWithGSHDefensePlanM:planM];
            }
        };
        [self.navigationController pushViewController:chooseVC animated:YES];
    } else {
        GSHDefenseDeviceMeteM *deviceMeteM = self.defenseInfoM.deviceMeteList[indexPath.row];
        GSHDefenseMeteChooseVC *chooseVC = [GSHDefenseMeteChooseVC defenseMeteChooseVCWithTitle:deviceMeteM.meteName flag:1 selectValue:deviceMeteM.status];
        chooseVC.chooseBlock = ^(NSString * _Nonnull reportLevel, NSString * _Nonnull reportName) {
            __strong typeof(weakCell) strongCell = weakCell;
            strongCell.typeValueLabel.text = reportName;
            deviceMeteM.status = reportLevel;
            self.isAlter = YES;
        };
        [self.navigationController pushViewController:chooseVC animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.0001f;
    } else if (section == 1) {
        return 32.f;
    }
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    if (section == 1) {
        view.frame = CGRectMake(0, 0, SCREEN_WIDTH, 32);
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-15, 32)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorWithHexString:@"#999999"];
        label.font = [UIFont systemFontOfSize:14];
        label.text = @"请设置警告项";
        [view addSubview:label];
    }
    return view;
}

#pragma mark - draw time

- (void)refreshTimeShowView {
    if (self.defenseInfoM.monTime.length > 0) {
        [self drawLineWithTime:self.defenseInfoM.monTime flag:0];
    }
    if (self.defenseInfoM.tueTime.length > 0) {
        [self drawLineWithTime:self.defenseInfoM.tueTime flag:1];
    }
    if (self.defenseInfoM.wedTime.length > 0) {
        [self drawLineWithTime:self.defenseInfoM.wedTime flag:2];
    }
    if (self.defenseInfoM.thuTime.length > 0) {
        [self drawLineWithTime:self.defenseInfoM.thuTime flag:3];
    }
    if (self.defenseInfoM.friTime.length > 0) {
        [self drawLineWithTime:self.defenseInfoM.friTime flag:4];
    }
    if (self.defenseInfoM.sauTime.length > 0) {
        [self drawLineWithTime:self.defenseInfoM.sauTime flag:5];
    }
    if (self.defenseInfoM.sunTime.length > 0) {
        [self drawLineWithTime:self.defenseInfoM.sunTime flag:6];
    }
}

- (void)refreshTimeShowViewWithGSHDefensePlanM:(GSHDefensePlanM *)planM {
    if (planM.monTime.length > 0) {
        [self drawLineWithTime:planM.monTime flag:0];
    }
    if (planM.tueTime.length > 0) {
        [self drawLineWithTime:planM.tueTime flag:1];
    }
    if (planM.wedTime.length > 0) {
        [self drawLineWithTime:planM.wedTime flag:2];
    }
    if (planM.thuTime.length > 0) {
        [self drawLineWithTime:planM.thuTime flag:3];
    }
    if (planM.friTime.length > 0) {
        [self drawLineWithTime:planM.friTime flag:4];
    }
    if (planM.sauTime.length > 0) {
        [self drawLineWithTime:planM.sauTime flag:5];
    }
    if (planM.sunTime.length > 0) {
        [self drawLineWithTime:planM.sunTime flag:6];
    }
}

- (void)drawLineWithTime:(NSString *)time flag:(int)flag {
    
    UIView *view = (UIView *)[self.view viewWithTag:(int)flag+1];
    
    [view.layer addSublayer:[self drawLineWithStartPoint:CGPointMake(0, view.frame.size.height/2.0) endPoint:CGPointMake(view.frame.size.width, view.frame.size.height/2.0) lineColor:[UIColor whiteColor]]];
    
    NSRange startRange = [time rangeOfString:@"1"];
    if (startRange.location != NSNotFound) {
        NSRange endRange = [time rangeOfString:@"1" options:NSBackwardsSearch];
        int startLocation = (int)startRange.location;
        int endLocation = (int)endRange.location+1;
        
        CGPoint startPoint = CGPointMake(startLocation/48.0 * view.frame.size.width, view.frame.size.height/2.0);
        CGPoint endPoint = CGPointMake(endLocation/48.0 * view.frame.size.width, view.frame.size.height/2.0);
        
        CAShapeLayer *layer = [self drawLineWithStartPoint:startPoint endPoint:endPoint lineColor:[UIColor colorWithHexString:@"#4c90f7"]];
        [view.layer addSublayer:layer];
    }
}

- (CAShapeLayer *)drawLineWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint lineColor:(UIColor *)lineColor {
    //创建出CAShapeLayer
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.fillColor = [UIColor clearColor].CGColor;//填充颜色为ClearColor
    
    //设置线条的宽度和颜色
    shapeLayer.lineWidth = 18.0f;
    shapeLayer.strokeColor = lineColor.CGColor;
    
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:startPoint];
    [linePath addLineToPoint:endPoint];
    [linePath setLineWidth:18.0];
    [linePath setLineJoinStyle:kCGLineJoinBevel];
    [linePath setLineCapStyle:kCGLineCapButt];
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [linePath stroke];
    [linePath fill];
    UIGraphicsEndImageContext();
    //让贝塞尔曲线与CAShapeLayer产生联系
    shapeLayer.path = linePath.CGPath;
    //添加并显示
    return shapeLayer;
}

@end
