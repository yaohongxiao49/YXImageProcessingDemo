//
//  YXChooseImgCell.h
//  YXImageProcessingTest
//
//  Created by Believer on 10/12/21.
//

#import <UIKit/UIKit.h>
#import "YXChooseImgPhotoAssetModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXChooseImgCell : UICollectionViewCell

/** 资产数据 */
@property (nonatomic, strong) YXChooseImgPhotoAssetModel *assetModel;
/** 点击勾选的回调 */
@property (nonatomic, copy) void (^clickSelectBlock) (void);

@end

NS_ASSUME_NONNULL_END
