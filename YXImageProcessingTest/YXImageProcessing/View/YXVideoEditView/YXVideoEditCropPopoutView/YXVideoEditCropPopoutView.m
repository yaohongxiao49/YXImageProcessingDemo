//
//  YXVideoEditCropPopoutView.m
//  FateU
//
//  Created by Believer on 10/15/21.
//  Copyright © 2021 FateU_SYP. All rights reserved.
//

#import "YXVideoEditCropPopoutView.h"

@interface YXVideoEditCropPopoutView ()

@property (nonatomic, strong) UIView *chooseBgView; //选择背景视图
@property (nonatomic, strong) UIButton *cancelBtn; //关闭按钮
@property (nonatomic, strong) UIButton *sureBtn; //确认按钮

@end

@implementation YXVideoEditCropPopoutView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"#000000"];
        [self initView];
    }
    return self;
}

#pragma mark - progress
#pragma mark - 确定
- (void)progressSureBtn {
 
    if (self.clickFinishBlock) {
        self.clickFinishBlock();
    }
}

#pragma mark - 初始化视图
- (void)initView {
    
    self.cropTimeLab.text = @"已选取0.0s";
    self.cropView.hidden = NO;
}

#pragma mark - 懒加载
- (UIView *)chooseBgView {
    
    if (!_chooseBgView) {
        _chooseBgView = [[UIView alloc] init];
        _chooseBgView.backgroundColor = [UIColor clearColor];
        [self addSubview:_chooseBgView];
        
        [_chooseBgView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.and.top.and.right.equalTo(self);
            make.height.mas_equalTo(45);
        }];
    }
    return _chooseBgView;
}
- (UIButton *)sureBtn {
    
    if (!_sureBtn) {
        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sureBtn setImage:[UIImage imageNamed:@"YXVideoEditCropSureImg"] forState:UIControlStateNormal];
        [_sureBtn addTarget:self action:@selector(progressSureBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.chooseBgView addSubview:_sureBtn];
        
        [_sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.right.and.top.and.bottom.equalTo(self.chooseBgView);
            make.width.mas_equalTo(62);
        }];
    }
    return _sureBtn;
}
- (UILabel *)cropTimeLab {
    
    if (!_cropTimeLab) {
        _cropTimeLab = [[UILabel alloc] init];
        _cropTimeLab.textAlignment = NSTextAlignmentLeft;
        _cropTimeLab.textColor = [UIColor colorWithHexString:@"#FFFFFF"];
        _cropTimeLab.font = [UIFont boldSystemFontOfSize:13];
        [self.chooseBgView addSubview:_cropTimeLab];
        
        [_cropTimeLab mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.equalTo(self.chooseBgView).with.offset(15);
            make.right.equalTo(self.sureBtn.mas_left).with.offset(-10);
            make.centerY.equalTo(self.sureBtn);
        }];
    }
    return _cropTimeLab;
}
- (YXVideoEditCropView *)cropView {
    
    if (!_cropView) {
        _cropView = [[YXVideoEditCropView alloc] init];
        [self addSubview:_cropView];
        
        [_cropView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.and.right.equalTo(self);
            make.height.mas_equalTo(60);
            make.top.equalTo(self.chooseBgView.mas_bottom).with.offset(15);
        }];
    }
    return _cropView;
}

@end
