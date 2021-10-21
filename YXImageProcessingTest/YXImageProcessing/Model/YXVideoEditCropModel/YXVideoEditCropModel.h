//
//  YXVideoCropModel.h
//  FateU
//
//  Created by Believer on 10/15/21.
//  Copyright © 2021 FateU_SYP. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXVideoEditCropModel : NSObject

/** 视频路径 */
@property (nonatomic, copy, readonly) NSString *videoPath;
/** 视频时标 */
@property (nonatomic, assign, readonly) CGFloat timescale;
/** 总的时间 */
@property (nonatomic, assign, readonly) CGFloat totalTime;
/** 最小时间 */
@property (nonatomic, assign, readonly) CGFloat minTime;
/** 最大时间 */
@property (nonatomic, assign, readonly) CGFloat maxTime;
/** 帧图片数 */
@property (nonatomic, assign, readonly) NSInteger imageNum;

/** 开始时间 */
@property (nonatomic, assign) CGFloat startTime;
/** 结束时间 */
@property (nonatomic, assign) CGFloat endTime;
/** 截取时间 */
@property (nonatomic, assign) CGFloat cropTime;
/** 是否在滑动截取 */
@property (nonatomic, assign) BOOL isSlideCrop;

/**
 *  初始化
 *  @param videoPath 视频路径
 *  @param minTime 最小时间
 *  @param maxTime 最大时间
 *  @param imageNum 帧图片数
 */
- (instancetype)initWithVideoPath:(NSString *)videoPath minTime:(CGFloat)minTime maxTime:(CGFloat)maxTime imageNum:(NSInteger)imageNum;

@end

NS_ASSUME_NONNULL_END
