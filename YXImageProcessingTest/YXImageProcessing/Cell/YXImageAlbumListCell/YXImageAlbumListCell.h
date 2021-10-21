//
//  YXImageAlbumListCell.h
//  FateU
//
//  Created by Believer on 10/13/21.
//  Copyright © 2021 FateU_SYP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXChooseImgAlbumModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXImageAlbumListCell : UITableViewCell

/** 专辑数据 */
@property (nonatomic, strong) YXChooseImgAlbumModel *albumModel;

@end

NS_ASSUME_NONNULL_END
