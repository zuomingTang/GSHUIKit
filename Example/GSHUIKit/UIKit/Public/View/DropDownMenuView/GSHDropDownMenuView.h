//
//  GSHDropDownMenuView.h
//  SmartHome
//
//  Created by zhanghong on 2018/5/24.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHDropDownMenuView : UIView

// width the table width, default 0.0, which indicates that the table width is equal to
// the window width, width less than 80 is two small and will be set to window width as
// well
@property (nonatomic, assign) CGFloat width;

// cell color default [UIColor colorWithRed:0.296 green:0.613 blue:1.000 alpha:1.000]
@property (nonatomic, strong) UIColor *cellColor;

// cell seprator color default whiteColor
@property (nonatomic, strong) UIColor *cellSeparatorColor;

// cell accessory check mark color default whiteColor
@property (nonatomic, strong) UIColor *cellAccessoryCheckmarkColor;

// cell height default 44
@property (nonatomic, assign) CGFloat cellHeight;

// animation duration default 0.4
@property (nonatomic, assign) CGFloat animationDuration;


// text color default whiteColor
@property (nonatomic, strong) UIColor *textColor;

// text font default system 17
@property (nonatomic, strong) UIFont *textFont;

// background opacity default 0.3
@property (nonatomic, assign) CGFloat backgroundAlpha;

@property (nonatomic, assign) NSUInteger selectedIndex;

@property (nonatomic, copy) NSArray *titles;

// callback block
@property (nonatomic, copy) void (^selectedAtIndex)(int index);

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray*)titles;

- (void)refreshWithTitles:(NSArray<NSString*>*)titles;

@end
