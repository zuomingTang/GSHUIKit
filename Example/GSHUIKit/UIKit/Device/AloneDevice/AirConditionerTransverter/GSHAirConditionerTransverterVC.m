//
//  GSHAirConditionerTransverterVC.m
//  SmartHome
//
//  Created by zhanghong on 2019/5/8.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHAirConditionerTransverterVC.h"
#import "GSHAirConditionerTransverterEditVC.h"

@interface GSHAirConditionerTransverterVCCell()

@property (weak, nonatomic) IBOutlet UIView *unBindView;
@property (weak, nonatomic) IBOutlet UIView *bindedView;

@property(nonatomic, strong) GSHDeviceM *deviceM;

@end

@implementation GSHAirConditionerTransverterVCCell

- (void)setDeviceM:(GSHDeviceM *)deviceM {
    if (deviceM.deviceType.intValue == -2) {
        self.unBindView.hidden = YES;
        self.bindedView.hidden = NO;
    } else {
        self.unBindView.hidden = NO;
        self.bindedView.hidden = YES;
    }
}

@end

@interface GSHAirConditionerTransverterVC () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *airConditionerTranCollectionView;

@property (nonatomic,strong) GSHDeviceM *deviceM;

@end

@implementation GSHAirConditionerTransverterVC

+ (instancetype)airConditionerTransverterVCWithDeviceM:(GSHDeviceM *)deviceM {
    GSHAirConditionerTransverterVC *vc = [TZMPageManager viewControllerWithSB:@"GSHAirConditionerTransverterSB" andID:@"GSHAirConditionerTransverterVC"];
    vc.deviceM = deviceM;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.airConditionerTranCollectionView reloadData];
}

#pragma mark - method

- (IBAction)enterDeviceButtonClick:(id)sender {
    [self.navigationController pushViewController:[GSHAirConditionerTransverterEditVC airConditionerTransverterEditVCWithDeviceM:self.deviceM] animated:YES];
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    GSHAirConditionerTransverterVCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"airConditionerCell" forIndexPath:indexPath];
    GSHDeviceM *deviceM = [[GSHDeviceM alloc] init];
    deviceM.deviceType = @(1);
    cell.deviceM = deviceM;
    cell.itemNameLabel.text = [NSString stringWithFormat:@"%d",(int)(indexPath.row+1)];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 8;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((collectionView.frame.size.width - 16 * 3) / 2, (collectionView.frame.size.width - 16 * 3) / 2 / 164 * 240);
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}



@end
