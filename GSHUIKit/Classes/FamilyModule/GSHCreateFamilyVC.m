//
//  GSHCreateFamilyVC.m
//  SmartHome
//
//  Created by gemdale on 2018/5/17.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHCreateFamilyVC.h"
#import "GSHAlertManager.h"
#import "GSHPickerViewManager.h"
#import <AVFoundation/AVFoundation.h>
#import "NSString+TZM.h"

@interface GSHCreateFamilyVC ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong)NSString *picPath;
@property (nonatomic, weak)GSHFamilyListVC *familyListVC;
@property(nonatomic,strong)NSArray<GSHPrecinctM *> *precinctList;
@property(nonatomic,strong)UIPickerView *pickerView;
@property(nonatomic,strong)GSHPrecinctM *selePrecinctM;

@property (weak, nonatomic) IBOutlet UITextField *tfName;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewHead;
@property (weak, nonatomic) IBOutlet UIButton *btnCreate;
@property (weak, nonatomic) IBOutlet UILabel *lblCity;
- (IBAction)touchCreate:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextField *tfAddress;

@property (copy, nonatomic) void (^completeBlock)(void);

@end

@implementation GSHCreateFamilyVC
+(instancetype)createFamilyVCWithFamilyListVC:(GSHFamilyListVC*)familyListVC completeBlock:(void(^)(void))completeBlock {
    GSHCreateFamilyVC *vc = [TZMPageManager viewControllerWithSB:@"GSHFamilySB" andID:@"GSHCreateFamilyVC"];
    vc.familyListVC = familyListVC;
    vc.completeBlock = completeBlock;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self observerNotifications];
    self.btnCreate.enabled = NO;
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
        }
        [self refreshCreateBut];
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

-(void)refreshCreateBut{
    self.btnCreate.enabled = self.tfName.text.length > 0 && self.picPath.length > 0 && self.tfAddress.text.length > 0 && self.lblCity.text.length > 0;
}

- (void)touchHeadImage {
    [self.view endEditing:YES];
    
    @weakify(self)
    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
        @strongify(self)
        if (buttonIndex == 1 || buttonIndex == 2) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.allowsEditing = YES;
            picker.delegate = self;
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
            [self presentViewController:picker animated:YES completion:^{
            }];
        }
    } textFieldsSetupHandler:^(UITextField *textField, NSUInteger index) {
        
    } andTitle:@"" andMessage:nil image:nil preferredStyle:GSHAlertManagerStyleActionSheet destructiveButtonTitle:@"" cancelButtonTitle:@"取消" otherButtonTitles:@"拍照",@"从相册选择",nil];
}

-(void)seleAddress{
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
        weakSelf.lblCity.text = address;
        [weakSelf refreshCreateBut];
    }];
}

- (IBAction)touchCreate:(UIButton *)sender {
    if (self.tfAddress.text.length > 50) {
        [SVProgressHUD showErrorWithStatus:@"详细地址不得超过50个字"];
        return;
    }
    if ([self.tfAddress.text judgeTheillegalCharacter]) {
        [SVProgressHUD showErrorWithStatus:@"详细地址不能输入特殊字符"];
        return;
    }
    if ([self.tfName.text judgeTheillegalCharacter]) {
        [SVProgressHUD showErrorWithStatus:@"家庭名不能输入特殊字符"];
        return;
    }
    [SVProgressHUD showWithStatus:@"创建中"];
    __weak typeof(self) weakSelf = self;
    [GSHFamilyManager postSetFamilyWithFamilyName:self.tfName.text familyPic:self.picPath project:self.selePrecinctM.precinctId.stringValue address:self.tfAddress.text block:^(GSHFamilyM *family, NSError *error) {
        if (family) {
            [SVProgressHUD dismiss];
            family.projectName = weakSelf.lblCity.text;
            [weakSelf.familyListVC.list addObject:family];
            if (weakSelf.completeBlock) {
                weakSelf.completeBlock();
            }
//            [weakSelf.navigationController popViewControllerAnimated:YES];
        }else{
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
}

#pragma --mark imagePicker

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    __weak typeof(self)weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:nil];
    // 从info中将图片取出，并加载到imageView当中
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [SVProgressHUD showWithStatus:@"上传中"];
    [GSHUserManager postImage:image type:GSHUploadingImageTypeFamily progress:^(NSProgress *progress) {
        [SVProgressHUD showProgress:(100.0 * progress.completedUnitCount) / (100.0 * progress.totalUnitCount) status:@"请稍候"];
    } block:^(NSString *picPath, NSError *error) {
        if (picPath) {
            weakSelf.picPath = picPath;
            weakSelf.imageViewHead.image = image;
            [weakSelf refreshCreateBut];
            [SVProgressHUD dismiss];
        }else{
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
}

// 取消选取调用的方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma --mark tableView

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 || (indexPath.section == 2 && indexPath.row == 1)) {
        return NO;
    }
    return YES;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        [self touchHeadImage];
    }
    if (indexPath.section == 2 && indexPath.row == 0) {
        [self seleAddress];
    }
    return nil;
}
@end
