

#import "PopoverViewCell.h"
#import <Masonry.h>
#import "UIButton+WebCache.h"

#import "UIImageView+WebCache.h"

// extern
float const PopoverViewCellHorizontalMargin = 15.f; ///< 水平边距
float const PopoverViewCellVerticalMargin = 3.f; ///< 垂直边距
float const PopoverViewCellTitleLeftEdge = 8.f; ///< 标题左边边距

@interface PopoverViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, weak) UIView *bottomLine;
@property (nonatomic, assign)BOOL isLeftPic;

@property (nonatomic, strong) UIImageView *leftImageView;

@end

@implementation PopoverViewCell

#pragma mark - Life Cycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = self.backgroundColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self initialize];
    
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        self.backgroundColor = _style == PopoverViewStyleDefault ? [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.00] : [UIColor colorWithRed:0.23 green:0.23 blue:0.23 alpha:1.00];
    } else {
        [UIView animateWithDuration:0.3f animations:^{
            self.backgroundColor = [UIColor clearColor];
        }];
    }
}

#pragma mark - Setter
- (void)setStyle:(PopoverViewStyle)style {
    _style = style;
    _bottomLine.backgroundColor = [self.class bottomLineColorForStyle:style];
    if (_style == PopoverViewStyleDefault) {
        _titleLabel.textColor = UIColor.blackColor;
    } else {
        _titleLabel.textColor = UIColor.whiteColor;
    }
}

#pragma mark - Private
// 初始化
- (void)initialize {
    // 底部线条
    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.backgroundColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.00];
    bottomLine.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:bottomLine];
    _bottomLine = bottomLine;
    // Constraint
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomLine]|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(bottomLine)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomLine(lineHeight)]|" options:kNilOptions metrics:@{@"lineHeight" : @(1/[UIScreen mainScreen].scale)} views:NSDictionaryOfVariableBindings(bottomLine)]];
    
    _rightImageView = [[UIImageView alloc] init];
    _rightImageView.hidden = YES;
    [self.contentView addSubview:_rightImageView];
//    _rightImageView.layer.cornerRadius = 16;
//    _rightImageView.clipsToBounds = YES;
    [_rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.trailing.equalTo(self).offset(-10);
//        make.width.equalTo(@(32));
//        make.height.equalTo(@(32));
    }];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [self.class titleFont];
    _titleLabel.textColor = UIColor.blackColor;
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_titleLabel];
    
    _leftImageView = [[UIImageView alloc] init];
    _leftImageView.hidden = YES;
    [self.contentView addSubview:_leftImageView];
    [_leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.leading.equalTo(self).offset(10);
        make.width.equalTo(@(32));
        make.height.equalTo(@(32));
    }];
    _leftImageView.layer.cornerRadius = 16;
    _leftImageView.clipsToBounds = YES;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if (self.isLeftPic) {
        _titleLabel.frame = CGRectMake(10 + 32 + 10, 0, self.frame.size.width - 62, self.height);
    }else{
        _titleLabel.frame = CGRectMake(10, 0, self.frame.size.width - 62, self.height);
    }
}

#pragma mark - Public
/*! @brief 标题字体 */
+ (UIFont *)titleFont {
    return [UIFont systemFontOfSize:15.f];
}

/*! @brief 底部线条颜色 */
+ (UIColor *)bottomLineColorForStyle:(PopoverViewStyle)style {
    return style == PopoverViewStyleDefault ? [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.00] : [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.00];
}

- (void)setAction:(PopoverAction *)action isLeftPic:(BOOL)isLeftPic {
    _titleLabel.text = action.title;
    self.isLeftPic = isLeftPic;
    if (isLeftPic) {
        _leftImageView.hidden = NO;
        _rightImageView.hidden = YES;
        if (action.image) {
            [_leftImageView setImage:action.image];
        }else{
            [_leftImageView sd_setImageWithURL:[NSURL URLWithString:action.imageUrl] placeholderImage:nil];
        }
        _titleLabel.frame = CGRectMake(10 + 32 + 10, 0, self.frame.size.width - 62, self.height);
        
    } else {
        _leftImageView.hidden = YES;
        _rightImageView.hidden = YES;
        if (action.image) {
            [_rightImageView setImage:action.image];
        }else{
            [_rightImageView sd_setImageWithURL:[NSURL URLWithString:action.imageUrl] placeholderImage:nil];
        }
        _titleLabel.frame = CGRectMake(10, 0, self.frame.size.width - 62, self.height);
    }

}

- (void)showBottomLine:(BOOL)show {
    _bottomLine.hidden = !show;
}

@end
