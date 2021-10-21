//
//  YXVideoEditVC.m
//  FateU
//
//  Created by Believer on 10/15/21.
//  Copyright © 2021 FateU_SYP. All rights reserved.
//

#import "YXVideoEditVC.h"
#import "YXVideoEditPlayerView.h"
#import "YXVideoEditCropPopoutView.h"

@interface YXVideoEditVC () <YXVideoEditPlayerViewDelegate, YXVideoEditCropViewDelegate>

@property (nonatomic, strong) UIView *navigationView; //导航栏
@property (nonatomic, strong) UIButton *backBtn; //返回按钮
@property (nonatomic, strong) UIButton *sureBtn; //完成按钮
@property (nonatomic, strong) YXVideoEditPlayerView *playerView; //播放视图
@property (nonatomic, strong) YXVideoEditCropPopoutView *cropPopoutView; //裁剪视图

/** 截取配置数据 */
@property (nonatomic, strong) YXVideoEditCropModel *cropModel;
/** 开始时间 */
@property (nonatomic, assign) CGFloat startTime;
/** 结束时间 */
@property (nonatomic, assign) CGFloat endTime;

/** 视频请求ID */
@property (nonatomic, assign) PHImageRequestID imageRequestID;

@end

@implementation YXVideoEditVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"#000000"];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO; //禁用侧滑手势
    self.fd_interactivePopDisabled = YES;
    
    [self initView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.playerView.playStatus == YXVideoEditPlayerStatusPlaying) {
        self.playerView.playStatus = YXVideoEditPlayerStatusBeforePlaying;
        [self.playerView.player pause];
    }
}

#pragma mark - progress
#pragma mark - 返回按钮
- (void)progressBackBtn {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 完成按钮
- (void)progressSureBtn {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - <YXVideoEditPlayerViewDelegate>
- (void)mediaPlayerTimeChanged {
    
    self.cropPopoutView.cropView.progress = self.playerView.progress;
}

#pragma mark - <YXVideoEditCropViewDelegate>
- (void)cropSliderTouchBegan {
    
    self.playerView.playerItem.forwardPlaybackEndTime = CMTimeMakeWithSeconds(_cropModel.totalTime, _cropModel.timescale);
}
- (void)cropSliderTouchEnded {
    
    self.playerView.playerItem.forwardPlaybackEndTime = CMTimeMakeWithSeconds(_cropModel.endTime, _cropModel.timescale);
    
    if (self.playerView.playStatus == YXVideoEditPlayerStatusBeforePlaying) {
        [self.playerView play];
    }
}
- (void)cropSliderMovedToTime:(CGFloat)time {
    
    [self.playerView.player seekToTime:CMTimeMakeWithSeconds(time, _cropModel.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
    if (self.playerView.playStatus == YXVideoEditPlayerStatusPlaying) {
        self.playerView.playStatus = YXVideoEditPlayerStatusBeforePlaying;
        [self.playerView.player pause];
    }
    
    self.cropPopoutView.cropTimeLab.text = [NSString stringWithFormat:@"已选取%.1fs", self.cropModel.cropTime];
}

#pragma mark - setting
- (void)setOriginalAssetModel:(YXChooseImgPhotoAssetModel *)originalAssetModel {
    
    _originalAssetModel = originalAssetModel;
    
    //取消上次的视频请求
    if (_imageRequestID != 0) {
        [[PHImageManager defaultManager] cancelImageRequest:_imageRequestID];
        _imageRequestID = 0;
    }

    //视频请求
    __weak typeof(self) weakSelf = self;
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionCurrent; //原始或编辑后的视频
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat; //最高质量
    options.networkAccessAllowed = YES; //网络下载

    _imageRequestID = [[PHImageManager defaultManager] requestAVAssetForVideo:_originalAssetModel.asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {

        dispatch_async(dispatch_get_main_queue(), ^{
            if ([asset isKindOfClass:[AVURLAsset class]]) {
                AVURLAsset *urlAsset = (AVURLAsset *)asset;
                weakSelf.cropModel = [[YXVideoEditCropModel alloc] initWithVideoPath:urlAsset.URL.absoluteString minTime:3 maxTime:180 imageNum:16];
                weakSelf.cropModel.startTime = 0;
                weakSelf.cropModel.endTime = 30;
                weakSelf.startTime = weakSelf.cropModel.startTime;
                weakSelf.endTime = weakSelf.cropModel.endTime;

                weakSelf.playerView.cropModel = weakSelf.cropModel;
                weakSelf.cropPopoutView.cropView.cropModel = weakSelf.cropModel;
            }
        });
    }];
}

#pragma mark - 初始化视图
- (void)initView {
    
    [self.sureBtn setTitle:@"完成" forState:UIControlStateNormal];
    
    if (self.playerView.playStatus == YXVideoEditPlayerStatusBeforePlaying) {
        [self.playerView play];
    }
}

#pragma mark - 懒加载
- (UIView *)navigationView {
    
    if (!_navigationView) {
        _navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, self.yc_naHeight)];
        _navigationView.backgroundColor = [UIColor colorWithHexString:@"#000000"];
        [self.view addSubview:_navigationView];
        
        [_navigationView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.and.top.and.right.equalTo(self.view);
            make.height.mas_equalTo(self.yc_naHeight);
        }];
    }
    return _navigationView;
}
- (UIButton *)backBtn {
    
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UIImage imageNamed:@"back_white"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(progressBackBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationView addSubview:_backBtn];
        
        [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.and.bottom.equalTo(self.navigationView);
            make.width.and.height.mas_equalTo(44);
        }];
    }
    return _backBtn;
}
- (UIButton *)sureBtn {
    
    if (!_sureBtn) {
        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sureBtn setTitleColor:[UIColor colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
        [_sureBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_sureBtn addTarget:self action:@selector(progressSureBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationView addSubview:_sureBtn];
        
        [_sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.right.equalTo(self.navigationView).with.offset(-15);
            make.centerY.equalTo(self.backBtn);
        }];
    }
    return _sureBtn;
}
- (YXVideoEditCropModel *)cropModel {
    
    if (!_cropModel) {
        _cropModel = [[YXVideoEditCropModel alloc] initWithVideoPath:@"" minTime:3 maxTime:180 imageNum:16];
        _cropModel.startTime = 0;
        _cropModel.endTime = 30;
    }
    return _cropModel;
}
- (YXVideoEditPlayerView *)playerView {
    
    if (!_playerView) {
        _playerView = [[YXVideoEditPlayerView alloc] init];
        _playerView.delegate = self;
        [self.view addSubview:_playerView];
        [self.view sendSubviewToBack:_playerView];
        
        [_playerView mas_makeConstraints:^(MASConstraintMaker *make) {

            make.top.equalTo(self.navigationView.mas_bottom);
            make.left.and.right.equalTo(self.view);
            make.bottom.equalTo(self.cropPopoutView.mas_top);
        }];
    }
    return _playerView;
}
- (YXVideoEditCropPopoutView *)cropPopoutView {
    
    if (!_cropPopoutView) {
        _cropPopoutView = [[YXVideoEditCropPopoutView alloc] init];
        _cropPopoutView.cropView.delegate = self;
        [self.view addSubview:_cropPopoutView];
        
        [_cropPopoutView mas_makeConstraints:^(MASConstraintMaker *make) {

            make.left.and.right.and.bottom.equalTo(self.view);
            make.height.mas_equalTo((130 + self.yc_xBarHeight));
        }];
        
        __weak typeof(self) weakSelf = self;
        _cropPopoutView.clickFinishBlock = ^{
            
            weakSelf.startTime = weakSelf.cropModel.startTime;
            weakSelf.endTime = weakSelf.cropModel.endTime;
        };
    }
    return _cropPopoutView;
}

@end
