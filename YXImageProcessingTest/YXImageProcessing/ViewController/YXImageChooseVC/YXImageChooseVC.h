//
//  YXImageChooseVC.h
//  YXImageProcessingTest
//
//  Created by Believer on 10/12/21.
//

#import <UIKit/UIKit.h>
#import "YXChooseImgAlbumModel.h"
#import "YXChooseMediaModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^YXImageChooseVCBackBlock)(void);

@interface YXImageChooseVC : BaseViewController<JXCategoryListContentViewDelegate>

/** 专辑数据 */
@property (nonatomic, strong) YXChooseImgAlbumModel *albumModel;
/** 基础数据 */
@property (nonatomic, strong) YXChooseMediaModel *mediaModel;

/** 栏目切换视图 */
@property (nonatomic, strong) JXCategoryTitleView *categoryView;

/** 关闭回调 */
@property (nonatomic, copy) YXImageChooseVCBackBlock yxImageChooseVCBackBlock;

@end

NS_ASSUME_NONNULL_END
