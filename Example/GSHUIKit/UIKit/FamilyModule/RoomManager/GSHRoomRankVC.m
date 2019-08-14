//
//  GSHRoomRankVC.m
//  SmartHome
//
//  Created by gemdale on 2019/7/3.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHRoomRankVC.h"
#import "JXMovableCellTableView.h"

@interface GSHRoomRankVCCell ()
@property (weak, nonatomic) IBOutlet UILabel *lblRoomName;
@end

@implementation GSHRoomRankVCCell

@end

@interface GSHRoomRankVC ()<JXMovableCellTableViewDelegate,JXMovableCellTableViewDataSource>
@property(nonatomic,strong)GSHFloorM *floor;
@property(nonatomic,strong)NSMutableArray<GSHRoomM*> *rooms;
@property(nonatomic,copy)NSString *familyId;
@property (weak, nonatomic) IBOutlet JXMovableCellTableView *tableView;
- (IBAction)touchSave:(UIButton *)sender;
@end

@implementation GSHRoomRankVC

+(instancetype)roomRankVCWithFloor:(GSHFloorM*)floor familyId:(NSString*)familyId{
    GSHRoomRankVC *vc = [TZMPageManager viewControllerWithSB:@"GSHRoomManagerSB" andID:@"GSHRoomRankVC"];
    vc.floor = floor;
    vc.rooms = [floor.rooms mutableCopy];
    vc.familyId = familyId;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.gestureMinimumPressDuration = 0.5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.floor.rooms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHRoomRankVCCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (self.floor.rooms.count > indexPath.row) {
        cell.lblRoomName.text = self.floor.rooms[indexPath.row].roomName;
    }
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    return NO;
}

- (NSMutableArray *)dataSourceArrayInTableView:(JXMovableCellTableView *)tableView {
    return [NSMutableArray arrayWithArray:@[self.rooms]];
}

- (IBAction)touchSave:(UIButton *)sender {
    [SVProgressHUD showWithStatus:@"保存中"];
    __weak typeof(self)weakSelf = self;
    [GSHFloorManager postUpdataRoomRankWithRoomList:self.rooms familyId:self.familyId block:^(NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }else{
            [SVProgressHUD showSuccessWithStatus:@"保存成功"];
            weakSelf.floor.rooms = weakSelf.rooms;
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
}
@end
