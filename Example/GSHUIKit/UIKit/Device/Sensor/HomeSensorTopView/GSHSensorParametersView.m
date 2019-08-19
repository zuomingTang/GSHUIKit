//
//  GSHSensorParametersView.m
//  SmartHome
//
//  Created by gemdale on 2018/11/12.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import "GSHSensorParametersView.h"
#import "Masonry.h"

@interface GSHSensorParametersView ()
@property(nonatomic,strong)NSMutableArray<UILabel*> *parametersLabel;
@end

@implementation GSHSensorParametersView

-(void)refreshWithSensor:(GSHSensorM*)sensor{
    for (UILabel *label in self.parametersLabel) {
        label.text = @"";
    }
    for (int i = 0; i < sensor.showAttributeList.count; i++) {
        GSHSensorMonitorM *model = sensor.showAttributeList[i];
        if (model.showMeteStr.length > 0){
            if (i * 2 < self.parametersLabel.count) {
                self.parametersLabel[i * 2].text = model.showMeteStr;
            }
            if (i * 2 + 1 < self.parametersLabel.count ) {
                self.parametersLabel[i * 2 + 1].text = model.unit?model.unit:@"";
            }
        }
    }
}

+(GSHSensorParametersView*)sensorParametersViewWithBigFont:(UIFont*)bigFont littleFont:(UIFont*)littleFont space:(CGFloat)space count:(NSInteger)count;{
    GSHSensorParametersView *view = [GSHSensorParametersView new];
    view.parametersLabel = [NSMutableArray array];
    __weak GSHSensorParametersView *weakView = view;
    __weak UILabel *previousView;
    
    for (int i = 0; i < count; i++) {
        UILabel *zhiLab = [UILabel new];
        zhiLab.font = bigFont;
        zhiLab.textColor = [UIColor whiteColor];
//        zhiLab.text = @"值";
        [view addSubview:zhiLab];
        
        [zhiLab mas_makeConstraints:^(MASConstraintMaker *make) {
            if (previousView) {
                make.left.equalTo(previousView.mas_right).offset(space);
                make.baseline.equalTo(previousView.mas_baseline);
            }else{
                make.left.equalTo(weakView);
                make.centerY.equalTo(@(0));
            }
        }];
        previousView = zhiLab;
        [weakView.parametersLabel addObject:previousView];
        
        UILabel *danWeiLab = [UILabel new];
        danWeiLab.font = littleFont;
//        danWeiLab.text = @"单位";
        danWeiLab.textColor = [UIColor whiteColor];
        [view addSubview:danWeiLab];
        
        [danWeiLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(previousView.mas_right);
            make.baseline.equalTo(previousView.mas_baseline);
        }];
        previousView = danWeiLab;
        [weakView.parametersLabel addObject:previousView];
    }
    [previousView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakView).offset(0);
    }];
    
    return view;
}

-(NSInteger)count{
    return self.parametersLabel.count / 2;
}

@end
