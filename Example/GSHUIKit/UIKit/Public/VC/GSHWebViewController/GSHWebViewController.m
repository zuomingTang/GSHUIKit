//
//  GSHWebViewController.m
//  SmartHome
//
//  Created by gemdale on 2018/9/25.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHWebViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "GSHAlertManager.h"

#import "TZMImagePickerController.h"
#import "UIView+TZM.h"
#import "UIViewController+TZM.h"
#import "NSDictionary+TZM.h"

@implementation JKEventHandler (GSH)
- (void)getInfoFromNative:(id)params{
    NSLog(@"sendInfoToNative :%@",params);
    if ([params isKindOfClass:NSString.class]) {
        params = [((NSString*)params) jsonValueDecoded];
    }
    NSString *funName = [((NSDictionary*)params) stringValueForKey:@"funName" default:nil];
    if([funName isEqualToString:@"popPage"]){
        [self popPage];
    }
}
- (void)getInfoFromNative:(id)params :(void(^)(id response))callBack{
    NSLog(@"params %@",params);
    if ([params isKindOfClass:NSString.class]) {
        params = [((NSString*)params) jsonValueDecoded];
    }
    NSString *funName = [((NSDictionary*)params) stringValueForKey:@"funName" default:nil];
    if([funName isEqualToString:@"camera"]){
        [self cameraWithBlock:callBack];
    }else if ([funName isEqualToString:@"navRightBut"]){
        NSString *title = [((NSDictionary*)params) stringValueForKey:@"title" default:nil];
        [self newNavbarRightButWithTitle:title block:callBack];
    }else if ([funName isEqualToString:@"setTitleName"]){
        NSString *title = [((NSDictionary*)params) stringValueForKey:@"title" default:nil];
        self.webView.viewController.title = title;
    }
}

- (void)cameraWithBlock:(void(^)(id response))callBack{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied) {
        [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
        } textFieldsSetupHandler:NULL andTitle:@"没有相机权限" andMessage:@"请到系统设置里设置，设置->隐私->相机，打开应用权限" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:nil otherButtonTitles:@"已经打开",@"取消",nil];
        return;
    }else{
    }
    TZMImagePickerController *picker = [[TZMImagePickerController alloc] init];
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.block = ^(NSDictionary<NSString *,id> *info) {
        if (info) {
            UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
            [SVProgressHUD showWithStatus:@"上传中"];
            [GSHUserManager postImage:image type:GSHUploadingImageTypeIdea progress:^(NSProgress *progress) {
                [SVProgressHUD showProgress:(90.0 * progress.completedUnitCount) / (100.0 * progress.totalUnitCount) status:@"请稍候"];
            } block:^(NSString *picPath, NSError *error) {
                if (picPath) {
                    [SVProgressHUD dismiss];
                    if (callBack) {
                        callBack([@{@"url":picPath} yy_modelToJSONString]);
                    }
                }else{
                    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                    if (callBack) {
                        callBack(nil);
                    }
                }
            }];
        }else{
            if (callBack) {
                callBack(nil);
            }
        }
    };
    [[UIViewController visibleTopViewController] presentViewController:picker animated:YES completion:^{
    }];
}

- (void)newNavbarRightButWithTitle:(NSString*)title block:(void(^)(id response))callBack{
    UIViewController *webVC = self.webView.viewController;
    if ([webVC isKindOfClass:GSHWebViewController.class]) {
        [((GSHWebViewController*)webVC) newNavbarRightButWithTitle:title block:callBack];
    }
}

- (void)popPage{
    UIViewController *webVC = self.webView.viewController;
    [webVC.navigationController popViewControllerAnimated:YES];
}

@end



@interface GSHWebViewController ()
@property (nonatomic,copy)void(^navbarRightButBlock)(id response);
@end

@implementation GSHWebViewController

// 生成h5 url
+ (NSURL*)webUrlWithType:(GSHAppConfigH5Type)type parameter:(NSDictionary*)parameter{
    NSString *urlString;
    switch (type) {
            case GSHAppConfigH5TypeFeedback:
            urlString = [NSString stringWithFormat:@"http://www.gemdalehome.com:8089/h5/%@/#/",@"feedback"];
            break;
            case GSHAppConfigH5TypeAgreement:
            urlString = [NSString stringWithFormat:@"http://www.gemdalehome.com:8089/h5/%@",@"agreement.html"];
            break;
            case GSHAppConfigH5TypeNorouter:
            urlString = [NSString stringWithFormat:@"http://www.gemdalehome.com:8089/h5/%@",@"norouter.html"];
            break;
            case GSHAppConfigH5TypeHelp:
            urlString = [NSString stringWithFormat:@"http://www.gemdalehome.com:8089/h5/%@/#/",@"usehelp"];
            break;
            case GSHAppConfigH5TypeSensor:
            urlString = [NSString stringWithFormat:@"http://www.gemdalehome.com:8089/h5/%@/#/",@"sensor"];
            break;
        default:
            break;
    }
    if (parameter.allValues.count > 0) {
        urlString = [NSString stringWithFormat:@"%@?%@",urlString,[parameter URLQueryString]];
    }
    return [NSURL URLWithString:urlString];
}

- (void)newNavbarRightButWithTitle:(NSString*)title block:(void(^)(id response))callBack{
    if (title) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:title style:UIBarButtonItemStyleDone target:self action:@selector(touchNavbarRightBut)];
        self.navbarRightButBlock = callBack;
    }else{
        self.navigationItem.rightBarButtonItem = nil;
        self.navbarRightButBlock = nil;
    }
}

- (void)touchNavbarRightBut{
    self.navbarRightButBlock(nil);
}

-(instancetype)init{
    self = [super init];
    if (self) {
        self.navigationType = LYWebViewControllerNavigationBarItem;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //删除关闭按钮
    self.navigationCloseItem = [[UIBarButtonItem alloc] initWithTitle:nil style:0 target:nil action:nil];
    
    WKUserScript *usrScript = [[WKUserScript alloc] initWithSource:[JKEventHandler shareInstance].handlerJS injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    // 通过JS与webview内容交互
    self.webView.configuration.userContentController = [[WKUserContentController alloc] init];
    [self.webView.configuration.userContentController addUserScript:usrScript];
    [JKEventHandler shareInstance].webView = self.webView;
    // 注入JS对象名称AppModel，当JS通过AppModel来调用时，
    // 我们可以在WKScriptMessageHandler代理中接收到
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types-discards-qualifiers"
    [self.webView.configuration.userContentController addScriptMessageHandler:[JKEventHandler shareInstance] name:EventHandler];
#pragma clang diagnostic
}

-(void)dealloc{
     [JKEventHandler shareInstance].webView = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types-discards-qualifiers"
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:EventHandler];
#pragma clang diagnostic
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
