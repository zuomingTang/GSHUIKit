//
//  GSHMessageVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/6/8.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHMessageVC.h"
#import "GSHMessageTableViewVC.h"
#import "GSHAlertManager.h"

#import "ZJScrollPageView.h"
#import "UIView+YeeBadge.h"
#import "YeeBadgeView.h"

#import "GSHMessageNotiSetVC.h"
#import "GSHSensorDetailVC.h"
#import "NSObject+TZM.h"

#define pageMenuH 40
#define scrollViewHeight (SCREEN_HEIGHT - KNavigationBar_Height - pageMenuH)

NSString *const GSHQueryIsHasUnReadMsgNotification = @"GSHQueryIsHasUnReadMsgNotification";

@interface GSHMessageVC () <UIScrollViewDelegate,ZJScrollPageViewDelegate>

@property(strong, nonatomic)NSArray<NSString *> *titles;
@property(strong, nonatomic)NSArray<UIViewController *> *childVcs;
@property (nonatomic, strong) ZJScrollPageView *scrollPageView;
@property (nonatomic, assign) NSInteger selectIndex;
@property(strong, nonatomic) NSMutableArray *titleViewArray;
@property(strong, nonatomic) NSMutableDictionary *subTableViewDictionary;
@property(strong, nonatomic) NSMutableIndexSet *unReadMsgIndexSet;

@end

@implementation GSHMessageVC

- (void)dealloc {
    NSLog(@"delloc");
}

- (instancetype)initWithSelectIndex:(NSInteger)selectIndex
{
    self = [super init];
    if (self) {
        self.selectIndex = selectIndex;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    [self initNavigation];
    
    ZJSegmentStyle *style = [[ZJSegmentStyle alloc] init];
    // 显示滚动条
    style.showLine = YES;
    // 颜色渐变
    style.gradualChangeTitleColor = YES;
    style.normalTitleColor = [UIColor colorWithHexString:@"#282828"];
    style.selectedTitleColor = [UIColor colorWithHexString:@"#4C90F7"];
    style.titleFont = [UIFont fontWithName:@"PingFangSC-Medium" size:16.0];
    style.titleMargin = SCREEN_WIDTH / 10.0;
    style.scrollLineColor = [UIColor colorWithHexString:@"#4C90F7"];
    style.adjustTitleWhenBeginDrag = YES;
    style.segmentHeight = 40.0;
    
    self.titles = @[@"告警",@"系统",@"低电量",@"场景",@"联动"];
    // 初始化
    _scrollPageView = [[ZJScrollPageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - KNavigationBar_Height) segmentStyle:style titles:self.titles parentViewController:self delegate:self];
    _scrollPageView.backgroundColor = [UIColor colorWithHexString:@"#F6F7FA"];
    _scrollPageView.segmentView.backgroundColor = [UIColor colorWithHexString:@"#FAFAFA"];
    [self.view addSubview:_scrollPageView];
    [_scrollPageView setSelectedIndex:self.selectIndex animated:YES];
    [self setMsgToBeReadWithFamilyId:[GSHOpenSDK share].currentFamily.familyId msgType:self.selectIndex+1 block:^(NSError * _Nonnull error) {
    }];
    
    [self queryIsHasUnReadMsg];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfChildViewControllers {
    return self.titles.count;
}

- (UIViewController<ZJScrollPageViewChildVcDelegate> *)childViewController:(UIViewController<ZJScrollPageViewChildVcDelegate> *)reuseViewController forIndex:(NSInteger)index {
    UIViewController<ZJScrollPageViewChildVcDelegate> *childVc = reuseViewController;
    
    if (!childVc) {
        GSHMessageTableViewVC *vc = [[GSHMessageTableViewVC alloc] initWithMsgType:[NSString stringWithFormat:@"%d",(int)index+1]];
        childVc = vc;
    }
    self.selectIndex = index;
    NSString *indexKey = [NSString stringWithFormat:@"%zd",index];
    [self.subTableViewDictionary setObject:childVc forKey:indexKey];

    return childVc;
}

/**
 *  页面将要出现
 *
 *  @param scrollPageController
 *  @param childViewController
 *  @param index
 */
- (void)scrollPageController:(UIViewController *)scrollPageController childViewControllWillAppear:(UIViewController *)childViewController forIndex:(NSInteger)index {
    [self showOrHiddenBadgeViewWithTypeIndex:index isShow:NO];
}

- (void)setUpTitleView:(ZJTitleView *)titleView forIndex:(NSInteger)index {
    titleView.label.redDotOffset = CGPointMake(0, 12);
    [self.titleViewArray insertObject:titleView atIndex:index];
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return YES;
}

#pragma mark - UI
- (void)initNavigation {
    
    self.navigationItem.title = @"消息";
    self.view.backgroundColor = [UIColor whiteColor];
    // 编辑
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"message_icon_edit"] style:UIBarButtonItemStylePlain target:self action:@selector(messageEditButtonClick:)];
    
    UIImage *leftImage = [[UIImage imageNamed:@"app_icon_blackback_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:leftImage style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    
}

#pragma mark - Lazy
- (NSMutableArray *)titleViewArray {
    if (!_titleViewArray) {
        _titleViewArray = [NSMutableArray array];
    }
    return _titleViewArray;
}

- (NSMutableDictionary *)subTableViewDictionary {
    if (!_subTableViewDictionary) {
        _subTableViewDictionary = [NSMutableDictionary dictionary];
    }
    return _subTableViewDictionary;
}

- (NSMutableIndexSet *)unReadMsgIndexSet {
    if (!_unReadMsgIndexSet) {
        _unReadMsgIndexSet = [NSMutableIndexSet indexSet];
    }
    return _unReadMsgIndexSet;
}

#pragma mark - method
- (void)messageEditButtonClick:(UIButton *)button {
    
    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
        if (buttonIndex == 1) {
            // 提醒设置
            GSHMessageNotiSetVC *messageNotiSetVC = [GSHMessageNotiSetVC messageNotiSetVC];
            [self.navigationController pushViewController:messageNotiSetVC animated:YES];
        } else if (buttonIndex == 2) {
            // 清空消息
            [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                if (buttonIndex == 0) {
                    //清空消息代码
                    [self clearMsgWithMsgType:self.selectIndex+1];
                }
            } textFieldsSetupHandler:NULL andTitle:nil andMessage:@"确认清空所有消息？" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:@"清空" cancelButtonTitle:nil otherButtonTitles:@"取消",nil];
        }
    } textFieldsSetupHandler:^(UITextField *textField, NSUInteger index) {
        
    } andTitle:@"" andMessage:@"" image:nil preferredStyle:GSHAlertManagerStyleActionSheet destructiveButtonTitle:@"" cancelButtonTitle:@"取消" otherButtonTitles:@"提醒设置",@"清空消息",nil];

}

- (void)back {
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

// 显示或隐藏指定类别的小红点
- (void)showOrHiddenBadgeViewWithTypeIndex:(NSInteger)typeIndex isShow:(BOOL)isShow {
    
    if (self.titleViewArray.count > typeIndex) {
        ZJTitleView *titleView = self.titleViewArray[typeIndex];
        if (isShow) {
            [titleView.label ShowBadgeView];
            [self.unReadMsgIndexSet addIndex:typeIndex];
        } else {
            [titleView.label hideBadgeView];
            if ([self.unReadMsgIndexSet containsIndex:typeIndex]) {
                @weakify(self)
                [self setMsgToBeReadWithFamilyId:[GSHOpenSDK share].currentFamily.familyId msgType:typeIndex+1 block:^(NSError * _Nonnull error) {
                    @strongify(self)
                    if (!error) {
                        if (self.unReadMsgIndexSet.count == 1) {
                            [self postNotification:GSHQueryIsHasUnReadMsgNotification object:nil];
                        }
                    }
                    [self.unReadMsgIndexSet removeIndex:typeIndex];
                }];
            }
        }
    }
}

- (void)changeSelectIndex:(NSInteger)selectIndex {
    self.selectIndex = selectIndex;
    [_scrollPageView setSelectedIndex:self.selectIndex animated:YES];
    NSString *indexKey = [NSString stringWithFormat:@"%d",(int)selectIndex];
    if ([self.subTableViewDictionary objectForKey:indexKey]) {
        [[self.subTableViewDictionary objectForKey:indexKey] refreshMsg];
    }
}

#pragma mark - request
// 查询是否有未读消息
- (void)queryIsHasUnReadMsg {
    
    @weakify(self)
    [GSHMessageManager queryIsHasUnReadMsgWithFamilyId:[GSHOpenSDK share].currentFamily.familyId block:^(NSArray<NSNumber *> * _Nonnull list, NSError * _Nonnull error) {
        @strongify(self)
        if (!error) {
            if (list.count > 0) {
                for (NSNumber *str in list) {
                    NSLog(@"str : %@",str);
                    if (str.intValue-1 != (int)self.selectIndex) {
                        [self showOrHiddenBadgeViewWithTypeIndex:str.intValue-1 isShow:YES];
                    }
                }
            } else {
                [self postNotification:GSHQueryIsHasUnReadMsgNotification object:nil];
            }
        }
    }];
}

// 清空消息
- (void)clearMsgWithMsgType:(NSInteger)msgType{
    [SVProgressHUD showWithStatus:@"删除中"];
    @weakify(self)
    [GSHMessageManager deleteMsgWithFamilyId:[GSHOpenSDK share].currentFamily.familyId msgType:msgType block:^(NSError * _Nonnull error) {
        @strongify(self)
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        } else {
            [SVProgressHUD showSuccessWithStatus:@"删除成功"];
            NSString *indexKey = [NSString stringWithFormat:@"%d",(int)msgType-1];
            if ([self.subTableViewDictionary objectForKey:indexKey]) {
                [[self.subTableViewDictionary objectForKey:indexKey] clearMsg];
            }
        }
    }];
}

// 将某一类消息置为已读
- (void)setMsgToBeReadWithFamilyId:(NSString *)familyId msgType:(NSInteger)msgType block:(void(^)(NSError * _Nonnull error))block {
    [GSHMessageManager setMsgToBeReadWithFamilyId:familyId msgType:msgType block:block];
}

@end
