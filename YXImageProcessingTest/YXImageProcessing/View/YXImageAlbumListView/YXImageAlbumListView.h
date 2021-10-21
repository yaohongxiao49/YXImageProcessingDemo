//
//  YXImageAlbumListView.h
//  FateU
//
//  Created by Believer on 10/13/21.
//  Copyright © 2021 FateU_SYP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXImageAlbumListCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXImageAlbumListView : UIView

/** 选择的专辑数据 */
@property (nonatomic, strong) YXChooseImgAlbumModel *selectAlbumModel;
/** 点击专辑的回调 */
@property (nonatomic, copy) void (^clickAlbumBlock) (YXChooseImgAlbumModel *albumModel, BOOL boolBlank, BOOL boolReloadTitle);

/** 获取专辑数据 */
- (void)getAlbumListData;

/**
 * 数据更新
 * @param boolReloadTitle 是否刷新标题
 */
- (void)valueReloadByBoolReloadTitle:(BOOL)boolReloadTitle;

/** 显示 */
- (void)showInView:(UIView *)view;

/** 关闭 */
- (void)close;

@end

NS_ASSUME_NONNULL_END
