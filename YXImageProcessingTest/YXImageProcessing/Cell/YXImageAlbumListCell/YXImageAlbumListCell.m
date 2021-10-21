//
//  YXImageAlbumListCell.m
//  FateU
//
//  Created by Believer on 10/13/21.
//  Copyright © 2021 FateU_SYP. All rights reserved.
//

#import "YXImageAlbumListCell.h"

@interface YXImageAlbumListCell ()

@property (nonatomic, strong) UIImageView *imgV; //相册图片
@property (nonatomic, strong) UILabel *titleLab; //标题
@property (nonatomic, strong) UILabel *countLab; //数量
@property (nonatomic, strong) UIImageView *chooseImgV; //选中图

@property (nonatomic, assign) PHImageRequestID imageRequestID; //图片请求ID

@end

@implementation YXImageAlbumListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - setting
- (void)setAlbumModel:(YXChooseImgAlbumModel *)albumModel {
    
    __weak typeof(self) weakSelf = self;
    _albumModel = albumModel;
        
    //取消上次的图片请求
    if (_imageRequestID != 0) {
        [[PHImageManager defaultManager] cancelImageRequest:_imageRequestID];
        _imageRequestID = 0;
    }
    self.imgV.image = nil;
    
    //图片大小
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize imageSize = CGSizeMake(self.imgV.width * scale, self.imgV.height * scale);
    
    //图片请求
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.networkAccessAllowed = YES;
    PHAsset *asset = [_albumModel.fetchResult firstObject];
    _imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        if (result) {
            weakSelf.imgV.image = result;
        }
    }];
    
    //专辑名称
    self.titleLab.text = _albumModel.albumName;
    self.countLab.text = [NSString stringWithFormat:@"%@", @(_albumModel.fetchResult.count)];
}

#pragma mark - 懒加载
- (UIImageView *)imgV {
    
    if (!_imgV) {
        _imgV = [[UIImageView alloc] init];
        _imgV.layer.masksToBounds = YES;
        _imgV.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_imgV];
        
        [_imgV mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.equalTo(self.contentView).with.offset(15);
            make.top.equalTo(self.contentView).with.offset(5);
            make.bottom.equalTo(self.contentView).with.offset(-5);
            make.width.and.height.mas_equalTo(70);
        }];
        
        [_imgV setNeedsLayout];
        [_imgV layoutIfNeeded];
    }
    return _imgV;
}
- (UILabel *)titleLab {
    
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textAlignment = NSTextAlignmentLeft;
        _titleLab.textColor = [UIColor colorWithHexString:@"#FFFFFF"];
        _titleLab.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_titleLab];
        
        [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.equalTo(self.imgV.mas_right).with.offset(15);
            make.top.equalTo(self.imgV).with.offset(10);
            make.right.equalTo(self.chooseImgV.mas_left).with.offset(- 10);
        }];
    }
    return _titleLab;
}
- (UILabel *)countLab {
    
    if (!_countLab) {
        _countLab = [[UILabel alloc] init];
        _countLab.textAlignment = NSTextAlignmentLeft;
        _countLab.textColor = [UIColor colorWithHexString:@"#FFFFFF"];
        _countLab.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_countLab];
        
        [_countLab mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.and.right.equalTo(self.titleLab);
            make.top.equalTo(self.titleLab.mas_bottom).with.offset(10);
        }];
    }
    return _countLab;
}
- (UIImageView *)chooseImgV {
    
    if (!_chooseImgV) {
        _chooseImgV = [[UIImageView alloc] init];
        [_chooseImgV setImage:[UIImage imageNamed:@""]];
        [self.contentView addSubview:_chooseImgV];
        
        [_chooseImgV mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.top.and.bottom.and.right.equalTo(self.contentView);
            make.height.mas_equalTo(self.chooseImgV.mas_width);
        }];
    }
    return _chooseImgV;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
