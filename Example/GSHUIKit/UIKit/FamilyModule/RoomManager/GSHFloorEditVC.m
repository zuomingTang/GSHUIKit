//
//  GSHFloorEditVC.m
//  SmartHome
//
//  Created by gemdale on 2018/5/22.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHFloorEditVC.h"

@interface GSHFloorEditVC ()<UIPickerViewDelegate,UIPickerViewDataSource>
@property (strong, nonatomic)GSHFamilyM *family;
@property (strong, nonatomic)GSHFloorM *floor;

@property (strong, nonatomic)NSMutableArray *nameList;
@property (weak, nonatomic) IBOutlet UIView *viewSeleName;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerViewName;
- (IBAction)hideSeleNameView:(id)sender;
- (IBAction)seleName:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *tfName;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
- (IBAction)touchSave:(UIButton *)sender;
- (IBAction)seleFloorName:(id)sender;
@end

@implementation GSHFloorEditVC
+(instancetype)floorEditVCWithFamily:(GSHFamilyM*)family floor:(GSHFloorM*)floor{
    GSHFloorEditVC *vc = [TZMPageManager viewControllerWithSB:@"GSHRoomManagerSB" andID:@"GSHFloorEditVC"];
    vc.family = family;
    vc.floor = floor;
    return vc;
}

-(void)setFloor:(GSHFloorM *)floor{
    _floor = floor;
    if (floor) {
        self.tfName.text = floor.floorName;
    }else{
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.floor = self.floor;
    self.nameList = [NSMutableArray arrayWithArray:@[@"三楼",@"二楼",@"一楼",@"负一楼",@"负二楼",@"负三楼"]];
    for (GSHFloorM *floor in self.family.floor) {
        [self.nameList removeObject:floor.floorName];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchSave:(UIButton *)sender {
    NSString *floorName = self.tfName.text;
    __weak typeof(self)weakSelf = self;
    if (floorName.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入楼层名"];
        return;
    }
    if (self.floor) {
        [SVProgressHUD showWithStatus:@"更新中"];
        [GSHFloorManager postUpdateFloorWithFamilyId:weakSelf.family.familyId floorId:weakSelf.floor.floorId floorName:floorName block:^(NSError *error) {
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"修改成功"];
                weakSelf.floor.floorName = floorName;
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        }];
    }else{
        [SVProgressHUD showWithStatus:@"创建中"];
        [GSHFloorManager postAddFloorWithFamilyId:weakSelf.family.familyId floorName:floorName block:^(GSHFloorM *floor, NSError *error) {
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"创建成功"];
                if (floor) [weakSelf.family.floor addObject:floor];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
}

- (IBAction)seleFloorName:(id)sender {
    self.viewSeleName.hidden = NO;
}
- (IBAction)hideSeleNameView:(id)sender {
    self.viewSeleName.hidden = YES;
}

- (IBAction)seleName:(id)sender {
    self.viewSeleName.hidden = YES;
    NSInteger row = [self.pickerViewName selectedRowInComponent:0];
    if (self.nameList.count > row) {
        self.tfName.text = self.nameList[row];
    }
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.nameList.count;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (self.nameList.count > row) {
        return self.nameList[row];
    }
    return @"";
}
@end
