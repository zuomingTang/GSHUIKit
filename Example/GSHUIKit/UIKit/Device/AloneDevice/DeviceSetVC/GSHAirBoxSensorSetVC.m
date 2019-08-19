//
//  GSHAirBoxSensorSetVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/11/21.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import "GSHAirBoxSensorSetVC.h"
#import "UINavigationController+TZM.h"
#import "GSHDeviceInfoDefines.h"

@interface GSHAirBoxSensorSetVC () <UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic,strong) GSHDeviceM *deviceM;
@property (nonatomic,strong) NSArray *exts;

@property (weak, nonatomic) IBOutlet UITableView *airBoxTableView;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;

@property (nonatomic , strong) NSArray *firstLeftDataArr;
@property (nonatomic , strong) NSMutableArray *firstRightDataArr;
@property (nonatomic , strong) NSArray *secondLeftDataArr;
@property (nonatomic , strong) NSMutableArray *secondRightDataArr;
@property (nonatomic , strong) NSArray *thirdLeftDataArr;

@property (nonatomic,assign) BOOL firstHidden;
@property (nonatomic,assign) BOOL secondHidden;
@property (nonatomic,assign) BOOL thirdHidden;

@property (nonatomic , strong) GSHAirBoxSensorCell *firstCell;
@property (nonatomic , strong) GSHAirBoxSensorCell *secondCell;
@property (nonatomic , strong) GSHAirBoxSensorCell *thirdCell;

@property (nonatomic , strong) UISwitch *temSwitch;
@property (nonatomic , strong) UISwitch *humSwitch;
@property (nonatomic , strong) UISwitch *pmSwitch;

@property (nonatomic , strong) NSString *temLeftSelectStr;
@property (nonatomic , strong) NSString *temRightSelectStr;
@property (nonatomic , strong) NSString *humLeftSelectStr;
@property (nonatomic , strong) NSString *humRightSelectStr;
@property (nonatomic , strong) NSString *pmSelectStr;

@property (nonatomic , assign) NSInteger temLeftDefaultIndex;
@property (nonatomic , assign) NSInteger temRightDefaultIndex;
@property (nonatomic , assign) NSInteger humLeftDefaultIndex;
@property (nonatomic , assign) NSInteger humRightDefaultIndex;
@property (nonatomic , assign) NSInteger pmDefaultIndex;

@end

@implementation GSHAirBoxSensorSetVC

+ (instancetype)airBoxSensorSetVCWithDeviceM:(GSHDeviceM *)deviceM {
    GSHAirBoxSensorSetVC *vc = [TZMPageManager viewControllerWithSB:@"GSHAirBoxSensorSetSB" andID:@"GSHAirBoxSensorSetVC"];
    vc.deviceM = deviceM;
    vc.exts = deviceM.exts;
    return vc;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tzm_prefersNavigationBarHidden = YES;
    
    self.deviceNameLabel.text = self.deviceM.deviceName;
    
    self.airBoxTableView.sectionHeaderHeight = 70;
    self.airBoxTableView.sectionFooterHeight = 0;
    self.airBoxTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.01)];
    
    self.firstLeftDataArr = @[@"高于",@"低于"];
    self.secondLeftDataArr = @[@"高于",@"低于"];
    self.thirdLeftDataArr = @[@"严重污染",@"重度污染",@"中度污染",@"轻度污染",@"良",@"优"];
    
    self.temLeftSelectStr = @"高于";
    self.temRightSelectStr = @"26";
    self.humLeftSelectStr = @"高于";
    self.humRightSelectStr = @"65";
    self.pmSelectStr = @"中度污染";
    
    self.temRightDefaultIndex = [self.firstRightDataArr indexOfObject:self.temRightSelectStr];
    self.humRightDefaultIndex = [self.secondRightDataArr indexOfObject:self.humRightSelectStr];
    self.pmDefaultIndex = [self.thirdLeftDataArr indexOfObject:self.pmSelectStr];
    
    [self layoutUI];

}

- (void)layoutUI {
    self.temSwitch.on = NO;
    self.humSwitch.on = NO;
    self.pmSwitch.on = NO;
    self.firstHidden = YES;
    self.secondHidden = YES;
    self.thirdHidden = YES;
    for (GSHDeviceExtM *extM in self.exts) {
        if ([extM.basMeteId isEqualToString:GSHAirBoxSensor_temMeteId]) {
            self.temSwitch.on = YES;
            self.firstHidden = NO;
            self.temLeftSelectStr = [extM.conditionOperator isEqualToString:@">"] ? @"高于" : @"低于";
            self.temRightSelectStr = extM.rightValue;
            NSString *operatorStr = [extM.conditionOperator isEqualToString:@">"] ? @"高于" : @"低于";
            self.temLeftDefaultIndex = [self.firstLeftDataArr containsObject:operatorStr] ? [self.firstLeftDataArr indexOfObject:operatorStr] : 0;
            self.temRightDefaultIndex = [self.firstRightDataArr containsObject:extM.rightValue] ? [self.firstRightDataArr indexOfObject:extM.rightValue] : 0;
        } else if ([extM.basMeteId isEqualToString:GSHAirBoxSensor_humMeteId]) {
            self.humSwitch.on = YES;
            self.secondHidden = NO;
            self.humLeftSelectStr = [extM.conditionOperator isEqualToString:@">"] ? @"高于" : @"低于";
            self.humRightSelectStr = extM.rightValue;
            NSString *operatorStr = [extM.conditionOperator isEqualToString:@">"] ? @"高于" : @"低于";
            self.humLeftDefaultIndex = [self.secondLeftDataArr containsObject:operatorStr] ? [self.secondLeftDataArr indexOfObject:operatorStr] : 0;
            self.humRightDefaultIndex = [self.secondRightDataArr containsObject:extM.rightValue] ? [self.secondRightDataArr indexOfObject:extM.rightValue] : 0;
        } else if ([extM.basMeteId isEqualToString:GSHAirBoxSensor_pmMeteId]) {
            self.pmSwitch.on = YES;
            self.thirdHidden = NO;
            NSString *str = @"轻度污染";
            if (extM.rightValue.integerValue == 35) {
                str = @"优";
            } else if ([extM.conditionOperator isEqualToString:@"<"] && extM.rightValue.integerValue == 75) {
                str = @"良";
            } else if ([extM.conditionOperator isEqualToString:@">"] && extM.rightValue.integerValue == 75) {
                str = @"轻度污染";
            } else if (extM.rightValue.integerValue == 115) {
                str = @"中度污染";
            } else if (extM.rightValue.integerValue == 150) {
                str = @"重度污染";
            } else if (extM.rightValue.integerValue == 250) {
                str = @"严重污染";
            }
            self.pmSelectStr = str;
            self.pmDefaultIndex = [self.thirdLeftDataArr containsObject:self.pmSelectStr] ? [self.thirdLeftDataArr indexOfObject:self.pmSelectStr] : 0;
        }
    }
    
}

- (void)viewWillLayoutSubviews {
    [self.firstCell.leftPickerView selectRow:self.temLeftDefaultIndex inComponent:0 animated:NO];
    [self.firstCell.rightPickerView selectRow:self.temRightDefaultIndex inComponent:0 animated:NO];
    [self.secondCell.leftPickerView selectRow:self.humLeftDefaultIndex inComponent:0 animated:NO];
    [self.secondCell.rightPickerView selectRow:self.humRightDefaultIndex inComponent:0 animated:NO];
    [self.thirdCell.middlePickerView selectRow:self.pmDefaultIndex inComponent:0 animated:NO];
    [self.airBoxTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//
//    [self.firstCell.leftPickerView selectRow:self.temLeftDefaultIndex inComponent:0 animated:YES];
//    [self.firstCell.rightPickerView selectRow:self.temRightDefaultIndex inComponent:0 animated:YES];
//    [self.secondCell.leftPickerView selectRow:self.humLeftDefaultIndex inComponent:0 animated:YES];
//    [self.secondCell.rightPickerView selectRow:self.humRightDefaultIndex inComponent:0 animated:YES];
//    [self.thirdCell.leftPickerView selectRow:self.pmDefaultIndex inComponent:0 animated:YES];
//    [self.airBoxTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//}

#pragma mark - Lazy
- (NSMutableArray *)firstRightDataArr {
    if (!_firstRightDataArr) {
        _firstRightDataArr = [NSMutableArray array];
        for (int i = -40; i < 101; i ++) {
            NSString *str = [NSString stringWithFormat:@"%d",i];
            [_firstRightDataArr addObject:str];
        }
    }
    return _firstRightDataArr;
}

- (NSMutableArray *)secondRightDataArr {
    if (!_secondRightDataArr) {
        _secondRightDataArr = [NSMutableArray array];
        for (int i = 0; i < 101; i ++) {
            NSString *str = [NSString stringWithFormat:@"%d",i];
            [_secondRightDataArr addObject:str];
        }
    }
    return _secondRightDataArr;
}

#pragma mark - method

- (IBAction)backButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sureButtonClick:(id)sender {
    if (!self.temSwitch.on && !self.humSwitch.on && !self.pmSwitch) {
        [SVProgressHUD showErrorWithStatus:@"请选择温度或湿度阈值或空气质量"];
        return;
    }
    NSMutableArray *exts = [NSMutableArray array];
    if (self.temSwitch.on) {
        GSHDeviceExtM *temExtM = [[GSHDeviceExtM alloc] init];
        temExtM.basMeteId = GSHAirBoxSensor_temMeteId;
        temExtM.conditionOperator = [self.temLeftSelectStr isEqualToString:@"高于"] ? @">" : @"<";
        temExtM.rightValue = self.temRightSelectStr;
        [exts addObject:temExtM];
    }
    if (self.humSwitch.on) {
        GSHDeviceExtM *humExtM = [[GSHDeviceExtM alloc] init];
        humExtM.basMeteId = GSHAirBoxSensor_humMeteId;
        humExtM.conditionOperator = [self.humLeftSelectStr isEqualToString:@"高于"] ? @">" : @"<";
        humExtM.rightValue = self.humRightSelectStr;
        [exts addObject:humExtM];
    }
    if (self.pmSwitch.on) {
        NSMutableArray *arr = [NSMutableArray array];
        GSHDeviceExtM *deviceExtM1 = [[GSHDeviceExtM alloc] init];
        deviceExtM1.basMeteId = GSHAirBoxSensor_pmMeteId;
        if ([self.pmSelectStr isEqualToString:@"优"]) {
            deviceExtM1.conditionOperator = @"<";
            deviceExtM1.rightValue = @"35";
        } else if ([self.pmSelectStr isEqualToString:@"良"]) {
            deviceExtM1.conditionOperator = @"<";
            deviceExtM1.rightValue = @"75";
        } else if ([self.pmSelectStr isEqualToString:@"轻度污染"]) {
            deviceExtM1.conditionOperator = @">";
            deviceExtM1.rightValue = @"75";
        } else if ([self.pmSelectStr isEqualToString:@"中度污染"]) {
            deviceExtM1.conditionOperator = @">";
            deviceExtM1.rightValue = @"115";
        } else if ([self.pmSelectStr isEqualToString:@"重度污染"]) {
            deviceExtM1.conditionOperator = @">";
            deviceExtM1.rightValue = @"150";
        } else if ([self.pmSelectStr isEqualToString:@"严重污染"]) {
            deviceExtM1.conditionOperator = @">";
            deviceExtM1.rightValue = @"250";
        }
        [arr addObject:deviceExtM1];
        [exts addObjectsFromArray:arr];
    }
    if (self.deviceSetCompleteBlock) {
        self.deviceSetCompleteBlock(exts);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return self.firstHidden ? 0 : 100;
    } else if (indexPath.section == 1) {
        return self.secondHidden ? 0 : 100;
    } else {
        return self.thirdHidden ? 0 : 100;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHAirBoxSensorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GSHAirBoxSensorCell" forIndexPath:indexPath];
    //    [cell setCellDataSourceWithCellIndex:(int)indexPath.section];
    cell.contentView.tag = indexPath.section;
    cell.leftPickerView.delegate = self;
    cell.leftPickerView.dataSource = self;
    cell.rightPickerView.delegate = self;
    cell.rightPickerView.dataSource = self;
    cell.middlePickerView.delegate = self;
    cell.middlePickerView.dataSource = self;
    if (indexPath.section == 2) {
        cell.leftPickerView.hidden = YES;
        cell.rightPickerView.hidden = YES;
        cell.middlePickerView.hidden = NO;
    } else {
        cell.leftPickerView.hidden = NO;
        cell.rightPickerView.hidden = NO;
        cell.middlePickerView.hidden = YES;
    }
    if (indexPath.section == 0) {
        self.firstCell = cell;
    } else if (indexPath.section == 1) {
        self.secondCell = cell;
    } else {
        self.thirdCell = cell;
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 70)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(34, 0, SCREEN_WIDTH - 34 - 34 - 50 - 10, 70)];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16.0];
    [view addSubview:label];
    
    UISwitch *sectionSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 34 - 50, 20, 50, 30)];
    sectionSwitch.backgroundColor = [UIColor clearColor];
    sectionSwitch.onTintColor = [UIColor colorWithHexString:@"#4CA4C4"];
    sectionSwitch.tag = section;
    [sectionSwitch addTarget:self action:@selector(sectionSwitchClick:) forControlEvents:UIControlEventValueChanged];
    [view addSubview:sectionSwitch];
    
    if (section == 0) {
        label.text = @"设置触发阈值-温度";
        sectionSwitch.on = !self.firstHidden;
        self.temSwitch = sectionSwitch;
    } else if (section == 1) {
        label.text = @"设置触发阈值-湿度";
        sectionSwitch.on = !self.secondHidden;
        self.humSwitch = sectionSwitch;
    } else {
        label.text = @"设置触发阈值-空气质量";
        sectionSwitch.on = !self.thirdHidden;
        self.pmSwitch = sectionSwitch;
    }
    
    return view;
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSInteger i = pickerView.superview.tag;
    if (i == 0) {
        if (pickerView == self.firstCell.leftPickerView) {
            return self.firstLeftDataArr.count;
        } else {
            return self.firstRightDataArr.count;
        }
    } else if (i == 1) {
        if (pickerView == self.secondCell.leftPickerView) {
            return self.secondLeftDataArr.count;
        } else {
            return self.secondRightDataArr.count;
        }
    } else {
        return self.thirdLeftDataArr.count;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //获取选中的文字，以便于在别的地方使用
    NSInteger i = pickerView.superview.tag;
    if (i == 0) {
        if (pickerView == self.firstCell.leftPickerView) {
            self.temLeftSelectStr = self.firstLeftDataArr[row];
        } else {
            self.temRightSelectStr = self.firstRightDataArr[row];
        }
    } else if (i == 1) {
        if (pickerView == self.secondCell.leftPickerView) {
            self.humLeftSelectStr = self.secondLeftDataArr[row];
        } else {
            self.humRightSelectStr = self.secondRightDataArr[row];
        }
    } else {
        self.pmSelectStr = self.thirdLeftDataArr[row];
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    //设置分割线的颜色
    for(UIView *singleLine in pickerView.subviews) {
        if (singleLine.frame.size.height < 1) {
            singleLine.backgroundColor = [UIColor whiteColor];
        } else {
            singleLine.backgroundColor = [UIColor clearColor];
        }
    }
    //设置文字的属性
    UILabel *genderLabel = [UILabel new];
    genderLabel.backgroundColor = [UIColor clearColor];
    genderLabel.textAlignment = NSTextAlignmentCenter;
    genderLabel.textColor = [UIColor whiteColor];
    NSInteger i = pickerView.superview.tag;
    if (i == 0) {
        if (pickerView == self.firstCell.leftPickerView) {
            genderLabel.text = self.firstLeftDataArr[row];
        } else {
            genderLabel.text = [NSString stringWithFormat:@"%@˚C",self.firstRightDataArr[row]];
        }
    } else if (i == 1) {
        if (pickerView == self.secondCell.leftPickerView) {
            genderLabel.text = self.secondLeftDataArr[row];
        } else {
            genderLabel.text = [NSString stringWithFormat:@"%@%%",self.secondRightDataArr[row]];
        }
    } else {
        if (pickerView == self.thirdCell.middlePickerView) {
            genderLabel.text = self.thirdLeftDataArr[row];
        }
    }
    return genderLabel;
    
}

- (void)sectionSwitchClick:(UISwitch *)sectionSwitch {
    
    if (sectionSwitch.tag == 0) {
        self.firstHidden = !sectionSwitch.on;
    } else if (sectionSwitch.tag == 1) {
        self.secondHidden = !sectionSwitch.on;
    } else if (sectionSwitch.tag == 2) {
        self.thirdHidden = !sectionSwitch.on;
    }
    [self.airBoxTableView reloadData];
    if (sectionSwitch.tag == 2) {
        [self.airBoxTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}


@end


@implementation GSHAirBoxSensorCell 


@end

