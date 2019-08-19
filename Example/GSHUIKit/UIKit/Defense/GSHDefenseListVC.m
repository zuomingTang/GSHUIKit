//
//  GSHDefenseListVC.m
//  SmartHome
//
//  Created by zhanghong on 2019/5/23.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHDefenseListVC.h"
#import "GSHDefensePlanListVC.h"
#import "GSHDefenseAddVC.h"
#import "UIView+TZMPageStatusViewEx.h"
#import "UIViewController+TZMPageStatusViewEx.h"

@interface GSHDefenseListVC () <UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *deviceTypeTableView;
@property (strong , nonatomic) NSMutableArray *deviceTypeArray;

@end

@implementation GSHDefenseListVC

+(instancetype)defenseListVC {
    GSHDefenseListVC *vc = [TZMPageManager viewControllerWithSB:@"GSHDefenseSB" andID:@"GSHDefenseListVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self getDeviceTypeList];
}

#pragma mark - Lazy
- (NSMutableArray *)deviceTypeArray {
    if (!_deviceTypeArray) {
        _deviceTypeArray = [NSMutableArray array];
    }
    return _deviceTypeArray;
}

- (IBAction)addDefenseButtonClick:(id)sender {
    GSHDefensePlanListVC *defensePlanListVC = [GSHDefensePlanListVC defensePlanListVC];
    
    [self.navigationController pushViewController:defensePlanListVC animated:YES];
}

#pragma mark - request
// 请求设备品类
- (void)getDeviceTypeList {
    [SVProgressHUD showWithStatus:@"请求中"];
    @weakify(self)
    [GSHDefenseDeviceTypeManager getDefenseDeviceTypeWithFamilyId:[GSHOpenSDK share].currentFamily.familyId block:^(NSArray<GSHDefenseDeviceTypeM *> * _Nonnull list, NSError * _Nonnull error) {
        @strongify(self)
        [SVProgressHUD dismiss];
        if (error) {
            [self.view showPageStatus:TZMPageStatusNormal image:[UIImage imageNamed:@"blankpage_icon_network"] title:nil desc:error.localizedDescription buttonText:@"刷新" didClickButtonCallback:^(TZMPageStatus status) {
                [self getDeviceTypeList];
            }];
        } else {
            [self.view dismissPageStatusView];
            [self.deviceTypeArray addObjectsFromArray:list];
            [self.deviceTypeTableView reloadData];
        }
    }];
}

// 设置防御状态
- (void)setDefenceStateWithDefenseDeviceTypeM:(GSHDefenseDeviceTypeM *)deviceTypeM rowIndex:(int)rowIndex {
    GSHDefenseListCell *cell = [self.deviceTypeTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:rowIndex inSection:0]];
    NSString *defenseState = cell.defenceStateButton.selected ? @"1" : @"0";
    __weak typeof(cell) weakCell = cell;
    [SVProgressHUD showWithStatus:@"操作中"];
    [GSHDefenseDeviceTypeManager setDefenceStateWithFamilyId:[GSHOpenSDK share].currentFamily.familyId deviceType:deviceTypeM.deviceType defenceState:defenseState block:^(NSError * _Nonnull error) {
        __strong typeof(weakCell) strongCell = weakCell;
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        } else {
            [SVProgressHUD showSuccessWithStatus:@"操作成功"];
            strongCell.defenceStateButton.selected = [defenseState isEqualToString:@"0"] ? YES : NO;
            strongCell.defenceStateLabel.text = [defenseState isEqualToString:@"0"] ? @"已撤防" : @"防御中";
            deviceTypeM.defenceState = defenseState;
        }
    }];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.deviceTypeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHDefenseListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GSHDefenseListCell" forIndexPath:indexPath];
    if (self.deviceTypeArray.count > indexPath.row) {
        GSHDefenseDeviceTypeM *deviceTypeM = self.deviceTypeArray[indexPath.row];
        [cell layoutCellWithDeviceTypeM:deviceTypeM];
        @weakify(self)
        cell.defenceStateButtonClickBlock = ^(UIButton * _Nonnull button) {
            @strongify(self)
            [self setDefenceStateWithDefenseDeviceTypeM:deviceTypeM rowIndex:(int)indexPath.row];
        };
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHDefenseDeviceTypeM *deviceTypeM = self.deviceTypeArray[indexPath.row];
    if (deviceTypeM.enableFlag.integerValue == 0) {
        [SVProgressHUD showErrorWithStatus:@"家庭下无此类设备"];
        return;
    }
    GSHDefenseAddVC *addVC = [GSHDefenseAddVC defenseAddVCWithDefenseDeviceTypeM:deviceTypeM typeName:deviceTypeM.typeName];
    
    [self.navigationController pushViewController:addVC animated:YES];
}

@end


@interface GSHDefenseListCell ()

@property (weak, nonatomic) IBOutlet UIImageView *deviceImageView;
@property (weak, nonatomic) IBOutlet UILabel *defenseNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *noDeviceFlagLabel;

@end

@implementation GSHDefenseListCell


- (void)layoutCellWithDeviceTypeM:(GSHDefenseDeviceTypeM *)deviceTypeM {
    
//    [self.deviceImageView sd_setImageWithURL:[NSURL URLWithString:deviceTypeM.picPath]];
    NSString *imageStr = [NSString stringWithFormat:@"deviceCategroy_off_icon-%d",[deviceTypeM.deviceType intValue]];
    self.deviceImageView.image = [UIImage imageNamed:imageStr];
    
    self.defenseNameLabel.text = deviceTypeM.typeName;
    if (deviceTypeM.enableFlag.integerValue == 0) {
        // 无此类设备
        self.noDeviceFlagLabel.hidden = NO;
        self.defenceStateButton.hidden = YES;
        self.defenceStateLabel.text = @"暂无此类设备";
    } else {
        // 有此类设备 判断状态
        self.noDeviceFlagLabel.hidden = YES;
        self.defenceStateButton.hidden = NO;
        self.defenceStateButton.selected = [deviceTypeM.defenceState isEqualToString:@"0"] ? YES : NO;
        self.defenceStateLabel.text = [deviceTypeM.defenceState isEqualToString:@"0"] ? @"已撤防" : @"防御中";
    }
}

- (IBAction)defenceStateButtonClick:(UIButton *)sender {
    if (self.defenceStateButtonClickBlock) {
        self.defenceStateButtonClickBlock(sender);
    }
}

@end
