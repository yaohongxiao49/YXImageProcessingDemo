//
//  YCMediaPhotoBrowserVideoCell.m
//  RuLiMeiRong
//
//  Created by 余成国 on 2021/1/29.
//  Copyright © 2021 成都美哆网络科技有限公司. All rights reserved.
//

#import "YCMediaPhotoBrowserVideoCell.h"
#import "YCProgressSlider.h"
#import "YXGPUImageUtils.h"

@implementation YCMediaPhotoBrowserPlayerView

#pragma mark - 播放器图层
+ (Class)layerClass {
    
    return [AVPlayerLayer class];
}
- (void)setPlayer:(AVPlayer *)player {
    
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}
- (AVPlayer *)player {
    
    return [(AVPlayerLayer *)[self layer] player];
}

@end

@interface YCMediaPhotoBrowserVideoCell ()

/** 监听播放时间 */
@property (nonatomic, strong) id timeObserver;
/** 视频请求ID */
@property (nonatomic, assign) PHImageRequestID imageRequestID;

@end

@implementation YCMediaPhotoBrowserVideoCell

#pragma mark - 释放资源
- (void)dealloc {
    
    [self releaseResource];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)releaseResource {
    
    if (_timeObserver) {
        [_playerView.player removeTimeObserver:_timeObserver];
        _timeObserver = nil;
    }
    
    if (_playerItem) {
        [_playerView.player removeObserver:self forKeyPath:@"status"];
        [_playerView.player removeObserver:self forKeyPath:@"timeControlStatus"];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
        _playerItem = nil;
    }
}

#pragma mark - 加载视图
- (void)awakeFromNib {
    [super awakeFromNib];
    
    //循环播放
    _isCyclePlay = YES;
    
    //监听浏览器停止滚动的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(browserDidScrollNotice) name:@"kMediaPhotoBrowserDidScrollNotice" object:nil];
    
    [self initView];
    [self addGesture];
}

#pragma mark - 初始化视图
- (void)initView {
    
    __weak typeof(self) weakSelf = self;
    
    //播放器图层
    AVPlayerLayer *playerLayer = (AVPlayerLayer *)_playerView.layer;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    //时间底视图阴影
    _timeBaseView.layer.shadowOpacity = 0.5;
    _timeBaseView.layer.shadowRadius = 1;
    _timeBaseView.layer.shadowOffset = CGSizeMake(0, 0);
    _timeBaseView.layer.shadowColor = [[UIColor blackColor] CGColor];
    
    //进度滑块
    _progressSlider.minimumColor = [UIColor whiteColor];
    _progressSlider.maximumColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    _progressSlider.touchBeganBlock = ^{
        
        if (weakSelf.playStatus == YCMediaPhotoBrowserVideoStatusPlaying) {
            weakSelf.playStatus = YCMediaPhotoBrowserVideoStatusBeforePlaying;
            [weakSelf pause];
        }
    };
    _progressSlider.touchEndedBlock = ^{
        
        if (weakSelf.playStatus == YCMediaPhotoBrowserVideoStatusBeforePlaying) {
            [weakSelf play];
        }
    };
    _progressSlider.valueChangedBlock = ^(CGFloat value) {
        
        CMTime time = CMTimeMakeWithSeconds(weakSelf.totalTime * value, weakSelf.playerItem.asset.duration.timescale);
        [weakSelf.playerView.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    };
}

#pragma mark - 添加手势
- (void)addGesture {
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickCell)];
    singleTap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTap];
}

#pragma mark - 布局
- (void)layoutSubviews {
    [super layoutSubviews];
    
    _timeBaseViewBottom.constant = self.yc_xBarHeight;
}

#pragma mark - 刷新数据
- (void)setAssetModel:(YXChooseImgPhotoAssetModel *)assetModel {
    
    __weak typeof(self) weakSelf = self;
    _assetModel = assetModel;
    _timeBaseView.hidden = _browserVC.navigationView.hidden;
    
    //取消上次的视频请求
    if (_imageRequestID != 0) {
        [[PHImageManager defaultManager] cancelImageRequest:_imageRequestID];
        _imageRequestID = 0;
    }
    [self pause];
    [self releaseResource];
    
    //视频请求
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    options.networkAccessAllowed = YES;
    _imageRequestID = [[PHImageManager defaultManager] requestPlayerItemForVideo:_assetModel.asset options:options resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
        
        if (playerItem) {
            [weakSelf initPlayerWithPlayerItem:playerItem];
            [weakSelf play];
        }
    }];
}

#pragma mark - 初始化播放器
- (void)initPlayerWithPlayerItem:(AVPlayerItem *)playerItem {
    
    //播放数据源
    _playerItem = playerItem;
    
    //播放器
    _playerView.player = [AVPlayer playerWithPlayerItem:_playerItem];
    _playerView.player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    
    //缩放类型
    NSInteger videoGravity = [YXGPUImageUtils getVideoGravityWithAsset:_playerItem.asset];
    AVPlayerLayer *playerLayer = (AVPlayerLayer *)_playerView.layer;
    if (videoGravity == 1) {
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    else {
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    }
    
    //总的时间
    _totalTime = CMTimeGetSeconds(_playerItem.asset.duration);
    _totalTimeLabel.text = [self timeStringFromSeconds:_totalTime];
    
    //监听播放时间
    [self addPeriodicTimeObserver];
    
    //监听播放状态
    [_playerView.player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [_playerView.player addObserver:self forKeyPath:@"timeControlStatus" options:NSKeyValueObservingOptionNew context:nil];
    
    //监听播放结束的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEndedNotice:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
}

#pragma mark - 设置播放状态
- (void)setPlayStatus:(YCMediaPhotoBrowserVideoStatus)playStatus {
    
    _playStatus = playStatus;
    
    if (_playStatus == YCMediaPhotoBrowserVideoStatusPlaying || _playStatus == YCMediaPhotoBrowserVideoStatusBeforePlaying) {
        [_playButton setImage:[UIImage imageNamed:@"YXImageVideoPauseImg"] forState:UIControlStateNormal];
    }
    else {
        [_playButton setImage:[UIImage imageNamed:@"YXImageVideoPlayImg"] forState:UIControlStateNormal];
    }
}

#pragma mark - 播放
- (void)play {
    
    if (_indexPath.row == _browserVC.currentIndex) {
        [_playerView.player play];
    }
}

#pragma mark - 暂停
- (void)pause {
    
    [_playerView.player pause];
}

#pragma mark - 点击播放
- (IBAction)clickPlay:(id)sender {
    
    if (self.playStatus == YCMediaPhotoBrowserVideoStatusPause) {
        [self play];
    }
    else {
        [self pause];
    }
}

#pragma mark - 点击cell
- (void)clickCell {
    
    _timeBaseView.hidden = !_browserVC.navigationView.hidden;
    
    if (_clickCellBlock) {
        _clickCellBlock();
    }
}

#pragma mark - 时间转化
- (NSString *)timeStringFromSeconds:(CGFloat)seconds {
    
    NSUInteger minute = (NSUInteger)(seconds / 60);
    NSUInteger second = (NSUInteger)((NSUInteger)seconds % 60);
    return [NSString stringWithFormat:@"%02d:%02d", (int)minute, (int)second];
}

#pragma mark - 监听播放时间
- (void)addPeriodicTimeObserver {
    
    if (_timeObserver) {
        [_playerView.player removeTimeObserver:_timeObserver];
        _timeObserver = nil;
    }
    
    __weak __typeof(self) weakSelf = self;
    _timeObserver = [_playerView.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 60) queue:NULL usingBlock:^(CMTime time) {
        
        weakSelf.playTime = CMTimeGetSeconds(time);
        weakSelf.progress = weakSelf.playTime / weakSelf.totalTime;
        
        weakSelf.totalTimeLabel.text = [weakSelf timeStringFromSeconds:weakSelf.totalTime];
        weakSelf.playTimeLabel.text = [weakSelf timeStringFromSeconds:weakSelf.playTime];
        [weakSelf.progressSlider setProgressValue:weakSelf.progress animated:YES];
    }];
}

#pragma mark - 监听播放状态
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = _playerView.player.status;
        if (status == AVPlayerStatusReadyToPlay) {
            //准备播放
        }
        else if (status == AVPlayerStatusFailed) {
            NSLog(@"无法播放该视频");
        }
    }
    else if ([keyPath isEqualToString:@"timeControlStatus"]) {
        AVPlayerTimeControlStatus timeControlStatus = _playerView.player.timeControlStatus;
        if (timeControlStatus == AVPlayerTimeControlStatusPaused) {
            if (self.playStatus != YCMediaPhotoBrowserVideoStatusBeforePlaying) {
                self.playStatus = YCMediaPhotoBrowserVideoStatusPause;
            }
        }
        else if (timeControlStatus == AVPlayerTimeControlStatusPlaying) {
            self.playStatus = YCMediaPhotoBrowserVideoStatusPlaying;
        }
    }
}

#pragma mark - 监听播放结束的通知
- (void)playEndedNotice:(NSNotification *)notice {
    
    if (notice.object != _playerItem) {
        return;
    }
    
    [_playerView.player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
    if (_isCyclePlay) {
        [self play];
    }
    else {
        [self pause];
    }
}

#pragma mark - 监听浏览器停止滚动的通知
- (void)browserDidScrollNotice {
    
    _timeBaseView.hidden = _browserVC.navigationView.hidden;
    
    if (_indexPath.row == _browserVC.currentIndex) {
        [self play];
    }
    else {
        [self pause];
    }
}

@end
