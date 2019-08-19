//
//  GSHSceneEditVC.h
//  SmartHome
//
//  Created by zhanghong on 2018/7/17.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHSceneEditVC : UIViewController

@property (nonatomic, strong) NSMutableArray *sourceArray;

@property (nonatomic , copy) void (^sceneEditCompleteBlock)(NSArray *sceneArray);

@property (nonatomic , copy) void (^deleteSuccessBlock)(GSHOssSceneM *ossSceneM);

@end
