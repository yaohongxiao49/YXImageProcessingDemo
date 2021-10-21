//
//  YXVideoCropModel.m
//  FateU
//
//  Created by Believer on 10/15/21.
//  Copyright © 2021 FateU_SYP. All rights reserved.
//

#import "YXVideoEditCropModel.h"

@implementation YXVideoEditCropModel

#pragma mark - 初始化
- (instancetype)initWithVideoPath:(NSString *)videoPath minTime:(CGFloat)minTime maxTime:(CGFloat)maxTime imageNum:(NSInteger)imageNum {
    
    self = [super init];
    if (self) {
        AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:videoPath]];
        
        //视频路径
        _videoPath = videoPath;
        //视频时标
        _timescale = asset.duration.timescale;
        //总的时间
        _totalTime = CMTimeGetSeconds(asset.duration);
        //最小时间
        _minTime = minTime < 0 ? 0 : minTime;
        //最大时间
        _maxTime = maxTime > _totalTime ? _totalTime : maxTime;
        //帧图片数
        _imageNum = imageNum < 0 ? 0 : imageNum;
    }
    return self;
}

#pragma mark - 设置开始时间
- (void)setStartTime:(CGFloat)startTime {

    if (startTime < 0 || (startTime >= _totalTime) || (_endTime > 0 && startTime >= _endTime)) {
        _startTime = 0;
    }
    else {
        _startTime = startTime;
    }
    
    _cropTime = _endTime - _startTime;
}

#pragma mark - 设置结束时间
- (void)setEndTime:(CGFloat)endTime {

    if (endTime < 0 || (endTime >= _totalTime) || (_startTime > 0 && endTime <= _startTime)) {
        _endTime = _totalTime;
    }
    else {
        _endTime = endTime;
    }
    
    _cropTime = _endTime - _startTime;
}

@end
