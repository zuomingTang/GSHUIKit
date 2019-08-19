//
//  GSHAddAutoVC.h
//  SmartHome
//
//  Created by zhanghong on 2018/5/30.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHAddAutoVC : UIViewController

@property (assign , nonatomic) BOOL isEditType;

@property (strong , nonatomic) GSHAutoM *autoM;

@property (strong , nonatomic) GSHOssAutoM *ossAutoM;

@property (nonatomic , assign) BOOL isAlertToNotiUser;

@property (copy , nonatomic) void(^addAutoSuccessBlock)(GSHOssAutoM *ossAutoM);

@property (copy , nonatomic) void(^updateAutoSuccessBlock)(GSHOssAutoM *ossAutoM);

+ (instancetype)addAutoVC;

@end

@interface GSHAddAutoOneCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *nameInputTextField;

@end

@interface GSHAddAutoTwoCell : UITableViewCell

- (void)setCellValueWithNameStr:(NSString *)str;

@end

@interface GSHAddAutoThreeCell : UITableViewCell

- (void)setCellValueWithNameStr:(NSString *)str;

@end

@interface GSHAddAutoFourCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *rightImageView;

@property (weak, nonatomic) IBOutlet UILabel *typeNameLabel;


@end

@interface GSHAddAutoFiveCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;
@property (weak, nonatomic) IBOutlet UILabel *cellNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightUpLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightDownLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightMiddleLabel;

@end

