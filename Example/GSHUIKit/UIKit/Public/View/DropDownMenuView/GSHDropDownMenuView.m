//
//  GSHDropDownMenuView.m
//  SmartHome
//
//  Created by zhanghong on 2018/5/24.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHDropDownMenuView.h"
#import <Masonry.h>
#import "GSHDropDownMenuCell.h"
#import "UIButton+TZM.h"

static const CGFloat kKTDropdownMenuViewHeaderHeight = 300;
static const CGFloat kKTDropdownMenuViewAutoHideHeight = 44;

@interface GSHDropDownMenuView() <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) BOOL isMenuShow;
@property (nonatomic, strong) UIButton *titleButton;
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *wrapperView;

@end

@implementation GSHDropDownMenuView

- (void)refreshWithTitles:(NSArray<NSString*>*)titles{
    _titles = titles;
    if (_titles.count > 0) {
        self.selectedIndex = 0;
    }else{
        [self.titleButton setTitle:@"" forState:UIControlStateNormal];
    }
    if (_titles.count <= 1) {
        self.titleButton.userInteractionEnabled = NO;
        self.arrowImageView.hidden = YES;
    }else{
        self.titleButton.userInteractionEnabled = YES;
        self.arrowImageView.hidden = NO;
    }
    [self.tableView reloadData];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        _width = 0.0;
        _animationDuration = 0.4;
        _backgroundAlpha = 0.4;
        _cellHeight = 40;
        _isMenuShow = NO;
        _selectedIndex = 0;

        [self addSubview:self.titleButton];
        [self addSubview:self.arrowImageView];
        [self.wrapperView addSubview:self.backgroundView];
        [self.wrapperView addSubview:self.tableView];

        // 添加KVO监听tableView的contenOffset属性，添加上滑返回功能
        NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
        [self.tableView addObserver:self forKeyPath:@"contentOffset" options:options context:nil];
    }
    return self;
}

#pragma mark -- life cycle --

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles {
    if (self = [super initWithFrame:frame]) {
        _width = 0.0;
        _animationDuration = 0.4;
        _backgroundAlpha = 0.4;
        _cellHeight = 40;
        _isMenuShow = NO;
        _selectedIndex = 0;
        _titles = titles;
        
        [self addSubview:self.titleButton];
        [self addSubview:self.arrowImageView];
        [self.wrapperView addSubview:self.backgroundView];
        [self.wrapperView addSubview:self.tableView];
        
        // 添加KVO监听tableView的contenOffset属性，添加上滑返回功能
        NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
        [self.tableView addObserver:self forKeyPath:@"contentOffset" options:options context:nil];
    }
    return self;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = self.cellSeparatorColor;
    if (self.window) {
        [self.window addSubview:self.wrapperView];
        [self.titleButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
        [self.arrowImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleButton.mas_right).offset(5);
            make.centerY.equalTo(self.titleButton.mas_centerY);
        }];
        // 依附于导航栏下面
        [self.wrapperView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.window);
            make.top.equalTo(self.superview.mas_bottom);
        }];
        [self.backgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.wrapperView);
        }];
        CGFloat tableCellsHeight = _cellHeight * _titles.count;
        [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.wrapperView.mas_centerX);
            if (self.width > 79.99999) {
                make.width.mas_equalTo(self.width);
            } else {
                make.width.equalTo(self.wrapperView.mas_width);
            }
            make.top.equalTo(self.wrapperView.mas_top).offset(-tableCellsHeight - kKTDropdownMenuViewHeaderHeight);
            make.bottom.equalTo(self.wrapperView.mas_bottom).offset(tableCellsHeight + kKTDropdownMenuViewHeaderHeight);
        }];
        self.wrapperView.hidden = YES;
    } else {
        // 避免不能销毁的问题
        [self.wrapperView removeFromSuperview];
    }
}

- (void)dealloc {
    [self.tableView removeObserver:self forKeyPath:@"contentOffset"];
}

#pragma mark -- KVO --

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    // 遇到这些情况就直接返回
    if (!self.userInteractionEnabled || !self.isMenuShow)
        return;
    
    // 这个就算看不见也需要处理
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint newOffset = [[change valueForKey:@"new"] CGPointValue];
        if (newOffset.y > kKTDropdownMenuViewAutoHideHeight) {
            self.isMenuShow = !self.isMenuShow;
        }
    }
}

#pragma mark -- UITableViewDataSource --
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titles.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GSHDropDownMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dropDownMenuCell" forIndexPath:indexPath];
    cell.selectTextLabel.text = [self.titles objectAtIndex:indexPath.row];
    cell.arrowImageView.hidden = !(self.selectedIndex == indexPath.row);
    cell.tintColor = self.cellAccessoryCheckmarkColor;
    cell.backgroundColor = self.cellColor;
    cell.selectTextLabel.font = self.textFont;
    cell.selectTextLabel.textColor = self.textColor;
    
    return cell;
}

#pragma mark -- UITableViewDataDelegate --
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedIndex = indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.selectedAtIndex) {
        self.selectedAtIndex((int)indexPath.row);
    }
    return nil;
}

#pragma mark -- handle actions --

- (void)handleTapOnTitleButton:(UIButton *)button {
    self.isMenuShow = !self.isMenuShow;
}

- (void)orientChange:(NSNotification *)notif {
    NSLog(@"change orientation");
}

#pragma mark -- helper methods --

- (void)showMenu {
    
    self.titleButton.enabled = NO;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, kKTDropdownMenuViewHeaderHeight)];
    headerView.backgroundColor = self.cellColor;
    self.tableView.tableHeaderView = headerView;
    [self.tableView layoutIfNeeded];
    
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.wrapperView.mas_top).offset(-kKTDropdownMenuViewHeaderHeight);
        make.bottom.equalTo(self.wrapperView.mas_bottom).offset(kKTDropdownMenuViewHeaderHeight);
    }];
    self.wrapperView.hidden = NO;
    self.backgroundView.alpha = 0.0;
    
    [UIView animateWithDuration:self.animationDuration
                     animations:^{
                         self.arrowImageView.transform = CGAffineTransformRotate(self.arrowImageView.transform, M_PI);
                     }];
    
    [UIView animateWithDuration:self.animationDuration * 1.5
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [self.tableView layoutIfNeeded];
                         self.backgroundView.alpha = self.backgroundAlpha;
                         self.titleButton.enabled = YES;
                     } completion:nil];
}

- (void)hideMenu {
    
    self.titleButton.enabled = NO;
    CGFloat tableCellsHeight = _cellHeight * _titles.count + 1;
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.wrapperView.mas_top).offset(-tableCellsHeight - kKTDropdownMenuViewHeaderHeight);
        make.bottom.equalTo(self.wrapperView.mas_bottom).offset(tableCellsHeight + kKTDropdownMenuViewHeaderHeight);
    }];
    
    [UIView animateWithDuration:self.animationDuration
                     animations:^{
                         self.arrowImageView.transform = CGAffineTransformRotate(self.arrowImageView.transform, M_PI);
                     }];
    
    [UIView animateWithDuration:self.animationDuration * 1.5
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [self.tableView layoutIfNeeded];
                         self.backgroundView.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         self.wrapperView.hidden = YES;
                         [self.tableView reloadData];
                         self.titleButton.enabled = YES;
                     }];
}

#pragma mark -- getter and setter --

- (UIColor *)cellColor {
    
    if (!_cellColor) {
        _cellColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    }
    
    return _cellColor;
}

@synthesize cellSeparatorColor = _cellSeparatorColor;
- (UIColor *)cellSeparatorColor {
    
    if (!_cellSeparatorColor) {
        _cellSeparatorColor = [UIColor colorWithRed:0.22745 green:0.22745 blue:0.22745 alpha:1];
    }
    
    return _cellSeparatorColor;
}

- (void)setCellSeparatorColor:(UIColor *)cellSeparatorColor {
    if (_tableView)
    {
        _tableView.separatorColor = cellSeparatorColor;
    }
    _cellSeparatorColor = cellSeparatorColor;
}

- (UIColor *)cellAccessoryCheckmarkColor
{
    if (!_cellAccessoryCheckmarkColor)
    {
        _cellAccessoryCheckmarkColor = [UIColor whiteColor];
    }
    
    return _cellAccessoryCheckmarkColor;
}


@synthesize textColor = _textColor;
- (UIColor *)textColor
{
    if (!_textColor)
    {
        _textColor = [UIColor whiteColor];
    }
    
    return _textColor;
}

- (void)setTextColor:(UIColor *)textColor
{
    if (_titleButton)
    {
        [_titleButton setTitleColor:textColor forState:UIControlStateNormal];
    }
    _textColor = textColor;
}

@synthesize textFont = _textFont;
- (UIFont *)textFont
{
    if(!_textFont)
    {
        _textFont = [UIFont systemFontOfSize:18];
    }
    
    return _textFont;
}

- (void)setTextFont:(UIFont *)textFont
{
    if (_titleButton)
    {
        [_titleButton.titleLabel setFont:textFont];;
    }
    _textFont = textFont;
}

- (UIButton *)titleButton {
    if (!_titleButton) {
        _titleButton = [[UIButton alloc] init];
        _titleButton.z_touchHitEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -50);
        [_titleButton setTitle:[self.titles objectAtIndex:0] forState:UIControlStateNormal];
        [_titleButton addTarget:self action:@selector(handleTapOnTitleButton:) forControlEvents:UIControlEventTouchUpInside];
        [_titleButton.titleLabel setFont:self.textFont];
        _titleButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_titleButton setTitleColor:self.textColor forState:UIControlStateNormal];
    }
    
    return _titleButton;
}

- (UIImageView *)arrowImageView {
    
    if (!_arrowImageView) {
        UIImage *image = [UIImage imageNamed:@"homeVC_titleView_downArrow_icon"];
        _arrowImageView = [[UIImageView alloc] initWithImage:image];
    }
    return _arrowImageView;
    
}

- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _tableView.tableFooterView = [UIView new];
        [_tableView registerNib:[UINib nibWithNibName:@"GSHDropDownMenuCell" bundle:nil] forCellReuseIdentifier:@"dropDownMenuCell"];
    }
    
    return _tableView;
}

- (UIView *)wrapperView
{
    if (!_wrapperView)
    {
        _wrapperView = [[UIView alloc] init];
        _wrapperView.clipsToBounds = YES;
    }
    
    return _wrapperView;
}

- (UIView *)backgroundView
{
    if (!_backgroundView)
    {
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [UIColor blackColor];
        _backgroundView.alpha = self.backgroundAlpha;
    }
    
    return _backgroundView;
}

- (void)setIsMenuShow:(BOOL)isMenuShow
{
    if (_isMenuShow != isMenuShow)
    {
        _isMenuShow = isMenuShow;
        
        if (isMenuShow)
        {
            [self showMenu];
        }
        else
        {
            [self hideMenu];
        }
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [self.tableView reloadData];
    _selectedIndex = selectedIndex;
    [_titleButton setTitle:[_titles objectAtIndex:selectedIndex] forState:UIControlStateNormal];
    
    self.isMenuShow = NO;
}

- (void)setWidth:(CGFloat)width
{
    if (width < 80.0)
    {
        NSLog(@"width should be set larger than 80, otherwise it will be set to be equal to window width");
        
        return;
    }
    
    _width = width;
}

@end
