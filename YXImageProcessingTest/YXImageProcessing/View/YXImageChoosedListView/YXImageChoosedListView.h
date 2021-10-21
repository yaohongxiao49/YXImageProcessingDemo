//
//  YXImageChoosedListView.h
//  FateU
//
//  Created by Believer on 10/14/21.
//  Copyright © 2021 FateU_SYP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXChoosedImgListCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^YXImageChoosedListViewBlock)(NSMutableArray *arr, BOOL boolMove, HXPhotoModel *model);
typedef void(^YXImageChoosedListViewNextStepBlock)(NSMutableArray *selectedAssetModelArr);

@interface YXImageChoosedListView : UIView

@property (nonatomic, strong) NSMutableArray *selectedArr;
/** 取消回调 */
@property (nonatomic, copy) YXImageChoosedListViewBlock yxImageChoosedListViewBlock;
/** 下一步回调 */
@property (nonatomic, copy) YXImageChoosedListViewNextStepBlock yxImageChoosedListViewNextStepBlock;

@end

NS_ASSUME_NONNULL_END
