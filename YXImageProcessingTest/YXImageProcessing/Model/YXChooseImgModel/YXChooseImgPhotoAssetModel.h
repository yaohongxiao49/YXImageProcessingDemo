//
//  YXChooseImgPhotoAssetModel.h
//  YXImageProcessingTest
//
//  Created by Believer on 10/12/21.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXChooseImgPhotoAssetModel : NSObject

/** 资产 */
@property (nonatomic, strong, nullable) PHAsset *asset;
/** 是否激活 */
@property (nonatomic, assign) BOOL isEnabled;
/** 是否勾选 */
@property (nonatomic, assign) BOOL isSelect;
/** 勾选计数 */
@property (nonatomic, assign) NSInteger selectCount;

@end

NS_ASSUME_NONNULL_END
