//
//  GSHAboutVC.m
//  SmartHome
//
//  Created by gemdale on 2018/5/16.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHAboutVC.h"
#import "GSHWebViewController.h"
#import "GSHAlertManager.h"

@interface GSHAboutVC ()
@property (weak, nonatomic) IBOutlet UILabel *lblVersions;
- (IBAction)changeEnvironment:(UIButton *)sender;
@end

@implementation GSHAboutVC{
    NSInteger _touchChangeEnvironmentCount;
}

+(instancetype)aboutVC{
    GSHAboutVC *vc = [TZMPageManager viewControllerWithSB:@"GSHSettingSB" andID:@"GSHAboutVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lblVersions.text = [NSString stringWithFormat:@"当前版本 V%@",[NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        NSMutableDictionary<NSString *,id> *dict = [NSMutableDictionary dictionary];
        GSHUserM *user = [GSHUserManager currentUser];
        if (user.userId.length > 0) {
            [dict setValue:user.userId forKey:@"userId"];
        }
        if (user.sessionId.length > 0) {
            [dict setValue:user.sessionId forKey:@"sessionId"];
        }

        NSURL *url = [GSHWebViewController webUrlWithType:GSHAppConfigH5TypeFeedback parameter:dict];
        [self.navigationController pushViewController:[[GSHWebViewController alloc] initWithURL:url] animated:YES];
//        [self.navigationController pushViewController:[GSHIdeaVC ideaVC] animated:YES];
    } else {
    }
    return nil;
}

- (IBAction)changeEnvironment:(UIButton *)sender {
    if (_touchChangeEnvironmentCount > 6) {
//        [GSHAppConfig showChangeAlertViewWithVC:self];
    }else{
        _touchChangeEnvironmentCount++;
    }
}
@end
