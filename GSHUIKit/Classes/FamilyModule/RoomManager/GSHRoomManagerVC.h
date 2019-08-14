//
//  GSHRoomManagerVC.h
//  SmartHome
//
//  Created by gemdale on 2018/5/22.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHRoomManagerFooterView : UITableViewHeaderFooterView
@property(nonatomic,strong)GSHFloorM *floor;
@end

@interface GSHRoomManagerHeaderView : UITableViewHeaderFooterView
@property(nonatomic,strong)GSHFloorM *floor;
@property(nonatomic,copy)NSString *familyId;
@end

@interface GSHRoomManagerCell : UITableViewCell
@property(nonatomic,strong)GSHRoomM *room;
@end

@interface GSHRoomManagerVC : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;

+(instancetype)roomManagerVCWithFamily:(GSHFamilyM*)family;

//编辑某个楼层的某个房间，楼层不能为空。房间可以为空，如果房间为空则为添加
-(void)editRoomWithFloor:(GSHFloorM*)floor room:(GSHRoomM*)room;
//编辑某个楼层，楼层可以为空，为空的时候为添加楼层
-(void)editFloorWithFloor:(GSHFloorM*)floor;

-(void)deleteFloorWithFloor:(GSHFloorM*)floor;
@end
