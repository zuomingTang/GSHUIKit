//
//  GSHAutoTimeSetVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/5/30.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHAutoTimeSetVC.h"
#import "GSHChooseRepeatCountVC.h"
#import "GSHAddAutoVC.h"

@interface GSHAutoTimeSetVC ()

@property (weak, nonatomic) IBOutlet UIView *repeatCountView;
@property (weak, nonatomic) IBOutlet UILabel *showRepeatCountLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *showTimeLabel;

@property (strong, nonatomic) NSArray *repeatCountArray;

@property (strong, nonatomic) NSIndexSet *repeatCountIndexSet;

@end

@implementation GSHAutoTimeSetVC

+ (instancetype)autoTimeSetVC {
    GSHAutoTimeSetVC *vc = [TZMPageManager viewControllerWithSB:@"GSHAddAutomationSB" andID:@"GSHAutoTimeSetVC"];
    return vc;
}

- (void)viewDidLoad {

    [super viewDidLoad];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseRepeatCount:)];
    [self.repeatCountView addGestureRecognizer:tapGesture];
    
    self.datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
    [self.datePicker addTarget:self action:@selector(datePickerChange:) forControlEvents:UIControlEventValueChanged];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSDate *date = [dateFormatter dateFromString:self.time];
    if (!self.time) {
        date = [NSDate date];
    }
    [self.datePicker setDate:date];
    [self setShowTimeLabelTextWithDate:date];
    self.showRepeatCountLabel.text = self.repeatCount.length > 0 ? self.repeatCount : @"仅一次";
    if (self.repeatCount.length > 0) {
        self.repeatCountArray = [self.repeatCount componentsSeparatedByString:@"、"];
    }
    [self initNavigationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI
- (void)initNavigationBar {
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonClick:)];
}

#pragma mark - method
- (void)datePickerChange:(UIDatePicker *)datePicker {
    [self setShowTimeLabelTextWithDate:datePicker.date];
}

- (void)setShowTimeLabelTextWithDate:(NSDate *)date {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    self.showTimeLabel.text = dateStr;
}

// 选择重复次数
- (void)chooseRepeatCount:(UITapGestureRecognizer *)tap {
    GSHChooseRepeatCountVC *chooseRepeatCountVC = [GSHChooseRepeatCountVC chooseRepeatCountVC];
    chooseRepeatCountVC.choosedIndexSet = self.choosedIndexSet;
    @weakify(self)
    chooseRepeatCountVC.chooseRepeatCountBlock = ^(NSIndexSet *indexSet,NSString *showRepeatStr) {
        @strongify(self)
        self.showRepeatCountLabel.text = showRepeatStr;
        self.repeatCountIndexSet = indexSet;
        self.choosedIndexSet = indexSet;
    };
    [self.navigationController pushViewController:chooseRepeatCountVC animated:YES];
}

- (void)saveButtonClick:(UIButton *)button {
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[GSHAddAutoVC class]]) {
            NSIndexSet *indexSet ;
            if (self.repeatCountIndexSet.count > 0) {
                indexSet = self.repeatCountIndexSet;
            } else if (self.choosedIndexSet.count > 0) {
                indexSet = self.choosedIndexSet;
            }
            if (self.compeleteSetTimeBlock) {    
                self.compeleteSetTimeBlock(self.showTimeLabel.text,self.showRepeatCountLabel.text,indexSet);
            }
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
    
}

@end
