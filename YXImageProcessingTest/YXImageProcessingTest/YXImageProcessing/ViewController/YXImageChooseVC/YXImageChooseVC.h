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

@interface YXImageChooseVC : UIViewController

/** 专辑数据 */
@property (nonatomic, strong) YXChooseImgAlbumModel *albumModel;
/** 基础数据 */
@property (nonatomic, strong) YXChooseMediaModel *mediaModel;

@end

NS_ASSUME_NONNULL_END
