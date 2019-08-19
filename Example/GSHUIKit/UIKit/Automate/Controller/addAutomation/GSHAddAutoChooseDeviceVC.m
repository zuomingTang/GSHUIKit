//
//  GSHAddAutoChooseDeviceVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/6/4.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHAddAutoChooseDeviceVC.h"
#import "GSHDropDownMenuView.h"

@interface GSHAddAutoChooseDeviceVC ()

@property (nonatomic , strong) NSMutableArray *deviceArray;
@property (nonatomic , strong) NSArray *floorNameArray;

@end

@implementation GSHAddAutoChooseDeviceVC

+ (instancetype)addAutoChooseDeviceVC {
    GSHAddAutoChooseDeviceVC *vc = [TZMPageManager viewControllerWithSB:@"GSHAddAutomationSB" andID:@"GSHAddAutoChooseDeviceVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.floorNameArray = @[@"一楼", @"二楼", @"三楼", @"四楼", @"五楼"];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    [self initNavigationView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI
- (void)initNavigationView {
    
    GSHDropDownMenuView *menuView = [[GSHDropDownMenuView alloc] initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH, 44) titles:self.floorNameArray];
//    @weakify(self)
    menuView.selectedAtIndex = ^(int index) {
//        @strongify(self)
       
    };
    menuView.width = SCREEN_WIDTH;
    menuView.textColor = [UIColor blackColor];
    menuView.cellColor = [UIColor lightGrayColor];
    self.navigationItem.titleView = menuView;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(SCREEN_WIDTH - 44, 0, 44, 44);
    rightButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [rightButton setTitleColor:[UIColor colorWithHexString:@"#4C90F7"] forState:UIControlStateNormal];
    [rightButton setTitle:@"确定" forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(sureButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

#pragma mark - Lazy
- (NSMutableArray *)deviceArray {
    if (!_deviceArray) {
        _deviceArray = [NSMutableArray array];
        [_deviceArray addObjectsFromArray:@[@"顶灯",@"空调",@"窗帘",@"智能电视"]];
    }
    return _deviceArray;
}

#pragma mark - method
- (void)sureButtonClick:(UIButton *)button {
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.deviceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GSHAddAutoChooseDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addAutoChooseDeviceCell" forIndexPath:indexPath];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    cell.deviceNameLabel.text = self.deviceArray[indexPath.row];
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0f;
}

@end

@implementation GSHAddAutoChooseDeviceCell

@end
