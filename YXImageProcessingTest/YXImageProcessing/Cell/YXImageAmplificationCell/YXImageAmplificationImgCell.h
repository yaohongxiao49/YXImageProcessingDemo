//
//  YXImageAmplificationCell.h
//  FateU
//
//  Created by Believer on 10/14/21.
//  Copyright © 2021 FateU_SYP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXChooseImgPhotoAssetModel.h"
#import "YXImageAmplificationVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXImageAmplificationImgCell : UICollectionViewCell

/** 图片视图 */
@property (nonatomic, strong) UIImageView *imageView;

/** 浏览器页面 */
@property (nonatomic, weak) YXImageAmplificationVC *browserVC;
/** 数据位置 */
@property (nonatomic, strong) NSIndexPath *indexPath;
/** 资产数据 */
@property (nonatomic, strong) YXChooseImgPhotoAssetModel *assetModel;
/** 点击cell的回调 */
@property (nonatomic, copy) void (^clickCellBlock) (void);

@end

NS_ASSUME_NONNULL_END
