//
//  YXChoosedImgListCell.m
//  FateU
//
//  Created by Believer on 10/14/21.
//  Copyright © 2021 FateU_SYP. All rights reserved.
//

#import "YXChoosedImgListCell.h"

@interface YXChoosedImgListCell  ()

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIImageView *videoImgV; //视频标识视图
@property (nonatomic, strong) UILabel *timeLab; //视频时间

@end

@implementation YXChoosedImgListCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initView];
    }
    return self;
}

#pragma mark - 初始化视图
- (void)initView {
    
    self.cancelBtn.hidden = NO;
}

#pragma mark - progress
#pragma mark - 移除
- (void)progressCancelBtn {
    
    if (self.yxChoosedImgListCellCancelBlock) {
        self.yxChoosedImgListCellCancelBlock(self.selectAssetModel);
    }
}

#pragma mark - setting
- (void)setSelectAssetModel:(HXPhotoModel *)selectAssetModel {
    
    _selectAssetModel = selectAssetModel;
    
    self.imgView.image = _selectAssetModel.thumbPhoto;
    
    //视频时间
    if (_selectAssetModel.subType == HXPhotoModelMediaSubTypeVideo) {
        self.timeLab.hidden = self.videoImgV.hidden = NO;
        int totalTime = (int)(_selectAssetModel.videoDuration);
        int min = totalTime / 60;
        int sec = totalTime % 60;
        self.timeLab.text = [NSString stringWithFormat:@"%02d:%02d", min, sec];
    }
    else {
        self.timeLab.hidden = self.videoImgV.hidden = YES;
    }
}

#pragma mark - 懒加载
- (UIImageView *)imgView {
    
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.layer.cornerRadius = 4;
        _imgView.layer.masksToBounds = YES;
        _imgView.userInteractionEnabled = YES;
        [self.contentView addSubview:_imgView];
        
        [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.edges.equalTo(self.contentView);
        }];
    }
    return _imgView;
}
- (UIButton *)cancelBtn {
    
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setImage:[UIImage imageNamed:@"topic_search_cancel"] forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(progressCancelBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.imgView addSubview:_cancelBtn];
        
        [_cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.top.equalTo(self.imgView).with.offset(4);
            make.right.equalTo(self.imgView).with.offset(-5);
            make.width.and.height.mas_equalTo(13);
        }];
    }
    return _cancelBtn;
}
- (UIImageView *)videoImgV {
    
    if (!_videoImgV) {
        _videoImgV = [[UIImageView alloc] init];
        [_videoImgV setImage:[UIImage imageNamed:@"YXImageChooseListVideoImg"]];
        [self.imgView addSubview:_videoImgV];
        
        [_videoImgV mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.equalTo(self.imgView).with.offset(5);
            make.bottom.equalTo(self.imgView).with.offset(-5);
            make.height.mas_equalTo(7);
            make.width.mas_equalTo(12);
        }];
    }
    return _videoImgV;
}
- (UILabel *)timeLab {
    
    if (!_timeLab) {
        _timeLab = [[UILabel alloc] init];
        _timeLab.textColor = [UIColor colorWithHexString:@"#FFFFFF"];
        _timeLab.textAlignment = NSTextAlignmentRight;
        _timeLab.font = [UIFont systemFontOfSize:7];
        [self.imgView addSubview:_timeLab];
        
        [_timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.height.mas_equalTo(10);
            make.right.equalTo(self.imgView).with.offset(-5);
            make.bottom.equalTo(self.imgView).with.offset(-2);
            make.left.greaterThanOrEqualTo(self.videoImgV.mas_right).with.offset(5);
        }];
    }
    return _timeLab;
}

@end
