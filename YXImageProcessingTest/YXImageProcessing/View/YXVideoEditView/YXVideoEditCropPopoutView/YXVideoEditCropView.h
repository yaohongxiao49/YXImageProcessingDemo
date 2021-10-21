//
//  YXVideoEditCropView.h
//  FateU
//
//  Created by Believer on 10/15/21.
//  Copyright © 2021 FateU_SYP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXVideoEditCropModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^YXVideoEditCropFinishedBlock) (BOOL isSuccess);

@protocol YXVideoEditCropViewDelegate <NSObject>
@optional

/** 按住滑块 */
- (void)cropSliderTouchBegan;

/** 放开滑块 */
- (void)cropSliderTouchEnded;

/** 滑动滑块到的时间 */
- (void)cropSliderMovedToTime:(CGFloat)time;

@end

@interface YXVideoEditCropView : UIView

/** 播放进度 */
@property (nonatomic, assign) CGFloat progress;
/** 截取配置数据 */
@property (nonatomic, strong) YXVideoEditCropModel *cropModel;
/** 截取的代理 */
@property (nonatomic, weak) id<YXVideoEditCropViewDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
