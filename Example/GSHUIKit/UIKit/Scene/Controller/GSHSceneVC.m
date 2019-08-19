//
//  GSHSceneVC.m
//  SmartHome
//
//  Created by gemdale on 2018/4/8.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHSceneVC.h"
#import "GSHSceneCell.h"
#import "GSHAddSceneVC.h"
#import "GSHSceneEditVC.h"

#import <MJRefresh.h>

#import "UIViewController+TZMPageStatusViewEx.h"
#import "UIView+TZMPageStatusViewEx.h"
#import "PopoverView.h"
#import "MJRefresh.h"
#import "NSObject+TZM.h"

@interface GSHSceneVC () <UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic , strong) UICollectionView *sceneCollectionView;
@property (nonatomic , strong) UICollectionViewFlowLayout *sceneFlowLayout;
@property (nonatomic , strong) NSMutableArray *sourceArray;
@property (nonatomic , strong) UIButton *editButton;
@property (nonatomic , strong) UIButton *addButton;
@property (nonatomic , strong) UIBarButtonItem *editBarButtonItem;
@property (nonatomic , strong) UIBarButtonItem *addBarButtonItem;
@property (nonatomic , strong) NSMutableArray *actions;
@property (nonatomic , assign) int currPage;

@end

@implementation GSHSceneVC

#pragma mark - life circle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.sceneCollectionView setBackgroundColor:[UIColor colorWithHexString:@"#F6F7FA"]];
    
    [self createNavigationButton]; // 创建 添加场景 按钮
    
    self.currPage = 1;
    [self querySceneModeListWithFamilyId:[GSHOpenSDK share].currentFamily.familyId currPage:self.currPage];  // 查询 情景模式列表
    
    [self observerNotifications];

}

-(void)observerNotifications{
    [self observerNotification:GSHOpenSDKFamilyChangeNotification];
}

-(void)handleNotifications:(NSNotification *)notification{
    if ([notification.name isEqualToString:GSHOpenSDKFamilyChangeNotification]) {
        GSHFamilyM *family = notification.object;
        if ([family isKindOfClass:GSHFamilyM.class]) {
            [self querySceneModeListWithFamilyId:family.familyId currPage:1];
        }
    } 
}

-(void)dealloc{
    [self removeNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI
- (void)createNavigationButton {
    // 编辑    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:self action:@selector(editButtonClick:)];
    [self.navigationItem.leftBarButtonItem setImage:[UIImage imageNamed:@"scene_icon_redact"]];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor blackColor];
    // 添加
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:self action:@selector(addSceneButtonClick:)];
    [self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:@"sense_icon_add_normal"]];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
    
}

#pragma mark - Lazy
- (NSMutableArray *)actions {
    if (!_actions) {
        _actions = [NSMutableArray array];
        NSArray *autoTypeArray = @[@"普通场景",@"房间场景"];
        for (NSString *autoTypeName in autoTypeArray) {
            PopoverAction *action = [PopoverAction actionWithImageUrl:nil title:autoTypeName handler:^(PopoverAction *action) {
                
            }];
            [_actions addObject:action];
        }
    }
    return _actions;
}

- (NSMutableArray *)sourceArray {
    if (!_sourceArray) {
        _sourceArray = [NSMutableArray array];
    }
    return _sourceArray;
}

- (UICollectionViewFlowLayout *)sceneFlowLayout {
    if (!_sceneFlowLayout) {
        _sceneFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        _sceneFlowLayout.minimumInteritemSpacing = 5; //cell左右间隔
        _sceneFlowLayout.minimumLineSpacing = 5;      //cell上下间隔
        _sceneFlowLayout.sectionInset = UIEdgeInsetsMake(5, 15, 10, 10);
        _sceneFlowLayout.itemSize = CGSizeMake((SCREEN_WIDTH - 30) / 2 ,(SCREEN_WIDTH - 30) / 2);
    }
    return _sceneFlowLayout;
}

- (UICollectionView *)sceneCollectionView {
    if (!_sceneCollectionView) {
        _sceneCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - KTabBarHeight - KNavigationBar_Height) collectionViewLayout:self.sceneFlowLayout];
        _sceneCollectionView.dataSource = self;
        _sceneCollectionView.delegate = self;
        [_sceneCollectionView registerNib:[UINib nibWithNibName:@"GSHSceneCell" bundle:nil] forCellWithReuseIdentifier:@"sceneCell"];
        [_sceneCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headView"];
        [self.view addSubview:_sceneCollectionView];
        @weakify(self)
        _sceneCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            @strongify(self)
            self.currPage = 1;
            [self querySceneModeListWithFamilyId:[GSHOpenSDK share].currentFamily.familyId currPage:self.currPage];
            [self.sceneCollectionView.mj_header endRefreshing];
        }];
        _sceneCollectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            @strongify(self)
            self.currPage++;
            [self querySceneModeListWithFamilyId:[GSHOpenSDK share].currentFamily.familyId currPage:self.currPage];
            [self.sceneCollectionView.mj_footer endRefreshing];
        }];
    }
    return _sceneCollectionView;
}

#pragma mark - method
// 编辑按钮点击
- (void)editButtonClick:(UIButton *)button {
    
    if (self.sourceArray.count == 0) {
        [SVProgressHUD showInfoWithStatus:@"暂无情景可编辑"];
        return;
    }
    GSHSceneEditVC *sceneEditVC = [[GSHSceneEditVC alloc] init];
    sceneEditVC.hidesBottomBarWhenPushed = NO;
    sceneEditVC.sourceArray = [self.sourceArray mutableCopy];
    sceneEditVC.sceneEditCompleteBlock = ^(NSArray *sceneArray) {
        if (self.sourceArray.count > 0) {
            [self.sourceArray removeAllObjects];
        }
        [self.sourceArray addObjectsFromArray:sceneArray];
        [self.sceneCollectionView reloadData];
    };
    sceneEditVC.deleteSuccessBlock = ^(GSHOssSceneM *ossSceneM) {
        for (GSHOssSceneM *tmpSceneM in self.sourceArray) {
            if ([tmpSceneM.scenarioId isKindOfClass:NSNumber.class]) {
                if ([ossSceneM.scenarioId isEqualToNumber:tmpSceneM.scenarioId]) {
                    [self.sourceArray removeObject:tmpSceneM];
                    break;
                }
            }
        }
        [self.sceneCollectionView reloadData];
        if (self.sourceArray.count == 0) {
            [self showBlankView];
        }
    };
    [self.navigationController pushViewController:sceneEditVC animated:NO];

}

// 添加场景按钮点击
- (void)addSceneButtonClick:(UIBarButtonItem *)buttonItem {
    
    if ([GSHOpenSDK share].currentFamily.familyId.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请先创建家庭"];
        return ;
    }
    NSString *largestRank = @"0";
    if (self.sourceArray.count > 0) {
        GSHOssSceneM *ossSceneM = self.sourceArray[0];
        largestRank = [NSString stringWithFormat:@"%d",[ossSceneM.rank intValue] + 1];
    }
    GSHAddSceneVC *addSceneVC = [[GSHAddSceneVC alloc] init];
    addSceneVC.largestRank = largestRank;
    addSceneVC.hidesBottomBarWhenPushed = YES;
    @weakify(self)
    addSceneVC.saveSceneBlock = ^(GSHOssSceneM *ossSceneM) {
        @strongify(self)
        ossSceneM.rank = @((int)self.sourceArray.count + 1);
        [self.sourceArray insertObject:ossSceneM atIndex:0];
        [self dismissPageStatusView];
        self.navigationItem.leftBarButtonItem.enabled = YES;
        [self.sceneCollectionView reloadData];
    };
    [self.navigationController pushViewController:addSceneVC animated:YES];
    
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
    if([GSHOpenSDK share].currentFamily.floor.count == 1) {
        // 只有一个楼层
        roomStr = [NSString stringWithFormat:@"%@",ossSceneM.roomName?ossSceneM.roomName:@""];
    } else {
        if (ossSceneM.roomName && ossSceneM.roomName.length > 0) {
            roomStr = [NSString stringWithFormat:@"%@%@",ossSceneM.floorName,ossSceneM.roomName?ossSceneM.roomName:@""];
        }
    }
    cell.roomLabel.text = roomStr;
    cell.sceneImageView.image = [GSHSceneM getSceneListBackgroundImageWithId:[ossSceneM.backgroundId intValue]];
    cell.deleteButton.hidden = YES;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    if (self.sourceArray.count > indexPath.row) {
        GSHOssSceneM *ossSceneM = self.sourceArray[indexPath.row];
        [self executeSceneWithSceneListModel:ossSceneM];
    }
    
}

#pragma mark - request
// 查询情景模式列表
- (void)querySceneModeListWithFamilyId:(NSString *)familyId currPage:(int)currPage {
    
    self.navigationItem.leftBarButtonItem.enabled = [GSHOpenSDK share].currentFamily.permissions == GSHFamilyMPermissionsManager ? YES : NO;
    self.navigationItem.rightBarButtonItem.enabled = [GSHOpenSDK share].currentFamily.permissions == GSHFamilyMPermissionsManager ? YES : NO;
    
    if ([GSHOpenSDK share].currentFamily.familyId.length == 0) {
        [self showBlankView];
        return;
    }
    if (self == [UIViewController visibleTopViewController]) {
        [SVProgressHUD showWithStatus:@"请求中"];
    }
    @weakify(self)
    [GSHSceneManager getSceneListWithFamilyId:familyId currPage:[NSString stringWithFormat:@"%d",currPage] block:^(NSArray<GSHOssSceneM *> *list, NSError *error) {
        @strongify(self)
        if (error) {
            [SVProgressHUD dismiss];
            [self.view showPageStatus:TZMPageStatusNormal image:[UIImage imageNamed:@"blankpage_icon_network"] title:nil desc:error.localizedDescription buttonText:@"刷新" didClickButtonCallback:^(TZMPageStatus status) {
                [self querySceneModeListWithFamilyId:familyId currPage:currPage];
            }];
        } else {
            [SVProgressHUD dismiss];
            [self.view dismissPageStatusView];
            if (self.currPage == 1 && self.sourceArray.count > 0) {
                [self.sourceArray removeAllObjects];
            }
            if (list.count < 12) {
                self.sceneCollectionView.mj_footer.state = MJRefreshStateNoMoreData;
                self.sceneCollectionView.mj_footer.hidden = YES;
            } else {
                self.sceneCollectionView.mj_footer.state = MJRefreshStateIdle;
                self.sceneCollectionView.mj_footer.hidden = NO;
            }
            [self.sourceArray addObjectsFromArray:list];
            if (self.sourceArray.count == 0) {
                [self showBlankView];
            } else {
                [self.sceneCollectionView reloadData];
            }
            if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
                self.navigationItem.leftBarButtonItem.enabled = NO;
                self.navigationItem.rightBarButtonItem.enabled = NO;
            }
        }
    }];
}

- (void)showBlankView {
    
    self.navigationItem.leftBarButtonItem.enabled = NO;
    NSString *desc = [GSHOpenSDK share].currentFamily.permissions == GSHFamilyMPermissionsManager ? @"点击右上方\"+\"按钮，添加自定义场景" : @"";
    @weakify(self)
    [self showPageStatus:TZMPageStatusNormal
                   image:[UIImage imageNamed:@"blankpage_icon_homescene"]
                   title:@"家庭下尚未添加场景"
                    desc:desc
              buttonText:@"刷新"
  didClickButtonCallback:^(TZMPageStatus status) {
      @strongify(self)
      [self querySceneModeListWithFamilyId:[GSHOpenSDK share].currentFamily.familyId currPage:self.currPage];
  }];
}

// 执行情景模式
- (void)executeSceneWithSceneListModel:(GSHOssSceneM *)ossSceneM {
    
    [SVProgressHUD showWithStatus:@"执行中"];
    [GSHSceneManager executeSceneWithFamilyId:ossSceneM.familyId.stringValue gateWayId:[GSHOpenSDK share].currentFamily.gatewayId scenarioId:ossSceneM.scenarioId.stringValue block:^(NSError * _Nonnull error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        } else {
            [SVProgressHUD showSuccessWithStatus:@"执行成功"];
        }
    }];
    
}

@end
