//
//  GSHFamilyManagerVC.m
//  SmartHome
//
//  Created by gemdale on 2018/5/17.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHFamilyManagerVC.h"
#import "UIImageView+WebCache.h"
#import "GSHInputTextVC.h"
#import "GSHAlertManager.h"
#import "GSHFamilyMemberListVC.h"
#import "GSHRoomManagerVC.h"
#import "UITextField+TZM.h"
#import "GSHPickerViewManager.h"
#import <AVFoundation/AVFoundation.h>
#import "NSString+TZM.h"
#import "GSHFamilyMemberAuthorityVC.h"
#import "GSHFamilyTransferVC.h"

@interface GSHFamilyManagerCell ()
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblText;
@property (weak, nonatomic) IBOutlet UIImageView *imageviewHead;
@property (weak, nonatomic) IBOutlet UILabel *lblLeftText;
@property (weak, nonatomic) IBOutlet UITextField *tfInput;
-(void)setTitle:(NSString*)title text:(NSString*)text imageUrl:(NSURL*)imageUrl leftText:(NSString*)leftText inputText:(NSString*)inputText inputPlaceholderText:(NSString*)inputPlaceholderText accessoryType:(UITableViewCellAccessoryType)type;
@end

@implementation GSHFamilyManagerCell
-(void)setTitle:(NSString*)title text:(NSString*)text imageUrl:(NSURL*)imageUrl leftText:(NSString*)leftText inputText:(NSString*)inputText inputPlaceholderText:(NSString*)inputPlaceholderText accessoryType:(UITableViewCellAccessoryType)type{
    self.lblTitle.text = title;
    self.accessoryType = type;
    if (imageUrl) {
        [self.imageviewHead sd_setImageWithURL:imageUrl];
        self.imageviewHead.hidden = NO;
    }else{
        self.imageviewHead.hidden = YES;
    }
    if (text) {
        self.lblText.text = text;
        self.lblText.hidden = NO;
    }else{
        self.lblText.hidden = YES;
    }
    if (leftText) {
        self.lblLeftText.text = leftText;
        self.lblLeftText.hidden = NO;
    }else{
        self.lblLeftText.hidden = YES;
    }
    if (inputText) {
        self.tfInput.text = inputText;
        self.tfInput.placeholder = inputPlaceholderText;
        self.tfInput.z_placeholderColor = @"#999999";
        self.tfInput.hidden = NO;
    }else{
        self.tfInput.hidden = YES;
    }
}
@end

@interface GSHFamilyManagerVC ()<UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property(nonatomic,strong)GSHFamilyM *family;
@property(nonatomic,weak)GSHFamilyListVC *familyListVC;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *butDeleteFamily;
- (IBAction)touchDeleteFamily:(UIButton *)sender;
- (IBAction)touchSave:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnTransfer;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
- (IBAction)touchChangeManager:(UIButton *)sender;

@property(nonatomic,strong)GSHFamilyM *changefamily;
@property(nonatomic,weak)UITextField *tfName;
@property(nonatomic,weak)UITextField *tfAddress;
@property(nonatomic,strong)NSArray<GSHPrecinctM *> *precinctList;
@property(nonatomic,strong)UIPickerView *pickerView;
@property(nonatomic,strong)GSHPrecinctM *selePrecinctM;
//@property(nonatomic,assign)BOOL isChange;
@end

@implementation GSHFamilyManagerVC

+(instancetype)familyManagerVCWithFamily:(GSHFamilyM*)family familyListVC:(GSHFamilyListVC*)familyListVC;{
    GSHFamilyManagerVC *vc = [TZMPageManager viewControllerWithSB:@"GSHFamilySB" andID:@"GSHFamilyManagerVC"];
    vc.family = family;
    vc.familyListVC = familyListVC;
    return vc;
}

-(void)setFamily:(GSHFamilyM *)family{
    _family = family;
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.btnSave.hidden = self.family.permissions == GSHFamilyMPermissionsMember;
    [self.butDeleteFamily setTitle:self.family.permissions == GSHFamilyMPermissionsMember ? @"解绑家庭" : @"删除家庭" forState:UIControlStateNormal];
    self.btnTransfer.hidden = self.family.permissions == GSHFamilyMPermissionsMember;
    self.changefamily = [GSHFamilyM new];
    [self.changefamily copyCommonData:self.family];
    [self observerNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [self removeNotifications];
}

-(void)observerNotifications{
    [self observerNotification:UITextFieldTextDidChangeNotification];
}

-(void)handleNotifications:(NSNotification *)notification{
    if ([notification.name isEqualToString:UITextFieldTextDidChangeNotification]) {
        if (notification.object == self.tfName){
            UITextField *textField = (UITextField *)notification.object;
            [self wordLimitWithTextField:textField wordMaxNumber:16];
            self.changefamily.familyName = textField.text;
        }
        if (notification.object == self.tfAddress){
            UITextField *textField = (UITextField *)notification.object;
            self.changefamily.address = textField.text;
        }
    }
}

-(void)wordLimitWithTextField:(UITextField*)textField wordMaxNumber:(NSInteger)maxNumber{
    NSString *toBeString = textField.text;
    UITextRange *selectedRange = [textField markedTextRange];
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!selectedRange || [selectedRange isEmpty]){
        if (toBeString.length > maxNumber) {
            [SVProgressHUD showErrorWithStatus:[[NSString alloc]initWithFormat:@"输入不得超过%d个字",(int)maxNumber]];
            textField.text = [toBeString substringToIndex:maxNumber];
        }
    }
}

-(void)changeFamilyArea{
    __weak typeof(self)weakSelf = self;
    if (self.precinctList) {
        [self showPickerView];
    }else{
        [SVProgressHUD showWithStatus:@"获取辖区列表中"];
        [GSHFamilyManager getPrecinctListWithblock:^(NSArray<GSHPrecinctM *> *precinctList, NSError *error) {
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                [SVProgressHUD dismiss];
                weakSelf.precinctList = precinctList;
                [weakSelf showPickerView];
            }
        }];
    }
}

-(void)showPickerView{
    __weak typeof(self)weakSelf = self;
    [GSHPickerViewManager showPrecinctPickerViewWithPrecinctList:self.precinctList completion:^(GSHPrecinctM *districtModel, NSString *address) {
        weakSelf.selePrecinctM = districtModel;
        weakSelf.changefamily.projectName = address;
        weakSelf.changefamily.project = districtModel.precinctId;
        [weakSelf.tableView reloadData];
    }];
}

-(void)changeFamilyImage{
    
    __weak typeof(self)weakSelf = self;
    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
        if (buttonIndex == 1 || buttonIndex == 2) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.allowsEditing = YES;
            picker.delegate = weakSelf;
            if (buttonIndex == 1) {
                // 拍照
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
                if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied) {
                    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                    } textFieldsSetupHandler:NULL andTitle:@"没有相机权限" andMessage:@"请到系统设置里设置，设置->隐私->相机，打开应用权限" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:nil otherButtonTitles:@"已经打开",@"取消",nil];
                    return;
                }
            } else if (buttonIndex == 2) {
                // 从相册选择
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
            [weakSelf presentViewController:picker animated:YES completion:^{
            }];
        }
    } textFieldsSetupHandler:^(UITextField *textField, NSUInteger index) {
        
    } andTitle:@"" andMessage:nil image:nil preferredStyle:GSHAlertManagerStyleActionSheet destructiveButtonTitle:@"" cancelButtonTitle:@"取消" otherButtonTitles:@"拍照",@"从相册选择",nil];
}

- (IBAction)touchDeleteFamily:(UIButton *)sender {
    __weak typeof(self)weakSelf = self;
    // 删除家庭
    if ([[GSHOpenSDK share].currentFamily.familyId isEqualToString:self.family.familyId]) {
        [SVProgressHUD showErrorWithStatus:self.family.permissions == GSHFamilyMPermissionsMember ? @"不能解绑当前家庭，请切换家庭" : @"不能删除当前家庭，请切换家庭"];
        return;
    }
    [SVProgressHUD showWithStatus:self.family.permissions == GSHFamilyMPermissionsMember ? @"解绑中" : @"删除中"];
    [GSHFamilyManager postDeleteFamilyWithFamilyId:self.family.familyId block:^(NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }else{
            [SVProgressHUD showSuccessWithStatus:self.family.permissions == GSHFamilyMPermissionsMember ? @"解绑成功" : @"删除成功"];
            [weakSelf.familyListVC.list removeObject:weakSelf.family];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (IBAction)touchSave:(UIButton *)sender {
    __weak typeof(self)weakSelf = self;
    if (self.changefamily.address.length > 50) {
        [SVProgressHUD showErrorWithStatus:@"详细地址不得超过50个字"];
        return;
    }
    if ([self.changefamily.familyName judgeTheillegalCharacter]) {
        [SVProgressHUD showErrorWithStatus:@"家庭名不能输入特殊字符"];
        return;
    }
    if ([self.changefamily.address judgeTheillegalCharacter]) {
        [SVProgressHUD showErrorWithStatus:@"详细地址不能输入特殊字符"];
        return;
    }
    [SVProgressHUD showWithStatus:@"保存设置中"];
    [GSHFamilyManager postUpdateFamilyWithFamilyId:weakSelf.family.familyId familyName:weakSelf.changefamily.familyName familyPic:weakSelf.changefamily.picPath project:weakSelf.changefamily.project.stringValue projectName:weakSelf.changefamily.projectName address:weakSelf.changefamily.address block:^(GSHFamilyM *family, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }else{
            [SVProgressHUD dismiss];
            family.projectName = weakSelf.changefamily.projectName;
            [weakSelf.family copyCommonData:family];
            [weakSelf.changefamily copyCommonData:family];
//            [weakSelf.tableView reloadData];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
}

#pragma mark-- tableViewDelegat

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 4;
    }else{
        if ([self.family permissions] == GSHFamilyMPermissionsManager) {
            return 3;
        }else{
            return 1;
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44)];
    view.backgroundColor = [UIColor colorWithRGB:0xf6f7fa];
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(15, 16, tableView.frame.size.width - 30, 20)];
    lable.font = [UIFont systemFontOfSize:14];
    lable.textColor = [UIColor colorWithHexString:@"#999999"];
    if (section == 0) {
        lable.text = @"家庭基础信息管理";
    }else{
        lable.text = @"家庭权限信息管理";
    }
    [view addSubview:lable];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHFamilyManagerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            if ([self.family permissions] == GSHFamilyMPermissionsManager) {
                [cell setTitle:@"家庭名称" text:nil imageUrl:nil leftText:nil inputText:self.changefamily.familyName inputPlaceholderText:@"请输入名称" accessoryType:UITableViewCellAccessoryNone];
            }else{
                [cell setTitle:@"家庭名称" text:self.family.familyName imageUrl:nil leftText:nil inputText:nil inputPlaceholderText:@"请输入名称" accessoryType:UITableViewCellAccessoryNone];
            }
            self.tfName = cell.tfInput;
        }else if (indexPath.row == 1){
            if ([self.family permissions] == GSHFamilyMPermissionsManager) {
                [cell setTitle:@"家庭头像" text:nil imageUrl:[NSURL URLWithString:self.changefamily.picPath] leftText:nil inputText:nil inputPlaceholderText:nil accessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }else{
                [cell setTitle:@"家庭头像" text:nil imageUrl:[NSURL URLWithString:self.family.picPath] leftText:nil inputText:nil inputPlaceholderText:nil accessoryType:UITableViewCellAccessoryNone];
            }
        }else if (indexPath.row == 2){
            if ([self.family permissions] == GSHFamilyMPermissionsManager) {
                [cell setTitle:@"所在地区" text:self.changefamily.projectName imageUrl:nil leftText:nil inputText:nil inputPlaceholderText:nil accessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }else{
                [cell setTitle:@"所在地区" text:self.family.projectName imageUrl:nil leftText:nil inputText:nil inputPlaceholderText:nil accessoryType:UITableViewCellAccessoryNone];
            }
        }else if (indexPath.row == 3){
            if ([self.family permissions] == GSHFamilyMPermissionsManager) {
                [cell setTitle:@"详细地址" text:nil imageUrl:nil leftText:nil inputText:self.changefamily.address ? self.changefamily.address : @"" inputPlaceholderText:@"请输入详细地址" accessoryType:UITableViewCellAccessoryNone];
            }else{
                [cell setTitle:@"详细地址" text:self.family.address imageUrl:nil leftText:nil inputText:nil inputPlaceholderText:@"请输入详细地址" accessoryType:UITableViewCellAccessoryNone];
            }
            self.tfAddress = cell.tfInput;
        }else{
        }
    }else{
        if (indexPath.row == 0) {
            [cell setTitle:@"我的权限" text:nil imageUrl:nil leftText:([self.family permissions] == GSHFamilyMPermissionsManager) ? @"管理员" : @"成员" inputText:nil inputPlaceholderText:nil accessoryType:UITableViewCellAccessoryNone];
        }else if (indexPath.row == 1){
            if ([self.family permissions] == GSHFamilyMPermissionsManager) {
                [cell setTitle:@"成员管理" text:nil imageUrl:nil leftText:nil inputText:nil inputPlaceholderText:nil accessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }else{
                [cell setTitle:@"设备权限" text:nil imageUrl:nil leftText:nil inputText:nil inputPlaceholderText:nil accessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }
        }else if (indexPath.row == 2){
            [cell setTitle:@"房间管理" text:nil imageUrl:nil leftText:nil inputText:nil inputPlaceholderText:nil accessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }else{
            
        }
    }
    return cell;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHFamilyManagerCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
        if (indexPath.section == 0) {
            if(indexPath.row == 1){
                //换图片
                [self changeFamilyImage];
            }
            if (indexPath.row == 2) {
                [self changeFamilyArea];
            }
        }else if(indexPath.section == 1){
            if (indexPath.row == 1) {
                if ([self.family permissions] == GSHFamilyMPermissionsManager) {
                    //成员管理
                    [self.navigationController pushViewController:[GSHFamilyMemberListVC familyMemberListVCWithFamily:self.family] animated:YES];
                }else{
                    //设备查看
                    GSHFamilyMemberM *member = [GSHFamilyMemberM new];
                    member.familyId = self.family.familyId;
                    member.childUserId = [GSHUserManager currentUser].userId;
                    GSHFamilyMemberAuthorityVC *vc = [GSHFamilyMemberAuthorityVC familyMemberAuthorityVCWithMember:member];
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }else if(indexPath.row == 2){
                //房间管理
                [self.navigationController pushViewController:[GSHRoomManagerVC roomManagerVCWithFamily:self.family] animated:YES];
            }
        }
    }
    return nil;
}

#pragma mark-- UIImagePickerController
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    __weak typeof(self)weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:nil];
    // 从info中将图片取出，并加载到imageView当中
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [SVProgressHUD showWithStatus:@"上传中"];
    [GSHUserManager postImage:image type:GSHUploadingImageTypeFamily progress:^(NSProgress *progress) {
        [SVProgressHUD showProgress:(90.0 * progress.completedUnitCount) / (100.0 * progress.totalUnitCount) status:@"请稍候"];
    } block:^(NSString *picPath, NSError *error) {
        if (picPath) {
            [GSHFamilyManager postUpdateFamilyWithFamilyId:weakSelf.family.familyId familyName:weakSelf.changefamily.familyName familyPic:picPath project:weakSelf.changefamily.project.stringValue projectName:weakSelf.changefamily.projectName address:weakSelf.changefamily.address block:^(GSHFamilyM *family, NSError *error) {
                if (error) {
                    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                }else{
                    [SVProgressHUD dismiss];
                    [weakSelf.family copyCommonData:family];
                    [weakSelf.changefamily copyCommonData:family];
                    [weakSelf.tableView reloadData];
                }
            }];
        }else{
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
}

// 取消选取调用的方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)touchChangeManager:(UIButton *)sender {
    GSHFamilyTransferVC *vc = [GSHFamilyTransferVC familyTransferVCWithFamily:self.family];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
