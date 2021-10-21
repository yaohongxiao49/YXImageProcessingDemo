//
//  YXVideoEditPlayerView.h
//  FateU
//
//  Created by Believer on 10/15/21.
//  Copyright © 2021 FateU_SYP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXVideoEditCropModel.h"

NS_ASSUME_NONNULL_BEGIN

/** 播放状态 */
typedef NS_ENUM(NSInteger, YXVideoEditPlayerStatus) {
    /** 暂停或结束 */
    YXVideoEditPlayerStatusPause = 0,
    /** 播放中 */
    YXVideoEditPlayerStatusPlaying,
    /** 之前是播放状态 */
    YXVideoEditPlayerStatusBeforePlaying,
};

@protocol YXVideoEditPlayerViewDelegate <NSObject>
@optional

/** 播放时间已改变 */
- (void)mediaPlayerTimeChanged;

/** 播放状态已改变 */
- (void)mediaPlayerStatusChanged;

@end


@interface YXVideoEditPlayerView : UIView

/** 播放数据源 */
@property (nonatomic, strong) AVPlayerItem *playerItem;
/** 播放器 */
@property (nonatomic, strong) AVPlayer *player;

/** 是否循环播放，默认YES */
@property (nonatomic, assign) BOOL isCyclePlay;
/** 总的时间 */
@property (nonatomic, assign) CGFloat totalTime;
/** 播放时间 */
@property (nonatomic, assign) CGFloat playTime;
/** 播放进度 */
@property (nonatomic, assign) CGFloat progress;
/** 播放音量 */
@property (nonatomic, assign) CGFloat playVolume;
/** 播放状态 */
@property (nonatomic, assign) YXVideoEditPlayerStatus playStatus;
/** 截取配置数据 */
@property (nonatomic, strong) YXVideoEditCropModel *cropModel;
/** 播放的代理 */
@property (nonatomic, weak) id<YXVideoEditPlayerViewDelegate>delegate;

/** 播放 */
- (void)play;

/** 暂停 */
- (void)pause;

@end

NS_ASSUME_NONNULL_END
