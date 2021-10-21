//
//  YXImageAmplificationCell.m
//  FateU
//
//  Created by Believer on 10/14/21.
//  Copyright © 2021 FateU_SYP. All rights reserved.
//

#import "YXImageAmplificationImgCell.h"

/** 最大的放大比例 */
#define kMaximumZoomScale 10

@interface YXImageAmplificationImgCell () <UIScrollViewDelegate>

@property (nonatomic, assign) PHImageRequestID imageRequestID; //图片请求ID
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation YXImageAmplificationImgCell

#pragma mark - 释放资源
- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initView];
    }
    return self;
}

#pragma mark - 添加手势
- (void)addGesture {
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickCell)];
    singleTap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleClickCell:)];
    doubleTap.numberOfTapsRequired = 2;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self addGestureRecognizer:doubleTap];
}

#pragma mark - 计算图片居中位置和大小
- (CGRect)calculateCenterWithImage:(UIImage *)image contentSize:(CGSize)size {
    
    if (image == nil) {
        return CGRectZero;
    }
    
    CGFloat w = size.height * (image.size.width / image.size.height);
    CGFloat h = size.width * (image.size.height / image.size.width);
    
    //宽度大于内容宽度就设置为内容宽
    if (w > size.width) {
        w = size.width;
    }
    
    //高度大于内容高度就设置为内容高
    if (h > size.height) {
        h = size.height;
    }
    
    //图片显示在中间的坐标
    CGFloat x = (size.width - w) / 2.f;
    CGFloat y = (size.height - h) / 2.f;
    
    CGRect rect = CGRectMake(x, y, w, h);
    return rect;
}

#pragma mark - 计算图片位置
- (void)calculateImageFrame {
    
    CGSize contentSize = self.scrollView.size;
    CGRect imageFrame = self.imageView.frame;
    
    //x坐标
    if (imageFrame.size.width < contentSize.width) {
        imageFrame.origin.x = (contentSize.width - imageFrame.size.width) / 2.f;
    }
    else {
        //当图片放大的宽大于内容宽时
        imageFrame.origin.x = 0.f;
    }
    
    //y坐标
    if (imageFrame.size.height < contentSize.height) {
        imageFrame.origin.y = (contentSize.height - imageFrame.size.height) / 2.f;
    }
    else {
        //当图片放大的高大于内容高时
        imageFrame.origin.y = 0.f;
    }
    
    self.imageView.frame = imageFrame;
}

#pragma mark - 点击cell
- (void)clickCell {
    
    if (self.clickCellBlock) {
        self.clickCellBlock();
    }
}

#pragma mark - 双击cell
- (void)doubleClickCell:(UIGestureRecognizer *)gesture {
    
    CGPoint touchPoint = [gesture locationInView:self];
    
    //判断滚动视图有没有放大
    if (self.scrollView.zoomScale != 1) {
        //缩小
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
        self.scrollView.scrollEnabled = NO;
    }
    else {
        //计算图片的放大倍数
        CGFloat maximumZoomScale = 5;
        CGSize imageSize = self.scrollView.size;
        if (imageSize.width < imageSize.height) {
            if (imageSize.width + 80 < self.scrollView.width) {
                maximumZoomScale = self.scrollView.width / imageSize.width;
            }
        }
        else {
            if (imageSize.height + 80 < self.scrollView.height) {
                maximumZoomScale = self.scrollView.height / imageSize.height;
            }
        }
        
        //放大
        self.scrollView.maximumZoomScale = maximumZoomScale;
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
        self.scrollView.scrollEnabled = YES;
        
        //还原放大倍数
        if (self.scrollView.maximumZoomScale < kMaximumZoomScale) {
            self.scrollView.maximumZoomScale = kMaximumZoomScale;
        }
    }
}

#pragma mark - 监听浏览器停止滚动的通知
- (void)browserDidScrollNotice {
    
    if (self.indexPath.row != self.browserVC.currentIndex) {
        self.scrollView.zoomScale = 1;
    }
}

#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    [self calculateImageFrame];
    if (self.scrollView.zoomScale == 1) {
        self.scrollView.scrollEnabled = NO;
    }
    else {
        self.scrollView.scrollEnabled = YES;
    }
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return self.imageView;
}

#pragma mark - setting
- (void)setAssetModel:(YXChooseImgPhotoAssetModel *)assetModel {
    
    _assetModel = assetModel;
    
    __weak typeof(self) weakSelf = self;
    //还原缩放
    self.scrollView.zoomScale = 1;
    self.scrollView.maximumZoomScale = kMaximumZoomScale;
    
    //取消上次的图片请求
    if (_imageRequestID != 0) {
        [[PHImageManager defaultManager] cancelImageRequest:_imageRequestID];
        _imageRequestID = 0;
    }
    self.imageView.image = nil;
    
    //图片请求
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.networkAccessAllowed = YES;
    _imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:_assetModel.asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        if (result == nil) {
            return;
        }
        
        weakSelf.imageView.image = result;
        weakSelf.imageView.frame = [weakSelf calculateCenterWithImage:result contentSize:weakSelf.scrollView.size];
        
        //图片的放大倍数
        CGFloat maximumZoomScale = 0.0;
        CGSize imageSize = weakSelf.imageView.size;
        if (imageSize.width < imageSize.height) {
            if (imageSize.width + 80 < weakSelf.scrollView.width) {
                maximumZoomScale = weakSelf.width / imageSize.width;
            }
        }
        else {
            if (imageSize.height + 80 < weakSelf.scrollView.height) {
                maximumZoomScale = weakSelf.scrollView.height / imageSize.height;
            }
        }

        //最小的放大倍数
        if (maximumZoomScale > kMaximumZoomScale) {
            weakSelf.scrollView.maximumZoomScale = maximumZoomScale;
        }
    }];
}

#pragma mark - 初始化视图
- (void)initView {
    
    //监听浏览器停止滚动的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(browserDidScrollNotice) name:@"kMediaPhotoBrowserDidScrollNotice" object:nil];
    
    self.scrollView.hidden = self.imageView.hidden = NO;
    [self addGesture];
}

#pragma mark - 懒加载
- (UIScrollView *)scrollView {
    
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
        _scrollView.zoomScale = 1;
        _scrollView.minimumZoomScale = 1;
        _scrollView.maximumZoomScale = kMaximumZoomScale;
        [self.contentView addSubview:_scrollView];
        
        [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.edges.equalTo(self.contentView);
        }];
        
        [_scrollView setNeedsLayout];
        [_scrollView layoutIfNeeded];
    }
    return _scrollView;
}
- (UIImageView *)imageView {
    
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.clipsToBounds = YES;
        _imageView.userInteractionEnabled = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.scrollView addSubview:_imageView];
    }
    return _imageView;
}

@end
