//
//  GSHDeviceCategoryListVC.m
//  SmartHome
//
//  Created by gemdale on 2018/6/4.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHDeviceCategoryListVC.h"
#import "GSHQRCodeScanningVC.h"
#import "GSHYingShiDeviceDetailVC.h"
#import "GSHDeviceCategoryGuideVC.h"
#import "GSHBlueRoundButton.h"
#import "GSHAddGWGuideVC.h"
#import "GSHYingShiDeviceTypeSeleVC.h"
#import "GSHDeviceInfoDefines.h"

@interface GSHDeviceCategoryListCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageViewIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblCategoryName;
@end

@implementation GSHDeviceCategoryListCell
-(void)setModel:(GSHDeviceCategoryM *)model{
    _model = model;
    self.lblCategoryName.text = model.deviceTypeStr;
//    [self.imageViewIcon sd_setImageWithURL:[NSURL URLWithString:model.picPath]];
    NSString *imageStr;
    if (model.deviceType.integerValue == 254 && model.deviceModel.integerValue < 0) {
        imageStr = [NSString stringWithFormat:@"deviceCategroy_off_icon_infrared_%d",-[model.deviceModel intValue]];
    }else{
        imageStr = [NSString stringWithFormat:@"deviceCategroy_off_icon-%d",[model.deviceType intValue]];
    }
    self.imageViewIcon.image = [UIImage imageNamed:imageStr];
}

-(void)setHighlighted:(BOOL)highlighted{
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithHexString:@"#f9f9f9"];
    }else{
        self.backgroundColor = [UIColor clearColor];
    }
}
@end

@interface GSHDeviceCategoryListVC () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lcViewTop;
@property (weak, nonatomic) IBOutlet UIButton *butNavScan;
- (IBAction)touchScan:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIView *viewError;
@property (weak, nonatomic) IBOutlet UILabel *lblError;
@property (weak, nonatomic) IBOutlet UIButton *btnSele;
@property (weak, nonatomic) IBOutlet GSHBlueRoundButton *btnScanAgain;
- (IBAction)touchScanAgain:(UIButton *)sender;
- (IBAction)touchSele:(UIButton *)sender;

@property(nonatomic,strong)NSMutableArray<GSHDeviceCategoryM*> *categoryList;
@property(nonatomic,strong)GSHDeviceCategoryM *seleCategory;
@end

@implementation GSHDeviceCategoryListVC

+(instancetype)deviceCategorylist{
    GSHDeviceCategoryListVC *vc = [TZMPageManager viewControllerWithSB:@"GSHAddDeviceSB" andID:@"GSHDeviceCategoryListVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.categoryList = [NSMutableArray array];
    self.butNavScan.hidden = YES;
    [self getDeviceTypes];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchScan:(UIButton *)sender {
    __weak typeof(self)weakSelf = self;
    self.seleCategory = nil;
    UINavigationController *nav = [GSHQRCodeScanningVC qrCodeScanningNavWithText:@"请扫描设备机身或说明书上的二维码添加设备" title:@"扫描设备二维码" block:^BOOL(NSString *code, GSHQRCodeScanningVC *vc) {
        [weakSelf scanQRCode:code];
        [weakSelf dismissViewControllerAnimated:NO completion:NULL];
        return NO;
    }];
    [self presentViewController:nav animated:YES completion:NULL];
}

- (void)scanQRCode:(NSString*)qrCode{
    if (qrCode.length > 0) {
        if ([qrCode rangeOfString:@"GD"].location != NSNotFound && qrCode.length > 15) {
            // 白名单所用二维码
            NSString *brandName = [qrCode substringWithRange:NSMakeRange(2, 2)];
            NSString *deviceType = [qrCode substringWithRange:NSMakeRange(5, 1)];
            NSString *deviceSubType = [qrCode substringWithRange:NSMakeRange(6, 1)];
            NSString *deviceSn = [qrCode substringFromIndex:15];
            if ([deviceType isEqualToString:@"1"]) {
                // 网关
                if (![GSHOpenSDK share].currentFamily) {
                    [SVProgressHUD showErrorWithStatus:@"请先添加家庭"];
                    return;
                }
                if ([GSHOpenSDK share].currentFamily.gatewayId.length > 0) {
                    // 有网关id
                    [SVProgressHUD showErrorWithStatus:@"家庭已添加网关"];
                    return;
                }
                [self.navigationController pushViewController:[GSHAddGWGuideVC addGWGuideVCWithFamily:[GSHOpenSDK share].currentFamily] animated:YES];
            } else {
                GSHDeviceCategoryM *deviceCategoryM = [self getCategoryWithBrandName:brandName deviceType:deviceType deviceSubType:deviceSubType];
                GSHDeviceCategoryGuideVC *vc = [GSHDeviceCategoryGuideVC deviceCategoryGuideVCWithGategory:deviceCategoryM deviceSn:deviceSn];
                [self.navigationController pushViewController:vc animated:YES];
            }
        } else {
            NSArray<NSString *> *items = [qrCode componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"]];
            if (items.count > 1) {
                if ([items[0] rangeOfString:@"ys7"].location != NSNotFound) {
                    [self pushYingShiWithQRCode:qrCode deviceCategoryM:nil];
                }
            } else {
                self.title = @"二维码扫描失败";
                self.viewError.hidden = NO;
                self.lblError.text = @"二维码信息错误，请扫描正确的二维码";
                return;
            }
        }
    } else {
        [SVProgressHUD showErrorWithStatus:@"无效二维码"];
    }
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger lineCount = self.categoryList.count / 3;
    lineCount = self.categoryList.count % 3 == 0 ? lineCount : lineCount + 1;
    return lineCount * 3;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    GSHDeviceCategoryListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if (self.categoryList.count > indexPath.row) {
        cell.model = self.categoryList[indexPath.row];
    } else {
        cell.model = nil;
    }
    return cell;
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.categoryList.count > indexPath.row) {
        __weak typeof(self)weakSelf = self;
        GSHDeviceCategoryM *deviceCategoryM = self.categoryList[indexPath.row];
        if (deviceCategoryM.deviceType.integerValue == 16 ||
            deviceCategoryM.deviceType.integerValue == 15) {
            self.seleCategory = deviceCategoryM;
            NSString *text;
            if (self.seleCategory.deviceType.integerValue == 16) {
                text = @"请扫描设备机身或说明书上的二维码添加设备";
            }else if (self.seleCategory.deviceType.integerValue == 15){
                text = @"请扫描设备“固件信息”或说明书上的二维码添加设备";
            }
            UINavigationController *nav = [GSHQRCodeScanningVC qrCodeScanningNavWithText:text title:@"扫描设备二维码" block:^BOOL(NSString *code, GSHQRCodeScanningVC *vc) {
                [weakSelf pushYingShiWithQRCode:code deviceCategoryM:weakSelf.seleCategory];
                [weakSelf dismissViewControllerAnimated:NO completion:NULL];
                return NO;
            }];
            [self presentViewController:nav animated:YES completion:NULL];
        } else if (deviceCategoryM.deviceType.integerValue == GateWayDeviceType) {
            // 添加网关
            if (![GSHOpenSDK share].currentFamily) {
                [SVProgressHUD showErrorWithStatus:@"请先添加家庭"];
                return NO;
            }
            if ([GSHOpenSDK share].currentFamily.gatewayId.length > 0) {
                // 有网关id
                [SVProgressHUD showErrorWithStatus:@"家庭已添加网关"];
                return NO;
            }
            [self.navigationController pushViewController:[GSHAddGWGuideVC addGWGuideVCWithFamily:[GSHOpenSDK share].currentFamily] animated:YES];
        } else {
            if ([GSHOpenSDK share].currentFamily.gatewayId.length == 0) {
                // 无网关id
                [SVProgressHUD showErrorWithStatus:@"暂不能添加该设备，请添加智能网关"];
                return NO;
            }
            GSHDeviceCategoryGuideVC *vc = [GSHDeviceCategoryGuideVC deviceCategoryGuideVCWithGategory:deviceCategoryM deviceSn:@""];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    return NO;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(collectionView.frame.size.width / 3, collectionView.frame.size.width / 3 / 125 * 135);
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < 100 || self.lcViewTop.constant > -90) {
        self.lcViewTop.constant = -scrollView.contentOffset.y;
        if (scrollView.contentOffset.y > -10) {
            CGFloat alpha = scrollView.contentOffset.y / 90.0;
            alpha = alpha > 0 ? alpha : 0;
            alpha = alpha > 1 ? 1 : alpha;
            self.butNavScan.alpha = alpha;
            self.butNavScan.hidden = alpha < 0.01;
        }
    }
}

#pragma mark - request
- (void)getDeviceTypes {
    [SVProgressHUD showWithStatus:@"获取设备品类中"];
    [GSHDeviceManager getDeviceTypesWithBlock:^(NSArray<GSHDeviceCategoryM *> *list, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        } else {
            [SVProgressHUD dismiss];
            [self.categoryList addObjectsFromArray:[self handleSourceArrayWithArray:list]];
            [self.collectionView reloadData];
        }
    }];
    
}

- (NSArray *)handleSourceArrayWithArray:(NSArray *)array {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSMutableArray *arr = [NSMutableArray array];
    for (GSHDeviceCategoryM *deviceCategoryM in array) {
        if (deviceCategoryM && ![dic objectForKey:deviceCategoryM.deviceType]) {
            [dic setObject:@"haha" forKey:deviceCategoryM.deviceType];
            [arr addObject:deviceCategoryM];
        }
    }
    return (NSArray *)arr;
}

- (IBAction)touchScanAgain:(UIButton *)sender {
    self.viewError.hidden = YES;
    self.title = @"添加设备";
    if (self.seleCategory) {
        NSString *text;
        if (self.seleCategory.deviceType.integerValue == 16) {
            text = @"请扫描设备机身或说明书上的二维码添加设备";
        }else if (self.seleCategory.deviceType.integerValue == 15){
            text = @"请扫描设备“固件信息”或说明书上的二维码添加设备";
        }
        __weak typeof(self)weakSelf = self;
        UINavigationController *nav = [GSHQRCodeScanningVC qrCodeScanningNavWithText:text title:@"扫描设备二维码" block:^BOOL(NSString *code, GSHQRCodeScanningVC *vc) {
            [weakSelf pushYingShiWithQRCode:code deviceCategoryM:weakSelf.seleCategory];
            [weakSelf dismissViewControllerAnimated:NO completion:NULL];
            return NO;
        }];
        [self presentViewController:nav animated:YES completion:NULL];
    }else{
        [self touchScan:nil];
    }
}

- (IBAction)touchSele:(UIButton *)sender {
    self.viewError.hidden = YES;
    self.title = @"添加设备";
}

- (void)pushYingShiWithQRCode:(NSString*)qrCode deviceCategoryM:(GSHDeviceCategoryM*)deviceCategoryM{
    //这个是萤石设备
    NSString *errorString;
    GSHDeviceM *deviceM = [GSHDeviceM new];
    NSArray<NSString *> *items = [qrCode componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"]];;
    if (items.count > 1) {
        deviceM.deviceSn = items[1];
    }
    if (items.count > 2) {
        deviceM.validateCode = items[2];
    }
    if (items.count > 3) {
        NSString *item3 = items[3];
        if (deviceCategoryM) {
            deviceM.deviceModelStr = item3;
            deviceM.deviceModel = deviceCategoryM.deviceModel;
            deviceM.deviceType = deviceCategoryM.deviceType;
            deviceM.deviceTypeStr = deviceCategoryM.deviceTypeStr;
            GSHYingShiDeviceDetailVC *vc = [GSHYingShiDeviceDetailVC yingShiDeviceDetailVCWithDevice:deviceM modelName:deviceCategoryM.deviceModelStr];
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }else{
            deviceM.deviceModelStr = item3;
            GSHYingShiDeviceTypeSeleVC *vc = [GSHYingShiDeviceTypeSeleVC yingShiDeviceDetailVCWithDevice:deviceM];
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }
    }else{
        errorString = @"二维码信息错误，请扫描正确的二维码";
    }
    
    if(errorString.length > 0){
        self.title = @"二维码扫描失败";
        self.viewError.hidden = NO;
        self.lblError.text = errorString;
        if (deviceCategoryM.deviceTypeStr.length > 0) {
            self.btnSele.hidden = YES;
            [self.btnScanAgain setTitle:@"重新扫描" forState:UIControlStateNormal];
        }else{
            [self.btnScanAgain setTitle:@"重试" forState:UIControlStateNormal];
            self.btnSele.hidden = NO;
        }
    }
}

#pragma mark -

// 根据二维码扫描截取出来的d设备类型决定设备品类图片
- (GSHDeviceCategoryM *)getCategoryWithBrandName:(NSString *)brandName deviceType:(NSString *)deviceType deviceSubType:(NSString *)deviceSubType {
    
    GSHDeviceCategoryM *deviceCategoryM = [[GSHDeviceCategoryM alloc] init];
    if ([brandName isEqualToString:@"HY"]) {
        // 鸿雁
        if (deviceType.integerValue == 2) {
            // 开关
            if (deviceSubType.integerValue == 1) {
                // 一路开关
                deviceCategoryM.deviceTypeStr = @"一路智能开关";
                deviceCategoryM.deviceType = @(0);
            } else if (deviceSubType.integerValue == 2) {
                // 二路开关
                deviceCategoryM.deviceTypeStr = @"二路智能开关";
                deviceCategoryM.deviceType = @(1);
            } else if (deviceSubType.integerValue == 3) {
                // 三路开关
                deviceCategoryM.deviceTypeStr = @"三路智能开关";
                deviceCategoryM.deviceType = @(2);
            }
        } else if (deviceType.integerValue == 4) {
            // 环境电器
            if (deviceSubType.integerValue == 2) {
                // 新风面板
                deviceCategoryM.deviceTypeStr = @"新风面板";
                deviceCategoryM.deviceType = @(7);
            } else if (deviceSubType.integerValue == 3) {
                // 空调
                deviceCategoryM.deviceTypeStr = @"空调";
                deviceCategoryM.deviceType = @(768);
            } else if (deviceSubType.integerValue == 6) {
                // 地暖
                deviceCategoryM.deviceTypeStr = @"地暖面板";
                deviceCategoryM.deviceType = @(518);
            }
        } else if (deviceType.integerValue == 5) {
            // 生活电器
            if (deviceSubType.integerValue == 3) {
                // 插座
                deviceCategoryM.deviceTypeStr = @"插座";
                deviceCategoryM.deviceType = @(81);
            }
        } else if (deviceType.integerValue == 6) {
            // 红外设备
            if (deviceSubType.integerValue == 3) {
                // 红外遥控
                deviceCategoryM.deviceTypeStr = @"红外转发器";
                deviceCategoryM.deviceType = @(254);
            }
        } else if (deviceType.integerValue == 7) {
            // 窗帘
            if (deviceSubType.integerValue == 1) {
                // 一路窗帘开关
                deviceCategoryM.deviceTypeStr = @"一路窗帘开关";
                deviceCategoryM.deviceType = @(519);
            } else if (deviceSubType.integerValue == 2) {
                // 二路窗帘开关
                deviceCategoryM.deviceTypeStr = @"双路窗帘";
                deviceCategoryM.deviceType = @(517);
            }
        } else if (deviceType.integerValue == 8) {
            // 场景面板
            if (deviceSubType.integerValue == 1) {
                // 场景开关六路
                deviceCategoryM.deviceTypeStr = @"场景面板";
                deviceCategoryM.deviceType = @(12);
            }
        } else if (deviceType.integerValue == 9) {
            // 家居安防
            if (deviceSubType.integerValue == 3) {
                // 红外幕帘
                deviceCategoryM.deviceTypeStr = @"红外幕帘";
                deviceCategoryM.deviceType = @(47);
            }
        } else if ([deviceType isEqualToString:@"A"]) {
            // 传感器
            if (deviceSubType.integerValue == 4) {
                // 红外人体感应面板
                deviceCategoryM.deviceTypeStr = @"红外人体感应面板";
                deviceCategoryM.deviceType = @(49);
            } else if (deviceSubType.integerValue == 8) {
                // 空气盒子
                deviceCategoryM.deviceTypeStr = @"空气盒子";
                deviceCategoryM.deviceType = @(45);
            }
        } else if ([deviceType isEqualToString:@"B"]) {
            // 辅助设备
            if (deviceSubType.integerValue == 2) {
                // 空调转换器
                deviceCategoryM.deviceTypeStr = @"空调转换器";
                deviceCategoryM.deviceType = @(17476);
            }
        }
    } else if ([brandName isEqualToString:@"HM"]) {
        // 海曼
        if (deviceType.integerValue == 9) {
            // 家居安防
            if (deviceSubType.integerValue == 4) {
                // 紧急按钮sos
                deviceCategoryM.deviceTypeStr = @"紧急按钮SOS";
                deviceCategoryM.deviceType = @(277);
            } else if (deviceSubType.integerValue == 5) {
                // 声光报警器
                deviceCategoryM.deviceTypeStr = @"声光报警";
                deviceCategoryM.deviceType = @(1201);
            }
        } else if ([deviceType isEqualToString:@"A"]) {
            // 传感器
            if (deviceSubType.integerValue == 1) {
                // 水浸传感器
                deviceCategoryM.deviceTypeStr = @"水浸传感器";
                deviceCategoryM.deviceType = @(42);
            } else if (deviceSubType.integerValue == 2 ||
                       deviceSubType.integerValue == 3 ||
                       deviceSubType.integerValue == 6) {
                // 气体传感器
                deviceCategoryM.deviceTypeStr = @"气体传感器";
                deviceCategoryM.deviceType = @(40);
            } else if (deviceSubType.integerValue == 4) {
                // 红外人体传感器
                deviceCategoryM.deviceTypeStr = @"红外人体传感器";
                deviceCategoryM.deviceType = @(263);
            } else if (deviceSubType.integerValue == 5) {
                // 门磁传感器
                deviceCategoryM.deviceTypeStr = @"门磁传感器";
                deviceCategoryM.deviceType = @(21);
            } else if (deviceSubType.integerValue == 7) {
                // 温湿度传感器
                deviceCategoryM.deviceTypeStr = @"温湿度传感器";
                deviceCategoryM.deviceType = @(770);
            }
        }
    } else if ([brandName isEqualToString:@"HN"]) {
        // 豪恩
        if ([deviceType isEqualToString:@"B"]) {
            // 辅助设备
            if (deviceSubType.integerValue == 3) {
                // 声光报警器
                deviceCategoryM.deviceTypeStr = @"声光报警器";
                deviceCategoryM.deviceType = @(1201);
            }
        }
    } else if ([brandName isEqualToString:@"EL"]) {
        // 智慧享联
        if ([deviceType isEqualToString:@"B"]) {
            // 辅助设备
            if (deviceSubType.integerValue == 1) {
                // 组合传感器
                deviceCategoryM.deviceTypeStr = @"组合传感器";
                deviceCategoryM.deviceType = @(46);
            }
        }
    } else if ([brandName isEqualToString:@"DY"]) {
        //
        if (deviceType.integerValue == 7) {
            // 窗帘
            if (deviceSubType.integerValue == 3) {
                // 开合窗帘电机
                deviceCategoryM.deviceTypeStr = @"开合窗帘电机";
                deviceCategoryM.deviceType = @(515);
            }
        }
    }
    return deviceCategoryM;
}

@end
