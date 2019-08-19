//
//  GSHRoomManagerVC.m
//  SmartHome
//
//  Created by gemdale on 2018/5/22.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHRoomManagerVC.h"
#import "UIView+TZM.h"
#import "GSHRoomEditVC.h"
#import "GSHFloorEditVC.h"
#import "GSHAlertManager.h"
#import "UIViewController+TZMPageStatusViewEx.h"
#import "GSHRoomRankVC.h"

@interface GSHRoomManagerFooterView()
@end
@implementation GSHRoomManagerFooterView{
    UIButton *_addRoomBut;
}

-(instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        _addRoomBut = [[UIButton alloc]init];
        [_addRoomBut addTarget:self action:@selector(touchAdd) forControlEvents:UIControlEventTouchUpInside];
        [_addRoomBut setTitle:@"添加房间" forState:UIControlStateNormal];
        _addRoomBut.layer.cornerRadius = 18;
        _addRoomBut.titleLabel.font = [UIFont systemFontOfSize:16];
        _addRoomBut.clipsToBounds = YES;
        _addRoomBut.layer.borderWidth = 1;
        _addRoomBut.layer.borderColor = [UIColor colorWithHexString:@"#1c93ff"].CGColor;
        [_addRoomBut setTitleColor:[UIColor colorWithHexString:@"#1c93ff"] forState:UIControlStateNormal];
        [self.contentView addSubview:_addRoomBut];
        
        self.backgroundView = [UIView new];
        self.backgroundView.backgroundColor = [UIColor colorWithRGB:0xf6f7fa];
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    _addRoomBut.frame = CGRectMake((self.frame.size.width - 160) / 2, 12, 160, 36);
    self.contentView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 10);
}

-(void)touchAdd{
    if ([self.viewController isKindOfClass:GSHRoomManagerVC.class]) {
        [((GSHRoomManagerVC*)self.viewController) editRoomWithFloor:self.floor room:nil];
    }
}

@end

@interface GSHRoomManagerHeaderView()
@end
@implementation GSHRoomManagerHeaderView{
//    UIButton *_showBut;
    UIButton *_rankBut;
    UILabel *_lblName;
    UIButton *_editBut;
//    UIImageView *_imageview;
    UIView *_lineView;
}

-(void)setFloor:(GSHFloorM *)floor{
    _floor = floor;
    _lblName.text = floor.floorName;
//    _imageview.highlighted = self.floor.hide;
}

-(instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
//        //收缩展开按钮
//        _showBut = [[UIButton alloc]init];
//        [_showBut addTarget:self action:@selector(touchShowOrHide) forControlEvents:UIControlEventTouchUpInside];
//        [self.contentView addSubview:_showBut];
        
        //排序按钮
        _rankBut = [[UIButton alloc]init];
        [_rankBut addTarget:self action:@selector(touchRank) forControlEvents:UIControlEventTouchUpInside];
        [_rankBut setImage:[UIImage imageNamed:@"roomManagerVC_rank_icon"] forState:UIControlStateNormal];
        [self.contentView addSubview:_rankBut];
        
        //楼层名字
        _lblName = [[UILabel alloc]init];
        _lblName.font = [UIFont systemFontOfSize:18];
        _lblName.textColor = [UIColor colorWithHexString:@"#282828"];
        [self.contentView addSubview:_lblName];
        //编辑按钮
        _editBut = [[UIButton alloc]init];
        [_editBut addTarget:self action:@selector(touchEdit) forControlEvents:UIControlEventTouchUpInside];
        [_editBut setTitle:@"" forState:UIControlStateNormal];
        [_editBut setImage:[UIImage imageNamed:@"roomManagerVC_delete_floor_icon"] forState:UIControlStateNormal];
        [self.contentView addSubview:_editBut];
        
//        //箭头
//        _imageview = [[UIImageView alloc]init];
//        _imageview.image = [UIImage imageNamed:@"roomManagerVC_show_room_icon"];
//        _imageview.highlightedImage = [UIImage imageNamed:@"roomManagerVC_hide_room_icon"];
//        [self.contentView addSubview:_imageview];
        
        _lineView = [[UIView alloc]init];
        _lineView.backgroundColor = [UIColor colorWithHexString:@"#dedede"];
        [self.contentView addSubview:_lineView];
        
        self.backgroundView = [UIView new];
        self.backgroundView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
//    _showBut.frame = self.contentView.frame;
    CGSize size = [_lblName.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:_lblName.font,NSFontAttributeName,nil]];
    CGFloat witdh = size.width > 200 ? 200 : size.width;
    _lblName.frame = CGRectMake(15, (self.contentView.frame.size.height - 25) / 2, witdh, 25);
    _editBut.frame = CGRectMake(15 + witdh + 10, (self.contentView.frame.size.height - 22) / 2, 22, 22);
//    _imageview.frame = CGRectMake(self.contentView.frame.size.width - 24 - 15,
    _rankBut.frame = CGRectMake(self.contentView.frame.size.width - 44 - 5,(self.contentView.frame.size.height - 44) / 2, 44, 44);
    _lineView.frame = CGRectMake(0, self.contentView.frame.size.height - 0.5, self.contentView.frame.size.width, 0.5);
}

-(void)touchEdit{
    if ([self.viewController isKindOfClass:GSHRoomManagerVC.class]) {
        __weak typeof(self)weakSelf = self;
        [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
            if (buttonIndex == 0) {
                [((GSHRoomManagerVC*)weakSelf.viewController) deleteFloorWithFloor:weakSelf.floor];
            }
        } textFieldsSetupHandler:NULL andTitle:nil andMessage:[NSString stringWithFormat:@"确认删除%@吗？",self.floor.floorName] image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:@"确认" cancelButtonTitle:@"取消" otherButtonTitles:nil];
    }
}

-(void)touchRank{
    [self.navigationController pushViewController:[GSHRoomRankVC roomRankVCWithFloor:self.floor familyId:self.familyId] animated:YES];
}

//-(void)touchShowOrHide{
//    self.floor.hide = !self.floor.hide;
//    if ([self.viewController isKindOfClass:GSHRoomManagerVC.class]) {
//        [((GSHRoomManagerVC*)self.viewController).tableView reloadData];
//    }
//}

@end

@interface GSHRoomManagerCell()
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblOnLineDevice;
@property (weak, nonatomic) IBOutlet UILabel *lblAllDevice;
@end

@implementation GSHRoomManagerCell
-(void)setRoom:(GSHRoomM *)room{
    _room = room;
    self.lblName.text = room.roomName;
    self.lblAllDevice.text = [NSString stringWithFormat:@"/%d",room.deviceCount.intValue];
    self.lblOnLineDevice.text = [NSString stringWithFormat:@"%d在线",room.onlineDeviceCount.intValue];
}
@end

@interface GSHRoomManagerVC ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)GSHFamilyM *family;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
- (IBAction)touchAddFloor:(UIButton *)sender;
@end

@implementation GSHRoomManagerVC

+(instancetype)roomManagerVCWithFamily:(GSHFamilyM*)family{
    GSHRoomManagerVC *vc = [TZMPageManager viewControllerWithSB:@"GSHRoomManagerSB" andID:@"GSHRoomManagerVC"];
    vc.family = family;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:GSHRoomManagerFooterView.class forHeaderFooterViewReuseIdentifier:@"footer"];
    [self.tableView registerClass:GSHRoomManagerHeaderView.class forHeaderFooterViewReuseIdentifier:@"header"];
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    if (self.family.floor.count == 1 && self.family.floor.firstObject.rooms.count == 0){
        GSHFloorM *floor = self.family.floor.firstObject;
        [self showPageStatus:TZMPageStatusNormal image:[UIImage imageNamed:@"blankpage_icon_room"] title:nil desc:@"暂无房间" buttonText:@"添加房间" didClickButtonCallback:^(TZMPageStatus status) {
            [self editRoomWithFloor:floor room:nil];
        }];
    }else{
        [self dismissPageStatusView];
    }
}

- (void)reloadData{
    __weak typeof(self)weakSelf = self;
    [self dismissPageStatusView];
    [SVProgressHUD showWithStatus:@"加载中"];
    [GSHFloorManager getFloorListWithFamilyId:self.family.familyId block:^(NSArray<GSHFloorM *> *floorList, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }else{
            if (floorList.count == 1 && floorList.firstObject.rooms.count == 0) {
                [SVProgressHUD dismiss];
                GSHFloorM *floor = floorList.firstObject;
                [weakSelf showPageStatus:TZMPageStatusNormal image:[UIImage imageNamed:@"blankpage_icon_room"] title:nil desc:@"暂无房间" buttonText:@"添加房间" didClickButtonCallback:^(TZMPageStatus status) {
                    [weakSelf editRoomWithFloor:floor room:nil];
                }];
            }else{
                if (floorList) {
                    [SVProgressHUD dismiss];
                    weakSelf.family.floor = [NSMutableArray arrayWithArray:floorList];
                    [weakSelf.tableView reloadData];
                }else{
                    [SVProgressHUD showErrorWithStatus:@"暂无楼层信息"];
                }
            }
        }
    }];
}

-(void)editRoomWithFloor:(GSHFloorM*)floor room:(GSHRoomM*)room{
    GSHRoomEditVC *vc = [GSHRoomEditVC roomEditVCWithFamily:self.family floor:floor room:room];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)deleteFloorWithFloor:(GSHFloorM*)floor{
    __weak typeof(self) weakSelf = self;
    [SVProgressHUD showWithStatus:@"删除中"];
    [GSHFloorManager postDeleteFloorWithFamilyId:weakSelf.family.familyId floorId:floor.floorId block:^(NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }else{
            [SVProgressHUD showSuccessWithStatus:@"删除成功"];
            [weakSelf.family.floor removeObject:floor];
            if (weakSelf.family.floor.count == 1 && weakSelf.family.floor.firstObject.rooms.count == 0) {
                GSHFloorM *floor = weakSelf.family.floor.firstObject;
                [weakSelf showPageStatus:TZMPageStatusNormal image:[UIImage imageNamed:@"blankpage_icon_room"] title:nil desc:@"暂无房间" buttonText:@"添加房间" didClickButtonCallback:^(TZMPageStatus status) {
                    [weakSelf editRoomWithFloor:floor room:nil];
                }];
            }else{
                [weakSelf.tableView reloadData];
            }
        }
    }];
}

-(void)editFloorWithFloor:(GSHFloorM*)floor{
    GSHFloorEditVC *vc = [GSHFloorEditVC floorEditVCWithFamily:self.family floor:floor];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark --tableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    self.btnAdd.hidden = self.family.floor.count >= 6;
    return self.family.floor.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.family.floor.count > section) {
        GSHFloorM *floor = self.family.floor[section];
//        if (floor.hide) {
//            return 0;
//        }else{
            return floor.rooms.count;
//        }
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHRoomManagerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (self.family.floor.count > indexPath.section) {
        if (self.family.floor[indexPath.section].rooms.count > indexPath.row) {
            cell.room = self.family.floor[indexPath.section].rooms[indexPath.row];
        }
    }
    return cell;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.family.floor.count > indexPath.section) {
        GSHFloorM *floor = self.family.floor[indexPath.section];
        if (floor.rooms.count > indexPath.row) {
            GSHRoomM *room = floor.rooms[indexPath.row];
            if (room) {
                [self editRoomWithFloor:floor room:room];
            }
        }
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    GSHRoomManagerHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    if (self.family.floor.count > section) {
        GSHFloorM *floor = self.family.floor[section];
        header.floor = floor;
        header.familyId = self.family.familyId;
    }
    return header;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    if (self.family.floor.count > section) {
//        GSHFloorM *floor = self.family.floor[section];
//        if (floor.hide) {
//            return 0;
//        }else{
            return 70;
//        }
//    }
//    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
//    if (self.family.floor.count > section) {
//        GSHFloorM *floor = self.family.floor[section];
//        if (floor.hide) {
//            return nil;
//        }else{
            GSHRoomManagerHeaderView *footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"footer"];
            if (self.family.floor.count > section) {
                GSHFloorM *floor = self.family.floor[section];
                footer.floor = floor;
            }
            return footer;
//        }
//    }
//    return nil;
}

- (IBAction)touchAddFloor:(UIButton *)sender {
    [self editFloorWithFloor:nil];
}
@end
