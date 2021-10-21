//
//  YXImageEditBottomMenuView.h
//  FateU
//
//  Created by 北宸卿月 on 2021/10/16.
//  Copyright © 2021 FateU_SYP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMButton.h"

NS_ASSUME_NONNULL_BEGIN

@protocol YXImageEditBottomMenuViewDelegate <NSObject>

/// 点击底部菜单按钮的点击事件的代理方法
/// @param index 各个按钮的tag值
- (void)clickImageEditBottomMenutBtnAction:(NSInteger)index;

@end

@interface YXImageEditBottomMenuView : UIView

@property(nonatomic, weak) id<YXImageEditBottomMenuViewDelegate> delegate;

///初始化XIB视图
+ (instancetype)viewFromXIB;
@end

NS_ASSUME_NONNULL_END
