//
//  YXImageEditBottomMenuView.m
//  FateU
//
//  Created by 北宸卿月 on 2021/10/16.
//  Copyright © 2021 FateU_SYP. All rights reserved.
//

#import "YXImageEditBottomMenuView.h"

@interface YXImageEditBottomMenuView ()
@property (weak, nonatomic) IBOutlet KMButton *oneBtn;
@property (weak, nonatomic) IBOutlet KMButton *twoBtn;
@property (weak, nonatomic) IBOutlet KMButton *threeBtn;
@property (weak, nonatomic) IBOutlet KMButton *fourBtn;
@property (weak, nonatomic) IBOutlet KMButton *fiveBtn;

@end

@implementation YXImageEditBottomMenuView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.oneBtn.kMButtonType = self.twoBtn.kMButtonType = self.threeBtn.kMButtonType = self.fourBtn.kMButtonType = self.fiveBtn.kMButtonType = KMButtonCenter;
    self.oneBtn.spacing = self.twoBtn.spacing = self.threeBtn.spacing = self.fourBtn.spacing = self.fiveBtn.spacing = 10;
}
- (IBAction)clickBtnAction:(KMButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickImageEditBottomMenutBtnAction:)]) {
        [self.delegate clickImageEditBottomMenutBtnAction:sender.tag];
    }
}

//初始化XIB视图
+ (instancetype)viewFromXIB {
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil];
    return [nibContents lastObject];
}

@end
