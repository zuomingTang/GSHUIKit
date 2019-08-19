//
//  GSHAddAutoChooseDeviceVC.h
//  SmartHome
//
//  Created by zhanghong on 2018/6/4.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHAddAutoChooseDeviceVC : UITableViewController

+ (instancetype)addAutoChooseDeviceVC;

@end

@interface GSHAddAutoChooseDeviceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;


@end
