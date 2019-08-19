//
//  GSHAddTriggerConditionVC.h
//  SmartHome
//
//  Created by zhanghong on 2018/5/30.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHAddTriggerConditionVC : UITableViewController

@property (nonatomic, copy) void (^selectDeviceBlock)(NSArray *selectedDeviceArray);
@property (strong, nonatomic) void (^compeleteSetTimeBlock)(NSString *time , NSString *repeatCount,NSIndexSet *repeatCountIndexSet);

@property (nonatomic, strong) NSMutableArray *selectedDeviceArray;

@property (strong, nonatomic) NSString *time;

+ (instancetype)addTriggerConditionVC;

@end

@interface GSHAddTriggerConditionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;
@property (weak, nonatomic) IBOutlet UILabel *triggerConditionNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *triggerDetailLabel;

@end
