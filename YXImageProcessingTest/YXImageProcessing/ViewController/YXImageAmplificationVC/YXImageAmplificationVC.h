//
//  YXImageAmplificationVC.h
//  FateU
//
//  Created by Believer on 10/13/21.
//  Copyright © 2021 FateU_SYP. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXImageAmplificationVC : BaseViewController

@property (nonatomic, strong) UIView *navigationView; //导航栏

/** 资产列表数据 */
@property (nonatomic, strong) NSMutableArray *assetModelArr;
/** 显示的位置 */
@property (nonatomic, assign) NSInteger currentIndex;
/** 点击勾选的回调 */
@property (nonatomic, copy) void (^clickSelectBlock) (NSInteger currentIndex);

@end

NS_ASSUME_NONNULL_END
