//
//  GSHViewController.m
//  GSHUIKit
//
//  Created by zuomingTang on 08/14/2019.
//  Copyright (c) 2019 zuomingTang. All rights reserved.
//

#import "GSHViewController.h"
#import "GSHFamilyListVC.h"

@interface GSHViewController ()
- (IBAction)touchFamily:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UITextField *password;
- (IBAction)login:(id)sender;

@end

@implementation GSHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[GSHOpenSDK share] setResponseBlock:^(NSError *error) {
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchFamily:(id)sender {
    [self.navigationController pushViewController:[GSHFamilyListVC familyListVC] animated:YES];
}
- (IBAction)login:(id)sender {
    [SVProgressHUD showWithStatus:@"登录中"];
    __weak typeof(self)weakSelf = self;
    [GSHUserManager postLoginWithPhoneNumber:self.phone.text passWord:self.password.text block:^(GSHUserM *user, NSError *error) {
        [SVProgressHUD dismiss];
    }];
}
@end
