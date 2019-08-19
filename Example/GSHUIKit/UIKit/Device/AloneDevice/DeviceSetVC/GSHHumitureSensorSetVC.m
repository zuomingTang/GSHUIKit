//
//  GSHHumitureSensorSetVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/11/15.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import "GSHHumitureSensorSetVC.h"
#import "UINavigationController+TZM.h"
#import "GSHDeviceInfoDefines.h"

@interface GSHHumitureSensorSetVC () <UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (nonatomic,strong) GSHDeviceM *deviceM;
@property (nonatomic,strong) NSArray *exts;
@property (weak, nonatomic) IBOutlet UITableView *humitureTableView;

@property (nonatomic , strong) UISwitch *temSwitch;
@property (nonatomic , strong) UISwitch *humSwitch;

@property (nonatomic,assign) BOOL firstHidden;
@property (nonatomic,assign) BOOL secondHidden;

@property (nonatomic , strong) NSArray *firstLeftDataArr;
@property (nonatomic , strong) NSMutableArray *firstRightDataArr;
@property (nonatomic , strong) NSArray *secondLeftDataArr;
@property (nonatomic , strong) NSMutableArray *secondRightDataArr;
@property (nonatomic , strong) GSHHumitureSenSorCell *firstCell;
@property (nonatomic , strong) GSHHumitureSenSorCell *secondCell;

@property (nonatomic , strong) NSString *temLeftSelectStr;
@property (nonatomic , strong) NSString *temRightSelectStr;
@property (nonatomic , strong) NSString *humLeftSelectStr;
@property (nonatomic , strong) NSString *humRightSelectStr;

@property (nonatomic , assign) NSInteger temLeftDefaultIndex;
@property (nonatomic , assign) NSInteger temRightDefaultIndex;
@property (nonatomic , assign) NSInteger humLeftDefaultIndex;
@property (nonatomic , assign) NSInteger humRightDefaultIndex;

@end

@implementation GSHHumitureSensorSetVC

+ (instancetype)humitureSensorSetVCWithDeviceM:(GSHDeviceM *)deviceM {
    GSHHumitureSensorSetVC *vc = [TZMPageManager viewControllerWithSB:@"GSHHumitureSensorSetSB" andID:@"GSHHumitureSensorSetVC"];
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
    
    self.humitureTableView.sectionHeaderHeight = 70;
    self.humitureTableView.sectionFooterHeight = 0;
    self.humitureTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.01)];
    
    self.firstLeftDataArr = @[@"高于",@"低于"];
    self.secondLeftDataArr = @[@"高于",@"低于"];
    
    self.temLeftSelectStr = @"高于";
    self.temRightSelectStr = @"26";
    self.humLeftSelectStr = @"高于";
    self.humRightSelectStr = @"65";
    self.temRightDefaultIndex = [self.firstRightDataArr indexOfObject:self.temRightSelectStr];
    self.humRightDefaultIndex = [self.secondRightDataArr indexOfObject:self.humRightSelectStr];
    
    if (self.exts.count > 0) {
        [self layoutUI];
    }
}

- (void)layoutUI {
    if (self.exts.count == 1) {
        GSHDeviceExtM *extM = self.exts[0];
        if ([extM.basMeteId isEqualToString:GSHHumitureSensor_temMeteId]) {
            self.temSwitch.on = YES;
            self.humSwitch.on = NO;
            self.firstHidden = NO;
            self.secondHidden = YES;
            [self.humitureTableView reloadData];
            self.temLeftSelectStr = [extM.conditionOperator isEqualToString:@">"] ? @"高于" : @"低于";
            self.temRightSelectStr = extM.rightValue;
            NSString *operatorStr = [extM.conditionOperator isEqualToString:@">"] ? @"高于" : @"低于";
            self.temLeftDefaultIndex = [self.firstLeftDataArr containsObject:operatorStr] ? [self.firstLeftDataArr indexOfObject:operatorStr] : 0;
            self.temRightDefaultIndex = [self.firstRightDataArr containsObject:extM.rightValue] ? [self.firstRightDataArr indexOfObject:extM.rightValue] : 0;
        } else {
            self.temSwitch.on = NO;
            self.humSwitch.on = YES;
            self.firstHidden = YES;
            self.secondHidden = NO;
            [self.humitureTableView reloadData];
            self.humLeftSelectStr = [extM.conditionOperator isEqualToString:@">"] ? @"高于" : @"低于";
            self.humRightSelectStr = extM.rightValue;
            NSString *operatorStr = [extM.conditionOperator isEqualToString:@">"] ? @"高于" : @"低于";
            self.humLeftDefaultIndex = [self.secondLeftDataArr containsObject:operatorStr] ? [self.secondLeftDataArr indexOfObject:operatorStr] : 0;
            self.humRightDefaultIndex = [self.secondRightDataArr containsObject:extM.rightValue] ? [self.secondRightDataArr indexOfObject:extM.rightValue] : 0;
        }
    } else {
        for (GSHDeviceExtM *extM in self.exts) {
            if ([extM.basMeteId isEqualToString:GSHHumitureSensor_temMeteId]) {
                self.temLeftSelectStr = [extM.conditionOperator isEqualToString:@">"] ? @"高于" : @"低于";
                self.temRightSelectStr = extM.rightValue;
                NSString *operatorStr = [extM.conditionOperator isEqualToString:@">"] ? @"高于" : @"低于";
                self.temLeftDefaultIndex = [self.firstLeftDataArr containsObject:operatorStr] ? [self.firstLeftDataArr indexOfObject:operatorStr] : 0;
                self.temRightDefaultIndex = [self.firstRightDataArr containsObject:extM.rightValue] ? [self.firstRightDataArr indexOfObject:extM.rightValue] : 0;
            } else {
                self.humLeftSelectStr = [extM.conditionOperator isEqualToString:@">"] ? @"高于" : @"低于";
                self.humRightSelectStr = extM.rightValue;
                NSString *operatorStr = [extM.conditionOperator isEqualToString:@">"] ? @"高于" : @"低于";
                self.humLeftDefaultIndex = [self.secondLeftDataArr containsObject:operatorStr] ? [self.secondLeftDataArr indexOfObject:operatorStr] : 0;
                self.humRightDefaultIndex = [self.secondRightDataArr containsObject:extM.rightValue] ? [self.secondRightDataArr indexOfObject:extM.rightValue] : 0;
            }
        }
    }
}

- (void)viewWillLayoutSubviews {
    
    [self.firstCell.leftPickerView selectRow:self.temLeftDefaultIndex inComponent:0 animated:NO];
    [self.firstCell.rightPickerView selectRow:self.temRightDefaultIndex inComponent:0 animated:NO];
    [self.secondCell.leftPickerView selectRow:self.humLeftDefaultIndex inComponent:0 animated:NO];
    [self.secondCell.rightPickerView selectRow:self.humRightDefaultIndex inComponent:0 animated:NO];
}

//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//
//    [self.firstCell.leftPickerView selectRow:self.temLeftDefaultIndex inComponent:0 animated:YES];
//    [self.firstCell.rightPickerView selectRow:self.temRightDefaultIndex inComponent:0 animated:YES];
//    [self.secondCell.leftPickerView selectRow:self.humLeftDefaultIndex inComponent:0 animated:YES];
//    [self.secondCell.rightPickerView selectRow:self.humRightDefaultIndex inComponent:0 animated:YES];
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
    
    if (!self.temSwitch.on && !self.humSwitch.on) {
        [SVProgressHUD showErrorWithStatus:@"请选择温度或湿度阈值"];
        return;
    }
    NSMutableArray *exts = [NSMutableArray array];
    if (self.temSwitch.on) {
        GSHDeviceExtM *temExtM = [[GSHDeviceExtM alloc] init];
        temExtM.basMeteId = GSHHumitureSensor_temMeteId;
        temExtM.conditionOperator = [self.temLeftSelectStr isEqualToString:@"高于"] ? @">" : @"<";
        temExtM.rightValue = self.temRightSelectStr;
        [exts addObject:temExtM];
    }
    if (self.humSwitch.on) {
        GSHDeviceExtM *humExtM = [[GSHDeviceExtM alloc] init];
        humExtM.basMeteId = GSHHumitureSensor_humMeteId;
        humExtM.conditionOperator = [self.humLeftSelectStr isEqualToString:@"高于"] ? @">" : @"<";
        humExtM.rightValue = self.humRightSelectStr;
        [exts addObject:humExtM];
    }
    if (self.deviceSetCompleteBlock) {
        self.deviceSetCompleteBlock(exts);
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return self.firstHidden ? 0 : 100;
    } else {
        return self.secondHidden ? 0 : 100;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHHumitureSenSorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GSHHumitureSenSorCell" forIndexPath:indexPath];
    cell.contentView.tag = indexPath.section;
    cell.leftPickerView.dataSource = self;
    cell.leftPickerView.delegate = self;
    cell.rightPickerView.dataSource = self;
    cell.rightPickerView.delegate = self;
    if (indexPath.section == 0) {
        self.firstCell = cell;
    } else {
        self.secondCell = cell;
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 70)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(34, 0, SCREEN_WIDTH - 34 - 34 - 50 - 10, 70)];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16.0];
    label.text = section == 0 ? @"设置触发阈值-温度" : @"设置触发阈值-湿度";
    [view addSubview:label];
    
    UISwitch *sectionSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 34 - 50, 20, 50, 30)];
    sectionSwitch.backgroundColor = [UIColor clearColor];
    sectionSwitch.onTintColor = [UIColor colorWithHexString:@"#4CA4C4"];
    sectionSwitch.on = section==0 ? !self.firstHidden : !self.secondHidden;
    [sectionSwitch addTarget:self action:@selector(sectionSwitchClick:) forControlEvents:UIControlEventValueChanged];
    [view addSubview:sectionSwitch];
    if (section == 0) {
        self.temSwitch = sectionSwitch;
    } else {
        self.humSwitch = sectionSwitch;
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
    } else {
        if (pickerView == self.secondCell.leftPickerView) {
            return self.secondLeftDataArr.count;
        } else {
            return self.secondRightDataArr.count;
        }
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
    } else {
        if (pickerView == self.secondCell.leftPickerView) {
            self.humLeftSelectStr = self.secondLeftDataArr[row];
        } else {
            self.humRightSelectStr = self.secondRightDataArr[row];
        }
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    //设置分割线的颜色
    for(UIView *singleLine in pickerView.subviews) {
        if (singleLine.frame.size.height < 1) {
            singleLine.backgroundColor = [UIColor whiteColor];
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
    } else {
        if (pickerView == self.secondCell.leftPickerView) {
            genderLabel.text = self.secondLeftDataArr[row];
        } else {
            genderLabel.text = [NSString stringWithFormat:@"%@%%",self.secondRightDataArr[row]];
        }
    }
    return genderLabel;
    
}

- (void)sectionSwitchClick:(UISwitch *)sectionSwitch {
    
    if (sectionSwitch == self.temSwitch) {
        self.firstHidden = !sectionSwitch.on;
    } else {
        self.secondHidden = !sectionSwitch.on;
    }
    [self.humitureTableView reloadData];
}


@end

@interface GSHHumitureSenSorCell()

@end

@implementation GSHHumitureSenSorCell

-(void)awakeFromNib {
    [super awakeFromNib];
    
}

@end
