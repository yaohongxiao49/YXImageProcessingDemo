//
//  YCMediaPhotoBrowserVideoCell.h
//  RuLiMeiRong
//
//  Created by 余成国 on 2021/1/29.
//  Copyright © 2021 成都美哆网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXChooseImgPhotoAssetModel.h"
#import "YXImageAmplificationVC.h"
#import "YCProgressSlider.h"

NS_ASSUME_NONNULL_BEGIN

/** 播放状态 */
typedef NS_ENUM(NSInteger, YCMediaPhotoBrowserVideoStatus) {
    /** 暂停或结束 */
    YCMediaPhotoBrowserVideoStatusPause = 0,
    /** 播放中 */
    YCMediaPhotoBrowserVideoStatusPlaying,
    /** 之前是播放状态 */
    YCMediaPhotoBrowserVideoStatusBeforePlaying,
};

@interface YCMediaPhotoBrowserPlayerView : UIView

/** 播放器 */
@property (nonatomic, strong) AVPlayer *player;

@end

@interface YCMediaPhotoBrowserVideoCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeBaseViewBottom;

/** 播放器视图 */
@property (weak, nonatomic) IBOutlet YCMediaPhotoBrowserPlayerView *playerView;
/** 时间底视图 */
@property (weak, nonatomic) IBOutlet UIView *timeBaseView;
/** 播放按钮 */
@property (weak, nonatomic) IBOutlet UIButton *playButton;
/** 总的时间 */
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
/** 播放时间 */
@property (weak, nonatomic) IBOutlet UILabel *playTimeLabel;
/** 播放进度 */
@property (weak, nonatomic) IBOutlet YCProgressSlider *progressSlider;

/** 播放数据源 */
@property (nonatomic, strong) AVPlayerItem *playerItem;
/** 是否循环播放，默认YES */
@property (nonatomic, assign) BOOL isCyclePlay;
/** 总的时间 */
@property (nonatomic, assign) CGFloat totalTime;
/** 播放时间 */
@property (nonatomic, assign) CGFloat playTime;
/** 播放进度 */
@property (nonatomic, assign) CGFloat progress;
/** 播放状态 */
@property (nonatomic, assign) YCMediaPhotoBrowserVideoStatus playStatus;

/** 浏览器页面 */
@property (nonatomic, weak) YXImageAmplificationVC *browserVC;
/** 数据位置 */
@property (nonatomic, strong) NSIndexPath *indexPath;
/** 资产数据 */
@property (nonatomic, strong) YXChooseImgPhotoAssetModel *assetModel;
/** 点击cell的回调 */
@property (nonatomic, copy) void (^clickCellBlock) (void);

/** 播放 */
- (void)play;

/** 暂停 */
- (void)pause;

@end

NS_ASSUME_NONNULL_END
