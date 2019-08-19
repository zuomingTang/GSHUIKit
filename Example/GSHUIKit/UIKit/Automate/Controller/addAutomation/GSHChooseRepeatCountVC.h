//
//  GSHChooseRepeatCountVC.h
//  SmartHome
//
//  Created by zhanghong on 2018/6/1.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHChooseRepeatCountVC : UITableViewController

@property (nonatomic , copy) void(^chooseRepeatCountBlock)(NSIndexSet *indexSet,NSString *showRepeatStr);

@property (nonatomic , strong) NSIndexSet *choosedIndexSet;

+ (instancetype)chooseRepeatCountVC;


@end


@interface GSHChooseRepeatCountCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *cellNameLabel;

@property (weak, nonatomic) IBOutlet UIButton *checkButton;

@end
