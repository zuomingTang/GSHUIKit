//
//  GSHInfraredControllerInfoVC.h
//  SmartHome
//
//  Created by gemdale on 2019/2/21.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHInfraredControllerInfoVCCell : UITableViewCell
@property(nonatomic,strong)GSHKuKongInfraredDeviceM *device;
@end

@interface GSHInfraredControllerInfoVC : UIViewController
+(instancetype)infraredControllerInfoVCWithDevice:(GSHDeviceM*)device;
@end

