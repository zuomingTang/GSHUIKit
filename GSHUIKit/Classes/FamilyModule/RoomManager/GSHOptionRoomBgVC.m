//
//  GSHOptionRoomBgVC.m
//  SmartHome
//
//  Created by gemdale on 2018/5/23.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHOptionRoomBgVC.h"

@interface GSHOptionRoomBgCell ()
@end

@implementation GSHOptionRoomBgCell
@end

@interface GSHOptionRoomBgVC ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (copy, nonatomic) void(^block)(NSString *bgId,UIImage *image);
@end

@implementation GSHOptionRoomBgVC

+(instancetype)optionRoomBgVCWithBlock:(void(^)(NSString *bgId,UIImage *image))block{
    GSHOptionRoomBgVC *vc = [TZMPageManager viewControllerWithSB:@"GSHRoomManagerSB" andID:@"GSHOptionRoomBgVC"];
    vc.block = block;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 12;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    GSHOptionRoomBgCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.imageViewBg.image = [GSHRoomM getBackgroundImageWithId:(int)indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = (collectionView.frame.size.width - 60) / 3;
    return CGSizeMake(width, width / 105 * 187);
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if (self.block) {
        self.block(@(indexPath.row).stringValue, ((GSHOptionRoomBgCell*)cell).imageViewBg.image);
    }
    [self.navigationController popViewControllerAnimated:YES];
    return NO;
}

@end
