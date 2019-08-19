//
//  GSHSceneModelBackVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/5/17.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHSceneBackgroundVC.h"
#import "GSHSceneBackCell.h"

@interface GSHSceneBackgroundVC () <UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic , strong) UICollectionView *sceneBackCollectionView;
@property (nonatomic , strong) UICollectionViewFlowLayout *sceneBackFlowLayout;
@property (nonatomic , strong) NSMutableArray *imageArray;
@property (nonatomic , assign) int backImgIndex;

@end

@implementation GSHSceneBackgroundVC

- (instancetype)initWithBackImgId:(int)backImgIndex;
{
    self = [super init];
    if (self) {
        self.backImgIndex = backImgIndex;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.backImgIndex = 100 ;
    
    self.navigationItem.title = @"选择场景背景";
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"#F6F7FA"];
    
    [self.sceneBackCollectionView setBackgroundColor:[UIColor whiteColor]];
    
    [self createRightButton]; // 创建 添加场景 按钮
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI
- (void)createRightButton {
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
- (NSMutableArray *)imageArray {
    if (!_imageArray) {
        _imageArray = [NSMutableArray array];
        for (int i = 1; i < 17; i ++) {
            NSString *imageNameStr = [NSString stringWithFormat:@"sence_pic_bg_%d_little",i];
            [_imageArray addObject:imageNameStr];
        }
    }
    return _imageArray;
}

- (UICollectionViewFlowLayout *)sceneBackFlowLayout {
    if (!_sceneBackFlowLayout) {
        _sceneBackFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        _sceneBackFlowLayout.minimumInteritemSpacing = 10; //cell左右间隔
        _sceneBackFlowLayout.minimumLineSpacing = 10;      //cell上下间隔
        _sceneBackFlowLayout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
        _sceneBackFlowLayout.itemSize = CGSizeMake((SCREEN_WIDTH - 40) / 2 ,(SCREEN_WIDTH - 40) / 2 / 167.5 * 84);
    }
    return _sceneBackFlowLayout;
}

- (UICollectionView *)sceneBackCollectionView {
    if (!_sceneBackCollectionView) {
        _sceneBackCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - KTabBarHeight) collectionViewLayout:self.sceneBackFlowLayout];
        _sceneBackCollectionView.dataSource = self;
        _sceneBackCollectionView.delegate = self;
        [_sceneBackCollectionView registerNib:[UINib nibWithNibName:@"GSHSceneBackCell" bundle:nil] forCellWithReuseIdentifier:@"sceneBackCell"];
        [self.view addSubview:_sceneBackCollectionView];
    }
    return _sceneBackCollectionView;
}

#pragma mark - method
// 添加场景按钮点击
- (void)sureButtonClick:(UIButton *)button {
    if (self.backImgIndex == 100) {
        [SVProgressHUD showInfoWithStatus:@"请选择背景图片"];
        return;
    }
    if (self.selectBackImage) {
        self.selectBackImage(self.backImgIndex);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GSHSceneBackCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"sceneBackCell" forIndexPath:indexPath];
    cell.sceneBackImageView.image = [GSHSceneM getSceneBackgroundImageWithId:(int)indexPath.row];
    cell.checkBoxImageView.hidden = (self.backImgIndex == indexPath.row) ? NO : YES;
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    for (int i = 0 ; i < 17 ; i ++) {
        GSHSceneBackCell *tmpCell = (GSHSceneBackCell *)[self.sceneBackCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        tmpCell.checkBoxImageView.hidden = YES;
    }
    GSHSceneBackCell *cell = (GSHSceneBackCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.checkBoxImageView.hidden = NO;
    self.backImgIndex = (int)indexPath.row;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    GSHSceneBackCell *cell = (GSHSceneBackCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.checkBoxImageView.hidden = YES;
}


@end
