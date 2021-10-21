//
//  YXVideoEditCropView.m
//  FateU
//
//  Created by Believer on 10/15/21.
//  Copyright © 2021 FateU_SYP. All rights reserved.
//

#import "YXVideoEditCropView.h"
#import "YXVideoEditCropCell.h"

@interface YXVideoEditCropView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

/** 列表视图 */
@property (nonatomic, strong) UICollectionView *collectionView;
/** 顶部分割线视图 */
@property (nonatomic, strong) UIImageView *topLineView;
/** 底部分割线视图 */
@property (nonatomic, strong) UIImageView *bottomLineView;
/** 左滑块视图 */
@property (nonatomic, strong) UIImageView *leftSliderView;
/** 右滑块视图 */
@property (nonatomic, strong) UIImageView *rightSliderView;
/** 进度视图 */
@property (nonatomic, strong) UIImageView *progressView;
/** 触摸的视图 */
@property (nonatomic, strong) UIView *touchView;

/** 左右间距 */
@property (nonatomic, assign) CGFloat margin;
/** 滑块的宽 */
@property (nonatomic, assign) CGFloat sliderWidth;
/** 帧图片数据 */
@property (nonatomic, strong) NSMutableArray *imageArr;

@end

@implementation YXVideoEditCropView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initView];
    }
    return self;
}

#pragma mark - 加载帧图片
- (void)loadFrameImage {
    
    CMTime startTime = kCMTimeZero;
    CMTime endTime = CMTimeMakeWithSeconds(self.cropModel.totalTime, self.cropModel.timescale);
    
    CGFloat intervalSeconds = self.cropModel.totalTime / (self.cropModel.imageNum - 1);
    CMTime addTime = CMTimeMakeWithSeconds(intervalSeconds, self.cropModel.timescale);
    
    NSMutableArray *timeArr = [NSMutableArray array];
    while (CMTIME_COMPARE_INLINE(startTime, <=, endTime)) {
        [timeArr addObject:[NSValue valueWithCMTime:startTime]];
        startTime = CMTimeAdd(startTime, addTime);
    }
    
    //第一帧和最后一帧特殊处理，规避有些视频开始和末尾是黑屏
    timeArr[0] = [NSValue valueWithCMTime:CMTimeMakeWithSeconds(0.1, self.cropModel.timescale)];
    timeArr[timeArr.count - 1] = [NSValue valueWithCMTime:CMTimeMakeWithSeconds(self.cropModel.totalTime - 0.1, self.cropModel.timescale)];
    
    //获取帧图片
    __weak __typeof(self) weakSelf = self;
    [_imageArr removeAllObjects];
    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:self.cropModel.videoPath]];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    imageGenerator.maximumSize = CGSizeMake(180, 180);
    [imageGenerator generateCGImagesAsynchronouslyForTimes:timeArr completionHandler:^(CMTime requestedTime, CGImageRef _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        
        if (result == AVAssetImageGeneratorSucceeded) {
            [weakSelf.imageArr addObject:[[UIImage alloc] initWithCGImage:image]];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [weakSelf.collectionView reloadData];
            });
        }
    }];
}

#pragma mark - 更新播放进度位置
- (void)updateProgressPoint {
    
    CGFloat slideMaxW = self.width - (_margin * 2) - (_sliderWidth * 2);
    CGFloat viewX = _margin + slideMaxW * (self.cropModel.startTime / self.cropModel.totalTime);
    [self.leftSliderView mas_updateConstraints:^(MASConstraintMaker *make) {

        make.left.equalTo(self).with.offset(viewX);
        make.width.mas_equalTo(_sliderWidth);
    }];

    viewX = _margin + slideMaxW * (self.cropModel.endTime / self.cropModel.totalTime) + _sliderWidth;
    [self.rightSliderView mas_updateConstraints:^(MASConstraintMaker *make) {

        make.left.equalTo(self).with.offset(viewX);
        make.width.mas_equalTo(_sliderWidth);
    }];
    
    viewX = _margin + (slideMaxW * self.progress) + (_sliderWidth - (4 / 2.f));
    [self.progressView mas_updateConstraints:^(MASConstraintMaker *make) {

        make.left.equalTo(self).with.offset(viewX);
    }];
}

#pragma mark - 滑动截取
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];

    UITouch *touch = (UITouch *)[touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    CGFloat margin = 10;
    CGRect leftSliderViewFrame = CGRectMake(self.leftSliderView.x - margin, self.leftSliderView.y, self.leftSliderView.width + margin * 2, self.leftSliderView.height);
    CGRect rightSliderViewFrame = CGRectMake(self.rightSliderView.x - margin, self.rightSliderView.y, self.rightSliderView.width + margin * 2, self.rightSliderView.height);
    
    margin = 30;
    CGRect progressTouchViewFrame = CGRectMake(self.progressView.x - margin, self.progressView.y, self.progressView.width + margin * 2, self.progressView.height);
    
    if (CGRectContainsPoint(leftSliderViewFrame, point)) {
        _touchView = self.leftSliderView;
    }
    else if (CGRectContainsPoint(rightSliderViewFrame, point)) {
        _touchView = self.rightSliderView;
    }
    else if (CGRectContainsPoint(progressTouchViewFrame, point)) {
        _touchView = self.progressView;
    }
    else {
        _touchView = nil;
    }
    
    if (_touchView == self.leftSliderView || _touchView == self.rightSliderView) {
        self.progressView.hidden = YES;
        self.cropModel.isSlideCrop = YES;
    }
    
    if (_touchView && self.delegate && [self.delegate respondsToSelector:@selector(cropSliderTouchBegan)]) {
        [self.delegate cropSliderTouchBegan];
    }
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];

    UITouch *touch = (UITouch *)[touches anyObject];
    CGPoint movedPoint = [touch locationInView:self];
    CGPoint previousPoint = [touch previousLocationInView:self];
    CGFloat offsetX = movedPoint.x - previousPoint.x;
    CGFloat slideMaxW = self.width - (_margin * 2) - (_sliderWidth * 2);
    
    if (_touchView == self.leftSliderView) {
        CGFloat viewX = self.leftSliderView.x + offsetX;
        if (viewX <= 0) {
            viewX = 0;
        }
        
        CGFloat startTime = self.cropModel.totalTime * ((viewX - _margin) / slideMaxW);
        CGFloat cropTime = self.cropModel.endTime - startTime;
        if (cropTime <= self.cropModel.minTime) {
            startTime = self.cropModel.endTime - self.cropModel.minTime;
        }
        else if (cropTime >= self.cropModel.maxTime) {
            startTime = self.cropModel.endTime - self.cropModel.maxTime;
        }
        
        viewX = _margin + slideMaxW * (startTime / self.cropModel.totalTime);
        [self.leftSliderView mas_updateConstraints:^(MASConstraintMaker *make) {
           
            make.left.equalTo(self).with.offset(viewX);
        }];
        
        self.cropModel.startTime = startTime;
        if (self.delegate && [self.delegate respondsToSelector:@selector(cropSliderMovedToTime:)]) {
            [self.delegate cropSliderMovedToTime:startTime];
        }
    }
    else if (_touchView == self.rightSliderView) {
        CGFloat viewX = self.rightSliderView.x + offsetX;
        if (viewX >= self.collectionView.right) {
            viewX = self.collectionView.right;
        }
        
        CGFloat endTime = self.cropModel.totalTime * ((viewX - _margin - _sliderWidth) / slideMaxW);
        CGFloat cropTime = endTime - self.cropModel.startTime;
        if (cropTime <= self.cropModel.minTime) {
            endTime = self.cropModel.startTime + self.cropModel.minTime;
        }
        else if (cropTime >= self.cropModel.maxTime) {
            endTime = self.cropModel.startTime + self.cropModel.maxTime;
        }
        
        viewX = _margin + slideMaxW * (endTime / self.cropModel.totalTime) + _sliderWidth;
        [self.rightSliderView mas_updateConstraints:^(MASConstraintMaker *make) {
           
            make.left.equalTo(self).with.offset(viewX);
        }];
        
        self.cropModel.endTime = endTime;
        if (self.delegate && [self.delegate respondsToSelector:@selector(cropSliderMovedToTime:)]) {
            [self.delegate cropSliderMovedToTime:endTime];
        }
    }
    else if (_touchView == self.progressView) {
        CGFloat viewX = self.progressView.x + offsetX;
        
        CGFloat playTime = self.cropModel.totalTime * ((viewX - _margin - _sliderWidth + (self.progressView.width / 2.f)) / slideMaxW);
        if (playTime <= self.cropModel.startTime) {
            playTime = self.cropModel.startTime;
        }
        else if (playTime >= self.cropModel.endTime) {
            playTime = self.cropModel.endTime;
        }
        
        viewX = _margin + slideMaxW * (playTime / self.cropModel.totalTime) + _sliderWidth - (self.progressView.width / 2.f);
        [self.progressView mas_updateConstraints:^(MASConstraintMaker *make) {
           
            make.left.equalTo(self).with.offset(viewX);
        }];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(cropSliderMovedToTime:)]) {
            [self.delegate cropSliderMovedToTime:playTime];
        }
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    if (_touchView && self.delegate && [self.delegate respondsToSelector:@selector(cropSliderTouchEnded)]) {
        if (_touchView != self.progressView) {
            CGFloat viewX = self.leftSliderView.right - self.progressView.width / 2.f;
            [self.progressView mas_updateConstraints:^(MASConstraintMaker *make) {
               
                make.left.equalTo(self).with.offset(viewX);
            }];
            self.progressView.hidden = NO;
        }
        
        _touchView = nil;
        self.cropModel.isSlideCrop = NO;
        [self.delegate cropSliderTouchEnded];
    }
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _imageArr.count;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    return 0;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(self.collectionView.width / self.cropModel.imageNum, self.collectionView.height);
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    YXVideoEditCropCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([YXVideoEditCropCell class]) forIndexPath:indexPath];
    cell.imageView.image = _imageArr[indexPath.row];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - setting
- (void)setCropModel:(YXVideoEditCropModel *)cropModel {
    
    _cropModel = cropModel;
 
    //帧图片数据
    _imageArr = [NSMutableArray array];
        
    //加载帧图片
    [self loadFrameImage];
    //更新位置
    [self updateProgressPoint];
}

#pragma mark - 设置播放进度
- (void)setProgress:(CGFloat)progress {
    
    _progress = progress;
    if (_touchView) {
        return;
    }
    
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear animations:^{
        
        [weakSelf updateProgressPoint];
    }
    completion:^(BOOL finished) {}];
}

#pragma mark - 初始化视图
- (void)initView {
    
    //左右间距
    _margin = 15;
    
    //滑块的宽
    _sliderWidth = 15;
}

#pragma mark - 懒加载
- (UICollectionView *)collectionView {
    
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.layer.masksToBounds = YES;
        _collectionView.layer.cornerRadius = 3;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.userInteractionEnabled = NO;
        [self addSubview:_collectionView];
        [self sendSubviewToBack:_collectionView];
        
        [_collectionView registerClass:[YXVideoEditCropCell class] forCellWithReuseIdentifier:NSStringFromClass([YXVideoEditCropCell class])];
        
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.equalTo(self).with.offset(self.margin + 15);
            make.top.equalTo(self.topLineView.mas_bottom);
            make.right.equalTo(self).with.offset(-(self.margin + 15));
            make.bottom.equalTo(self.bottomLineView.mas_top);
        }];
        
        [_collectionView setNeedsLayout];
        [_collectionView layoutIfNeeded];
    }
    return _collectionView;
}
- (UIImageView *)topLineView {
    
    if (!_topLineView) {
        _topLineView = [[UIImageView alloc] init];
        _topLineView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_topLineView];
        [self bringSubviewToFront:_topLineView];
        
        [_topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.equalTo(self.leftSliderView.mas_right);
            make.top.equalTo(self);
            make.right.equalTo(self.rightSliderView.mas_left);
            make.height.mas_equalTo(2);
        }];
        
        [_topLineView setNeedsLayout];
        [_topLineView layoutIfNeeded];
    }
    return _topLineView;
}
- (UIImageView *)bottomLineView {
    
    if (!_bottomLineView) {
        _bottomLineView = [[UIImageView alloc] init];
        _bottomLineView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_bottomLineView];
        [self bringSubviewToFront:_bottomLineView];
        
        [_bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.and.right.and.height.equalTo(self.topLineView);
            make.bottom.equalTo(self);
        }];
        
        [_bottomLineView setNeedsLayout];
        [_bottomLineView layoutIfNeeded];
    }
    return _bottomLineView;
}
- (UIImageView *)leftSliderView {
    
    if (!_leftSliderView) {
        _leftSliderView = [[UIImageView alloc] init];
        _leftSliderView.layer.shadowOpacity = 0.2;
        _leftSliderView.layer.shadowRadius = 4;
        _leftSliderView.layer.shadowOffset = CGSizeMake(0, 0);
        _leftSliderView.layer.shadowColor = [[UIColor blackColor] CGColor];
        _leftSliderView.backgroundColor = [UIColor clearColor];
        _leftSliderView.image = [UIImage imageNamed:@"YXVideoEditCropLeftSliderImg"];
        [self addSubview:_leftSliderView];
        [self bringSubviewToFront:_leftSliderView];
        
        [_leftSliderView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.top.equalTo(self);
            make.left.equalTo(self).with.offset(15);
            make.bottom.equalTo(self);
            make.width.mas_equalTo(self.sliderWidth);
        }];
        
        [_leftSliderView setNeedsLayout];
        [_leftSliderView layoutIfNeeded];
    }
    return _leftSliderView;
}
- (UIImageView *)rightSliderView {
    
    if (!_rightSliderView) {
        _rightSliderView = [[UIImageView alloc] init];
        _rightSliderView.layer.shadowOpacity = 0.2;
        _rightSliderView.layer.shadowRadius = 4;
        _rightSliderView.layer.shadowOffset = CGSizeMake(0, 0);
        _rightSliderView.layer.shadowColor = [[UIColor blackColor] CGColor];
        _rightSliderView.backgroundColor = [UIColor clearColor];
        _rightSliderView.image = [UIImage imageNamed:@"YXVideoEditCropRightSliderImg"];
        [self addSubview:_rightSliderView];
        [self bringSubviewToFront:_rightSliderView];
        
        [_rightSliderView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.top.and.bottom.equalTo(self.leftSliderView);
            make.right.lessThanOrEqualTo(self).with.offset(-15);
            make.width.mas_equalTo(self.sliderWidth);
        }];
        
        [_rightSliderView setNeedsLayout];
        [_rightSliderView layoutIfNeeded];
    }
    return _rightSliderView;
}
- (UIImageView *)progressView {
    
    if (!_progressView) {
        _progressView = [[UIImageView alloc] init];
        _progressView.layer.cornerRadius = 2;
        _progressView.layer.shadowOpacity = 0.2;
        _progressView.layer.shadowRadius = 4;
        _progressView.layer.shadowOffset = CGSizeMake(0, 0);
        _progressView.layer.shadowColor = [[UIColor blackColor] CGColor];
        _progressView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_progressView];
        [self bringSubviewToFront:_progressView];
        
        [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.top.equalTo(self).with.offset(-4);
            make.left.equalTo(self).with.offset(self.margin + 15);
            make.bottom.equalTo(self).with.offset(4);
            make.width.mas_equalTo(4);
        }];
        
        [_progressView setNeedsLayout];
        [_progressView layoutIfNeeded];
    }
    return _progressView;
}

@end
