//
//  GSHOptionRoomBgVC.h
//  SmartHome
//
//  Created by gemdale on 2018/5/23.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHOptionRoomBgCell :UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageViewBg;
@end

@interface GSHOptionRoomBgVC : UIViewController
+(instancetype)optionRoomBgVCWithBlock:(void(^)(NSString *bgId,UIImage *image))block;
@end
