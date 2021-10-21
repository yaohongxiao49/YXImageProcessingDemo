//
//  YXChoosedImgListCell.h
//  FateU
//
//  Created by Believer on 10/14/21.
//  Copyright © 2021 FateU_SYP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXChooseImgPhotoAssetModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^YXChoosedImgListCellCancelBlock)(HXPhotoModel *selectedModel);

@interface YXChoosedImgListCell : UICollectionViewCell

/** 资产数据 */
@property (nonatomic, strong) HXPhotoModel *selectAssetModel;

/** 取消 */
@property (nonatomic, copy) YXChoosedImgListCellCancelBlock yxChoosedImgListCellCancelBlock;

@end

NS_ASSUME_NONNULL_END
