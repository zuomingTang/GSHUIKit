//
//  GSHMessageNotiSetVC.h
//  SmartHome
//
//  Created by zhanghong on 2018/11/29.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSHMessageNotiSetVC : UITableViewController

+ (instancetype)messageNotiSetVC;

@end

@interface GSHMessageNotiCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *cellNameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *notiSwitch;

@property (copy, nonatomic) void(^switchClickBlock)(void);

@end


NS_ASSUME_NONNULL_END
