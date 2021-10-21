//
//  YXChooseImgCell.m
//  YXImageProcessingTest
//
//  Created by Believer on 10/12/21.
//

#import "YXChooseImgCell.h"

@interface YXChooseImgCell ()

@property (nonatomic, strong) UIImageView *imgV; //照片视图
@property (nonatomic, strong) UIView *enableView; //蒙层视图
@property (nonatomic, strong) UIButton *chooseBtn; //选择按钮
@property (nonatomic, strong) UIImageView *videoImgV; //视频标识视图
@property (nonatomic, strong) UILabel *timeLab; //视频时间

@property (nonatomic, assign) PHImageRequestID imageRequestID; //图片请求ID

@end

@implementation YXChooseImgCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        
    }
    return self;
}

#pragma mark - progress
#pragma mark - 勾选
- (void)progressChooseBtn {
    
    if (self.clickSelectBlock) {
        self.clickSelectBlock();
    }
}

#pragma mark - setting
- (void)setAssetModel:(YXChooseImgPhotoAssetModel *)assetModel {
    
    _assetModel = assetModel;
    
    __weak typeof(self) weakSelf = self;
    //取消上次的图片请求
    if (_imageRequestID != 0) {
        [[PHImageManager defaultManager] cancelImageRequest:_imageRequestID];
        _imageRequestID = 0;
    }
    
    //图片大小
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize imageSize = CGSizeMake(self.imgV.width *scale, self.imgV.height *scale);
    
    if (_assetModel.asset == nil) { //第一个数据为相机
        self.imgV.contentMode = UIViewContentModeCenter;
        self.imgV.image = [UIImage imageNamed:@"YXImageChooseTakePicImg"];
        self.enableView.hidden = YES;
        self.chooseBtn.hidden = self.timeLab.hidden = self.videoImgV.hidden = YES;
    }
    else { //图片请求
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        options.networkAccessAllowed = YES;
        self.imgV.contentMode = UIViewContentModeScaleAspectFill;
        _imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:_assetModel.asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
            if (result) {
                weakSelf.imgV.image = result;
            }
        }];
        
        //是否勾选
        self.chooseBtn.hidden = NO;
        if (_assetModel.isSelect) {
            [self.chooseBtn setTitle:[NSString stringWithFormat:@"%@", @(_assetModel.selectCount)] forState:UIControlStateNormal];
            self.chooseBtn.backgroundColor = [UIColor colorWithHexString:@"#F9DD23"];
            self.chooseBtn.layer.borderWidth = 0;
        }
        else {
            [self.chooseBtn setTitle:@"" forState:UIControlStateNormal];
            self.chooseBtn.backgroundColor = [[UIColor colorWithHexString:@"#999999"] colorWithAlphaComponent:0.5];
            self.chooseBtn.layer.borderWidth = 1;
        }
        
        //视频时间
        if (_assetModel.asset.mediaType == PHAssetMediaTypeVideo) {
            self.timeLab.hidden = self.videoImgV.hidden = NO;
            int totalTime = (int)(_assetModel.asset.duration);
            int min = totalTime / 60;
            int sec = totalTime % 60;
            self.timeLab.text = [NSString stringWithFormat:@"%02d:%02d", min, sec];
        }
        else {
            self.timeLab.hidden = self.videoImgV.hidden = YES;
        }
        
//        self.enableView.hidden = _assetModel.isEnabled;
        self.enableView.hidden =! _assetModel.isSelect;
    }
}

#pragma mark - 懒加载
- (UIImageView *)imgV {
    
    if (!_imgV) {
        _imgV = [[UIImageView alloc] init];
        _imgV.layer.masksToBounds = YES;
        _imgV.userInteractionEnabled = YES;
        [self.contentView addSubview:_imgV];
        
        [_imgV mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.edges.equalTo(self.contentView);
        }];
        
        [_imgV setNeedsLayout];
        [_imgV layoutIfNeeded];
    }
    return _imgV;
}
- (UIView *)enableView {
    
    if (!_enableView) {
        _enableView = [[UIView alloc] init];
        _enableView.backgroundColor = [[UIColor colorWithHexString:@"#000000"] colorWithAlphaComponent:0.4];
        _enableView.hidden = YES;
        [self.imgV addSubview:_enableView];
        [self.imgV sendSubviewToBack:_enableView];
        
        [_enableView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.edges.equalTo(self.imgV);
        }];
    }
    return _enableView;
}
- (UIButton *)chooseBtn {
    
    if (!_chooseBtn) {
        _chooseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _chooseBtn.layer.borderWidth = 1;
        _chooseBtn.layer.borderColor = [UIColor colorWithHexString:@"#FFFFFF"].CGColor;
        _chooseBtn.layer.cornerRadius = 10;
        _chooseBtn.layer.masksToBounds = YES;
        _chooseBtn.backgroundColor = [[UIColor colorWithHexString:@"#999999"] colorWithAlphaComponent:0.5];
        [_chooseBtn setTitleColor:[UIColor colorWithHexString:@"#000000"] forState:UIControlStateNormal];
        [_chooseBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [_chooseBtn addTarget:self action:@selector(progressChooseBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.imgV addSubview:_chooseBtn];
        
        [_chooseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.top.equalTo(self.imgV).with.offset(6);
            make.right.equalTo(self.imgV).with.offset(-7);
            make.width.and.height.mas_equalTo(20);
        }];
    }
    return _chooseBtn;
}
- (UIImageView *)videoImgV {
    
    if (!_videoImgV) {
        _videoImgV = [[UIImageView alloc] init];
        [_videoImgV setImage:[UIImage imageNamed:@"YXImageChooseListVideoImg"]];
        [self.imgV addSubview:_videoImgV];
        
        [_videoImgV mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.equalTo(self.imgV).with.offset(5);
            make.bottom.equalTo(self.imgV).with.offset(-5);
            make.height.mas_equalTo(14);
            make.width.mas_equalTo(25);
        }];
    }
    return _videoImgV;
}
- (UILabel *)timeLab {
    
    if (!_timeLab) {
        _timeLab = [[UILabel alloc] init];
        _timeLab.textColor = [UIColor colorWithHexString:@"#FFFFFF"];
        _timeLab.textAlignment = NSTextAlignmentRight;
        _timeLab.font = [UIFont systemFontOfSize:14];
        [self.imgV addSubview:_timeLab];
        
        [_timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.height.mas_equalTo(20);
            make.right.equalTo(self.imgV).with.offset(-5);
            make.bottom.equalTo(self.imgV).with.offset(-2);
            make.left.greaterThanOrEqualTo(self.videoImgV.mas_right).with.offset(10);
        }];
    }
    return _timeLab;
}

@end
