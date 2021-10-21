//
//  YXVideoEditCropPopoutView.h
//  FateU
//
//  Created by Believer on 10/15/21.
//  Copyright © 2021 FateU_SYP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXVideoEditCropView.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXVideoEditCropPopoutView : UIView

@property (nonatomic, strong) UILabel *cropTimeLab; //截取时间
@property (nonatomic, strong) YXVideoEditCropView *cropView; //截取视图

/** 点击完成的回调 */
@property (nonatomic, copy) void (^clickFinishBlock) (void);

@end

NS_ASSUME_NONNULL_END
