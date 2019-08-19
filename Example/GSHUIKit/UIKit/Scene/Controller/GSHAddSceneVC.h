//
//  GSHAddSceneVC.h
//  SmartHome
//
//  Created by zhanghong on 2018/5/16.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GSHOpenSDKSoundCode/GSHSceneM.h>

@interface GSHAddSceneVC : UIViewController

@property (nonatomic , strong) GSHSceneM *sceneM;

@property (nonatomic , strong) GSHOssSceneM *ossSceneM;

@property (nonatomic , strong) NSString *largestRank;

@property (nonatomic , assign) BOOL isAlertToNotiUser;

@property (nonatomic , copy) void (^saveSceneBlock)(GSHOssSceneM *ossSceneM);

@property (nonatomic , copy) void (^updateSceneBlock)(GSHOssSceneM *ossSceneM);

@end
