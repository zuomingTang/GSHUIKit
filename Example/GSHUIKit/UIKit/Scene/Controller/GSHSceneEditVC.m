//
//  GSHSceneEditVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/7/17.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHSceneEditVC.h"
#import "GSHAddSceneVC.h"

#import "GSHSceneCell.h"
#import "GSHAlertManager.h"

#import "UINavigationController+TZM.h"

@interface GSHSceneEditVC () <UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic , strong) UICollectionView *sceneEditCollectionView;
@property (nonatomic , strong) UICollectionViewFlowLayout *sceneEditFlowLayout;

@property (nonatomic , strong) UIButton *completeButton;
@property (nonatomic , strong) UIBarButtonItem *completeBarButtonItem;
@property (nonatomic , assign) BOOL isAlerted;

@property (nonatomic , strong) GSHSceneM *tmpSceneM;

@end

@implementation GSHSceneEditVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.sourceArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"编辑场景";
    
    [self.sceneEditCollectionView setBackgroundColor:[UIColor colorWithHexString:@"#F6F7FA"]];
    
    [self createNavigationButton]; // 创建 完成 按钮
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldHoldBackButtonEvent {
    return YES;
}

- (BOOL)canPopViewController {
    if (self.isAlerted) {
        [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
            if (buttonIndex == 1) {
                [self sortSceneListRequest];
            } else {
                [self.navigationController popViewControllerAnimated:NO];
            }
        } textFieldsSetupHandler:NULL andTitle:nil andMessage:@"是否保存已作的修改?" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"不保存" otherButtonTitles:@"保存",nil];
    } else {
        if (self.sceneEditCompleteBlock) {
            self.sceneEditCompleteBlock(self.sourceArray);
        }
        [self.navigationController popViewControllerAnimated:NO];
    }
    return NO;
}

#pragma mark - UI
- (void)createNavigationButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(completeButtonClick:)];
}

#pragma mark - Lazy

- (UICollectionViewFlowLayout *)sceneEditFlowLayout {
    if (!_sceneEditFlowLayout) {
        _sceneEditFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        _sceneEditFlowLayout.minimumInteritemSpacing = 5; //cell左右间隔
        _sceneEditFlowLayout.minimumLineSpacing = 5;      //cell上下间隔
        _sceneEditFlowLayout.sectionInset = UIEdgeInsetsMake(5, 15, 10, 10);
        _sceneEditFlowLayout.itemSize = CGSizeMake((SCREEN_WIDTH - 30) / 2 ,(SCREEN_WIDTH - 30) / 2);
        [_sceneEditFlowLayout setHeaderReferenceSize:CGSizeMake(SCREEN_WIDTH, 40)];
    }
    return _sceneEditFlowLayout;
}

- (UICollectionView *)sceneEditCollectionView {
    if (!_sceneEditCollectionView) {
        _sceneEditCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - KTabBarHeight - KNavigationBar_Height) collectionViewLayout:self.sceneEditFlowLayout];
        _sceneEditCollectionView.dataSource = self;
        _sceneEditCollectionView.delegate = self;
        [_sceneEditCollectionView registerNib:[UINib nibWithNibName:@"GSHSceneCell" bundle:nil] forCellWithReuseIdentifier:@"sceneCell"];
        [_sceneEditCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headView"];
        [self.view addSubview:_sceneEditCollectionView];
        
        //此处给其增加长按手势，用此手势触发cell移动效果
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlelongGesture:)];
        [_sceneEditCollectionView addGestureRecognizer:longGesture];
        
    }
    return _sceneEditCollectionView;
}

- (GSHSceneM *)tmpSceneM {
    if (!_tmpSceneM) {
        _tmpSceneM = [[GSHSceneM alloc] init];
    }
    return _tmpSceneM;
}

#pragma mark - method
// 排序操作或删除操作之后，重新按顺序修改rank值
- (void)alertRankAfterHandleScene {
    for (int i = 0; i < self.sourceArray.count ; i ++) {
        GSHOssSceneM *ossSceneM = self.sourceArray[i];
        int rank = (int)self.sourceArray.count - 1 - i;
        ossSceneM.rank = @(rank);
    }
}

- (void)completeButtonClick:(UIButton *)button {
    if (self.sourceArray.count == 0) {
        [self.navigationController popViewControllerAnimated:NO];
    } else {
        [self sortSceneListRequest];
    }
}

- (void)handlelongGesture:(UILongPressGestureRecognizer *)longGesture {
    //判断手势状态
    switch (longGesture.state) {
        case UIGestureRecognizerStateBegan:{
            //判断手势落点位置是否在路径上
            NSIndexPath *indexPath = [self.sceneEditCollectionView indexPathForItemAtPoint:[longGesture locationInView:self.sceneEditCollectionView]];
            if (indexPath == nil) {
                break;
            }
            //在路径上则开始移动该路径上的cell
            if (@available(iOS 9.0, *)) {
                [self.sceneEditCollectionView beginInteractiveMovementForItemAtIndexPath:indexPath];
            } else {
                // Fallback on earlier versions
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
            //移动过程当中随时更新cell位置
            if (@available(iOS 9.0, *)) {
                [self.sceneEditCollectionView updateInteractiveMovementTargetPosition:[longGesture locationInView:self.sceneEditCollectionView]];
            } else {
                // Fallback on earlier versions
            }
            break;
        case UIGestureRecognizerStateEnded:
            //移动结束后关闭cell移动
            if (@available(iOS 9.0, *)) {
                [self.sceneEditCollectionView endInteractiveMovement];
            } else {
                // Fallback on earlier versions
            }
            break;
        default:
            if (@available(iOS 9.0, *)) {
                [self.sceneEditCollectionView cancelInteractiveMovement];
            } else {
                // Fallback on earlier versions
            }
            break;
    }
}

- (void)startShakeWithCell:(GSHSceneCell *)cell {
    CAKeyframeAnimation * keyAnimaion = [CAKeyframeAnimation animation];
    keyAnimaion.keyPath = @"transform.rotation";
    keyAnimaion.values = @[@(-3 / 180.0 * M_PI),@(3 /180.0 * M_PI),@(-3/ 180.0 * M_PI)];//度数转弧度
    keyAnimaion.removedOnCompletion = NO;
    keyAnimaion.fillMode = kCAFillModeForwards;
    keyAnimaion.duration = 0.3;
    keyAnimaion.repeatCount = MAXFLOAT;
    [cell.layer addAnimation:keyAnimaion forKey:@"cellShake"];
}

- (void)stopShakeWithCell:(GSHSceneCell*)cell{
    [cell.layer removeAnimationForKey:@"cellShake"];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.sourceArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GSHSceneCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"sceneCell" forIndexPath:indexPath];
    GSHOssSceneM *ossSceneM = self.sourceArray[indexPath.row];
    cell.sceneNameLabel.text = ossSceneM.scenarioName;
    NSString *roomStr = @"";
    if (ossSceneM.roomName && ossSceneM.roomName.length > 0) {
        roomStr = [NSString stringWithFormat:@"%@%@",ossSceneM.floorName,ossSceneM.roomName?ossSceneM.roomName:@""];
    }
    cell.roomLabel.text = roomStr;
    cell.sceneImageView.image = [GSHSceneM getSceneListBackgroundImageWithId:[ossSceneM.backgroundId intValue]];
    cell.deleteButton.hidden = NO;
    @weakify(self)
    __weak typeof(ossSceneM) weakOssSceneM = ossSceneM;
    cell.deleteButtonClickBlock = ^{
        __strong typeof(weakOssSceneM) strongOssSceneM = weakOssSceneM;
        @strongify(self)
        [self removeSceneWithIndexPath:indexPath ossSceneM:strongOssSceneM];
    };
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headView" forIndexPath:indexPath];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, SCREEN_WIDTH, 20)];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor colorWithHexString:@"#585858"];
    label.text = @"点击进行场景编辑，拖动可进行排序";
    [reusableview addSubview:label];
    return reusableview;
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath{
    //返回YES允许其item移动
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath {
    //取出源item数据
    id objc = [self.sourceArray objectAtIndex:sourceIndexPath.item];
    //从资源数组中移除该数据
    [self.sourceArray removeObject:objc];
    //将数据插入到资源数组中的目标位置上
    [self.sourceArray insertObject:objc atIndex:destinationIndexPath.item];
    
    self.isAlerted = YES;
    [self alertRankAfterHandleScene];   // 重新排序rank的值
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.sourceArray.count > indexPath.row) {
        // 编辑模式下 -- 进入编辑页面
        GSHOssSceneM *ossSceneM = self.sourceArray[indexPath.row];
        [self enterEditDeviceVCWithOssSceneM:ossSceneM indexPath:indexPath];
        
    }
}

#pragma mark - request
// 情景列表排序
- (void)sortSceneListRequest {
    
    NSMutableArray *scenariosArray = [NSMutableArray array];
    for (int i = 0; i < self.sourceArray.count; i ++) {
        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
        GSHOssSceneM *ossSceneM = self.sourceArray[i];
        [tmpDic setObject:ossSceneM.scenarioId ? ossSceneM.scenarioId : @"" forKey:@"id"];
        [tmpDic setObject:ossSceneM.rank ? ossSceneM.rank : @"" forKey:@"rank"];
        [scenariosArray addObject:tmpDic];
    }
    [SVProgressHUD showWithStatus:@"请求中"];
    @weakify(self)
    [GSHSceneManager sortSceneWithFamilyId:[GSHOpenSDK share].currentFamily.familyId rankArray:scenariosArray block:^(NSError *error) {
        @strongify(self)
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        } else {
            [SVProgressHUD dismiss];
            if (self.sceneEditCompleteBlock) {
                self.sceneEditCompleteBlock(self.sourceArray);
            }
            [self.navigationController popViewControllerAnimated:NO];
        }
    }];
}

// 删除情景模式
- (void)removeSceneWithIndexPath:(NSIndexPath *)indexPath ossSceneM:(GSHOssSceneM *)ossSceneM {
    @weakify(self)
    __weak typeof(ossSceneM) weakOssSceneM = ossSceneM;
    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
        if (buttonIndex == 0) {
            @strongify(self)
            __strong typeof(weakOssSceneM) strongOssSceneM = weakOssSceneM;
            [self deleteSceneWithIndexPath:indexPath ossSceneM:strongOssSceneM];
        }
    } textFieldsSetupHandler:NULL andTitle:nil andMessage:@"确认要删除该情景吗？" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:@"删除" cancelButtonTitle:@"取消" otherButtonTitles:nil];
    
}

- (void)deleteSceneWithIndexPath:(NSIndexPath *)indexPath ossSceneM:(GSHOssSceneM *)ossSceneM {
    
    [SVProgressHUD showWithStatus:@"删除中"];
    @weakify(self)
    [GSHSceneManager deleteSceneWithOssSceneM:ossSceneM familyId:ossSceneM.familyId.stringValue block:^(NSError *error) {
        @strongify(self)
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        } else {
            [SVProgressHUD showSuccessWithStatus:@"删除成功"];
            if (self.sourceArray.count > indexPath.row) {
                [self.sourceArray removeObjectAtIndex:indexPath.row];
            }
            [self.sceneEditCollectionView reloadData];
            [self alertRankAfterHandleScene];   // 重新排序rank的值
            if (self.deleteSuccessBlock) {
                self.deleteSuccessBlock(ossSceneM);
            }
        }
    }];
}

- (void)enterEditDeviceVCWithOssSceneM:(GSHOssSceneM *)ossSceneM indexPath:(NSIndexPath *)indexPath {
    
    NSString *json = [[GSHFileManager shared] readDataWithFileType:LocalStoreFileTypeScene fileName:ossSceneM.fid];
    if (json) {
        // 本地有文件
        NSString *md5 = [json md5String];
        if (![md5 isEqualToString:ossSceneM.md5]) {
            [self getFileFromSeverWithFid:ossSceneM.fid ossSceneM:ossSceneM indexPath:indexPath];
        } else {
            [self editWithJson:json ossSceneM:ossSceneM indexPath:indexPath];
        }
    } else {
        // 本地无文件 ， 从oss服务器获取文件
        [self getFileFromSeverWithFid:ossSceneM.fid ossSceneM:ossSceneM indexPath:indexPath];
    }
    
}

- (void)editWithJson:(NSString *)json ossSceneM:(GSHOssSceneM *)ossSceneM indexPath:(NSIndexPath *)indexPath {
    self.tmpSceneM = [GSHSceneM yy_modelWithJSON:json];
    self.tmpSceneM.scenarioId = ossSceneM.scenarioId;
    self.tmpSceneM.roomName = ossSceneM.roomName;
    self.tmpSceneM.floorName = ossSceneM.floorName;
    
    NSMutableArray *deviceIdArr = [NSMutableArray array];
    for (GSHDeviceM *deviceM in self.tmpSceneM.devices) {
        [deviceIdArr addObject:deviceM.deviceId];
    }
    @weakify(self)
    __weak typeof(ossSceneM) weakOssSceneM = ossSceneM;
    [SVProgressHUD showWithStatus:@"数据校验中"];
    [GSHSceneManager checkDevicesFromServerWithDeviceIdArray:deviceIdArr sceneArray:nil autoArray:nil familyId:[GSHOpenSDK share].currentFamily.familyId block:^(NSArray<GSHNameIdM*> *arr, NSError *error) {
        @strongify(self)
        __strong typeof(weakOssSceneM) strongOssSceneM = weakOssSceneM;
        [SVProgressHUD dismiss];
        if (!error) {
            NSMutableArray *tmpArr = [NSMutableArray array];
            BOOL isAlert = NO;
            for (GSHDeviceM *sceneDeviceM in self.tmpSceneM.devices) {
                BOOL isIn = NO ;
                for (GSHNameIdM *tmpNameIdM in arr) {
                    if ([sceneDeviceM.deviceId isEqual:tmpNameIdM.idStr]) {
                        isIn = YES;
                        if (![sceneDeviceM.deviceName isEqualToString:tmpNameIdM.nameStr]) {
                            sceneDeviceM.deviceName = tmpNameIdM.nameStr;
                            isAlert = YES;
                        }
                    }
                }
                if (!isIn) {
                    [tmpArr addObject:sceneDeviceM];
                }
            }
            if (tmpArr.count > 0) {
                isAlert = YES;
                [self.tmpSceneM.devices removeObjectsInArray:tmpArr];
            }
            [self jumpToSceneEditVCWithOssSceneM:strongOssSceneM sceneM:self.tmpSceneM indexPath:indexPath isAlert:isAlert];
            
        } else {
            [self jumpToSceneEditVCWithOssSceneM:strongOssSceneM sceneM:self.tmpSceneM indexPath:indexPath isAlert:NO];
        }
    }];
}

- (void)jumpToSceneEditVCWithOssSceneM:(GSHOssSceneM *)ossSceneM sceneM:(GSHSceneM *)sceneM indexPath:(NSIndexPath *)indexPath isAlert:(BOOL)isAlert {
    GSHAddSceneVC *addSceneVC = [[GSHAddSceneVC alloc] init];
    addSceneVC.hidesBottomBarWhenPushed = YES;
    addSceneVC.sceneM = sceneM;
    addSceneVC.ossSceneM = ossSceneM;
    addSceneVC.isAlertToNotiUser = isAlert;
    addSceneVC.largestRank = [NSString stringWithFormat:@"%@",ossSceneM.rank];
    @weakify(self)
    addSceneVC.updateSceneBlock = ^(GSHOssSceneM *ossSceneM) {
        @strongify(self)
        if (self.sourceArray.count > indexPath.row) {
            [self.sourceArray removeObjectAtIndex:indexPath.row];
        }
        [self.sourceArray insertObject:ossSceneM atIndex:indexPath.row];
        [self.sceneEditCollectionView reloadData];
    };
    [self.navigationController pushViewController:addSceneVC animated:YES];
}

- (void)getFileFromSeverWithFid:(NSString *)fid
                      ossSceneM:(GSHOssSceneM *)ossSceneM
                      indexPath:(NSIndexPath *)indexPath {
    
    if (fid.length == 0) {
        return;
    }
    [SVProgressHUD showWithStatus:@"数据获取中"];
    [GSHSceneManager getSceneFileFromOssWithFid:fid block:^(NSString *json, NSError *error) {
        if (error) {
            if (error.code == 404) {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"找不到%@文件",fid]];
            } else {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }
        } else {
            [SVProgressHUD dismiss];
            [self editWithJson:json ossSceneM:ossSceneM indexPath:indexPath];
        }
    }];
}


@end
