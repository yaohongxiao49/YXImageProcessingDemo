//
//  YXVideoEditPlayerView.m
//  FateU
//
//  Created by Believer on 10/15/21.
//  Copyright © 2021 FateU_SYP. All rights reserved.
//

#import "YXVideoEditPlayerView.h"
#import "YCProgressSlider.h"
#import "YXGPUImageUtils.h"

@interface YXVideoEditPlayerView ()

@property (nonatomic, strong) UIButton *playBtn; //播放按钮
@property (nonatomic, strong) UIView *timeBgView; //时长背景图
@property (nonatomic, strong) UILabel *playTimeLab; //播放时间
@property (nonatomic, strong) UILabel *totalTimeLab; //总时间
@property (nonatomic, strong) YCProgressSlider *progressSlider; //进度控制器

@property (nonatomic, strong) id timeObserver; //监听播放时间

@end

@implementation YXVideoEditPlayerView

#pragma mark - 释放资源
- (void)dealloc {
    
    [self releaseResource];
}
- (void)releaseResource {
    
    if (_timeObserver) {
        [self.player removeTimeObserver:_timeObserver];
        _timeObserver = nil;
    }
    
    [self.player removeObserver:self forKeyPath:@"status"];
    [self.player removeObserver:self forKeyPath:@"timeControlStatus"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initView];
    }
    return self;
}

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

#pragma mark - 播放
- (void)play {
    
    [self.player play];
}

#pragma mark - 暂停
- (void)pause {
    
    [self.player pause];
}

#pragma mark - 时间转化
- (NSString *)timeStringFromSeconds:(CGFloat)seconds {
    
    NSUInteger minute = (NSUInteger)(seconds / 60);
    NSUInteger second = (NSUInteger)((NSUInteger)seconds % 60);
    return [NSString stringWithFormat:@"%02d:%02d", (int)minute, (int)second];
}

#pragma mark - progress
#pragma mark - 播放
- (void)progressPlayBtn {
    
    if (self.playStatus == YXVideoEditPlayerStatusPause) {
        [self play];
    }
    else {
        [self pause];
    }
}

#pragma mark - 监听播放时间
- (void)addPeriodicTimeObserver {
    
    if (_timeObserver) {
        [self.player removeTimeObserver:_timeObserver];
        _timeObserver = nil;
    }
    
    __weak __typeof(self) weakSelf = self;
    _timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 60) queue:NULL usingBlock:^(CMTime time) {
        
        weakSelf.playTime = CMTimeGetSeconds(time);
        weakSelf.progress = weakSelf.playTime / weakSelf.totalTime;
        
        CGFloat totalTime = weakSelf.cropModel.endTime - weakSelf.cropModel.startTime;
        weakSelf.totalTimeLab.text = [weakSelf timeStringFromSeconds:totalTime];
        
        CGFloat playTime = 0;
        if (!weakSelf.cropModel.isSlideCrop) {
            playTime = weakSelf.playTime - weakSelf.cropModel.startTime;
        }
        weakSelf.playTimeLab.text = [weakSelf timeStringFromSeconds:playTime];
        
        CGFloat progress = playTime / totalTime;
        [weakSelf.progressSlider setProgressValue:progress animated:YES];
        
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(mediaPlayerTimeChanged)]) {
            [weakSelf.delegate mediaPlayerTimeChanged];
        }
    }];
}

#pragma mark - 监听播放状态
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = self.player.status;
        if (status == AVPlayerStatusReadyToPlay) {
            //准备播放
        }
        else if (status == AVPlayerStatusFailed) {
            NSLog(@"无法播放该视频");
        }
    }
    else if ([keyPath isEqualToString:@"timeControlStatus"]) {
        AVPlayerTimeControlStatus timeControlStatus = self.player.timeControlStatus;
        if (timeControlStatus == AVPlayerTimeControlStatusPaused) {
            if (self.playStatus != YXVideoEditPlayerStatusBeforePlaying) {
                self.playStatus = YXVideoEditPlayerStatusPause;
            }
        }
        else if (timeControlStatus == AVPlayerTimeControlStatusPlaying) {
            self.playStatus = YXVideoEditPlayerStatusPlaying;
        }
    }
}

#pragma mark - 监听播放结束的通知
- (void)playEndedNotice:(NSNotification *)notice {
    
    if (notice.object != _playerItem) {
        return;
    }
    
    [self.player seekToTime:CMTimeMakeWithSeconds(_cropModel.startTime, _cropModel.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
    if (_isCyclePlay) {
        [self play];
    }
    else {
        [self pause];
    }
}

#pragma mark - setting
- (void)setCropModel:(YXVideoEditCropModel *)cropModel {
    
    _cropModel = cropModel;
    
    NSURL *videoUrl = [NSURL fileURLWithPath:_cropModel.videoPath];
    [self initPlayerWithPlayerItem:[AVPlayerItem playerItemWithURL:videoUrl]];
    [self play];
}

#pragma mark - 设置播放音量
- (void)setPlayVolume:(CGFloat)playVolume {

    _playVolume = playVolume;
    
    NSMutableArray *inputParameters = [NSMutableArray array];
    NSArray *audioTracks = [self.playerItem.asset tracksWithMediaType:AVMediaTypeAudio];
    for (AVAssetTrack *track in audioTracks) {
        AVMutableAudioMixInputParameters *audioParameters = [AVMutableAudioMixInputParameters audioMixInputParameters];
        [audioParameters setVolume:self.playVolume atTime:kCMTimeZero];
        [audioParameters setTrackID:[track trackID]];
        [inputParameters addObject:audioParameters];
    }
    
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    audioMix.inputParameters = inputParameters;
    self.playerItem.audioMix = audioMix;
}

#pragma mark - 设置播放状态
- (void)setPlayStatus:(YXVideoEditPlayerStatus)playStatus {
    
    _playStatus = playStatus;
    
    if (_playStatus == YXVideoEditPlayerStatusPlaying || _playStatus == YXVideoEditPlayerStatusBeforePlaying) {
        self.playBtn.hidden = YES;
    }
    else {
        self.playBtn.hidden = NO;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(mediaPlayerStatusChanged)]) {
        [self.delegate mediaPlayerStatusChanged];
    }
}

#pragma mark - 初始化播放器
- (void)initPlayerWithPlayerItem:(AVPlayerItem *)playerItem {
    
    //播放数据源
    _playerItem = playerItem;
    
    //播放器
    self.player = [AVPlayer playerWithPlayerItem:_playerItem];
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    
    //缩放类型
    NSInteger videoGravity = [YXGPUImageUtils getVideoGravityWithAsset:_playerItem.asset];
    AVPlayerLayer *playerLayer = (AVPlayerLayer *)self.layer;
    if (videoGravity == 1) {
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    else {
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    }
    
    //总的时间
    _totalTime = CMTimeGetSeconds(_playerItem.asset.duration);
    _totalTimeLab.text = [self timeStringFromSeconds:_totalTime];
    
    //循环播放
    _isCyclePlay = YES;
    
    //播放音量
    _playVolume = 1;
    
    //监听播放时间
    [self addPeriodicTimeObserver];
    
    //监听播放状态
    [self.player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.player addObserver:self forKeyPath:@"timeControlStatus" options:NSKeyValueObservingOptionNew context:nil];
    
    //监听播放结束的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEndedNotice:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
    
    //点击手势
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(progressPlayBtn)];
    [self addGestureRecognizer:singleTap];
}

#pragma mark - 初始化视图
- (void)initView {
    
}

#pragma mark - 懒加载
- (UIButton *)playBtn {
    
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setImage:[UIImage imageNamed:@"YXVideoEditCropPlayImg"] forState:UIControlStateNormal];
        [_playBtn addTarget:self action:@selector(progressPlayBtn) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_playBtn];
        
        [_playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.center.equalTo(self);
        }];
    }
    return _playBtn;
}
- (UIView *)timeBgView {
    
    if (!_timeBgView) {
        _timeBgView = [[UIView alloc] init];
        _timeBgView.backgroundColor = [UIColor clearColor];
        [self addSubview:_timeBgView];
        
        [_timeBgView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.and.bottom.and.right.equalTo(self);
            make.height.mas_equalTo(44);
        }];
    }
    return _timeBgView;
}
- (UILabel *)playTimeLab {
    
    if (!_playTimeLab) {
        _playTimeLab = [[UILabel alloc] init];
        _playTimeLab.text = @"00:00";
        _playTimeLab.textAlignment = NSTextAlignmentLeft;
        _playTimeLab.font = [UIFont boldSystemFontOfSize:12];
        _playTimeLab.textColor = [UIColor colorWithHexString:@"#FFFFFF"];
        [self.timeBgView addSubview:_playTimeLab];
        
        [_playTimeLab mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.equalTo(self.timeBgView).with.offset(15);
            make.top.and.bottom.equalTo(self.timeBgView);
        }];
    }
    return _playTimeLab;
}
- (UILabel *)totalTimeLab {
    
    if (!_totalTimeLab) {
        _totalTimeLab = [[UILabel alloc] init];
        _totalTimeLab.text = @"00:00";
        _totalTimeLab.textAlignment = NSTextAlignmentLeft;
        _totalTimeLab.font = [UIFont boldSystemFontOfSize:12];
        _totalTimeLab.textColor = [UIColor colorWithHexString:@"#FFFFFF"];
        [self.timeBgView addSubview:_totalTimeLab];
        
        [_totalTimeLab mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.right.equalTo(self.timeBgView).with.offset(-15);
            make.top.and.bottom.equalTo(self.timeBgView);
        }];
    }
    return _totalTimeLab;
}
- (YCProgressSlider *)progressSlider {
    
    if (!_progressSlider) {
        _progressSlider = [[YCProgressSlider alloc] initWithFrame:CGRectMake(60, 0, self.timeBgView.frame.size.width - 120, 30)];
        _progressSlider.minimumColor = [UIColor whiteColor];
        _progressSlider.maximumColor = [UIColor whiteColor];
        _progressSlider.centerY = self.timeBgView.centerY;
        [self.timeBgView addSubview:_progressSlider];
        
        __weak typeof(self) weakSelf = self;
        _progressSlider.touchBeganBlock = ^{
            
            if (weakSelf.playStatus == YXVideoEditPlayerStatusPlaying) {
                weakSelf.playStatus = YXVideoEditPlayerStatusBeforePlaying;
                [weakSelf pause];
            }
        };
        _progressSlider.touchEndedBlock = ^{
            
            if (weakSelf.playStatus == YXVideoEditPlayerStatusBeforePlaying) {
                [weakSelf play];
            }
        };
        _progressSlider.valueChangedBlock = ^(CGFloat value) {
            
            CGFloat totalTime = weakSelf.cropModel.endTime - weakSelf.cropModel.startTime;
            CGFloat playTime = weakSelf.cropModel.startTime + (totalTime * value);
            [weakSelf.player seekToTime:CMTimeMakeWithSeconds(playTime, weakSelf.cropModel.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        };
    }
    return _progressSlider;
}

@end
