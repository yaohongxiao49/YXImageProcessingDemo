//
//  YXVideoEditVC.h
//  FateU
//
//  Created by Believer on 10/15/21.
//  Copyright © 2021 FateU_SYP. All rights reserved.
//

#import "BaseViewController.h"
#import "YXChooseImgPhotoAssetModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXVideoEditVC : BaseViewController

/** 原始数据 */
@property (nonatomic, strong) YXChooseImgPhotoAssetModel *originalAssetModel;

@end

NS_ASSUME_NONNULL_END
