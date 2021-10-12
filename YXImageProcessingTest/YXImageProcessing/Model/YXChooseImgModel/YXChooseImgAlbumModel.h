//
//  YXChooseImgAlbumModel.h
//  YXImageProcessingTest
//
//  Created by Believer on 10/12/21.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXChooseImgAlbumModel : NSObject

/** 专辑名称 */
@property (nonatomic, copy) NSString *albumName;
/** 专辑获取结果 */
@property (nonatomic, strong) PHFetchResult<PHAsset *> *fetchResult;

@end

NS_ASSUME_NONNULL_END
