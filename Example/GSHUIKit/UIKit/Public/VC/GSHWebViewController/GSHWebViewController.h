//
//  GSHWebViewController.h
//  SmartHome
//
//  Created by gemdale on 2018/9/25.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "LYWKWebViewController.h"

#import <JKWKWebViewHandler/JKWKWebViewHandler.h>

typedef enum : NSInteger {
    GSHAppConfigH5TypeAgreement = 0, // 使用协议
    GSHAppConfigH5TypeFeedback  = 1, // 意见反馈
    GSHAppConfigH5TypeNorouter  = 2, // 找不到要连接的路由
    GSHAppConfigH5TypeHelp  = 3,     // 使用帮助
    GSHAppConfigH5TypeSensor  = 4,     // 传感器
} GSHAppConfigH5Type;

@interface JKEventHandler (GSH)<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
- (void)getInfoFromNative:(id)params;
- (void)getInfoFromNative:(id)params :(void(^)(id response))callBack;
@end

@interface GSHWebViewController : LYWKWebViewController
// 生成h5 url
+ (NSURL*)webUrlWithType:(GSHAppConfigH5Type)type parameter:(NSDictionary*)parameter;
- (void)newNavbarRightButWithTitle:(NSString*)title block:(void(^)(id response))callBack;
@end
