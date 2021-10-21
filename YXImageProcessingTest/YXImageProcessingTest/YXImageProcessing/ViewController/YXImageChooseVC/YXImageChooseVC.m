//
//  YXImageChooseVC.m
//  YXImageProcessingTest
//
//  Created by Believer on 10/12/21.
//

#import "YXImageChooseVC.h"
#import "YXChooseVideoCell.h"
#import "YXChooseImgCell.h"

@interface YXImageChooseVC () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray *assetModelArr; //资产列表数据
@property (nonatomic, assign) PHAssetMediaType filterMediaType; //筛选的媒体类型
@property (nonatomic, assign) PHAssetMediaType selectMediaType; //勾选的媒体类型
@property (nonatomic, strong) NSMutableArray *selectAssetModelArr; //勾选的资产数据
@property (nonatomic, strong) NSMutableArray *selectAssetArr;
@property (nonatomic, assign) NSInteger selectCount; //勾选计数

@property (nonatomic, strong) UIView *navigationView; //导航栏
@property (nonatomic, strong) UIButton *backBtn; //返回按钮
@property (nonatomic, strong) UIButton *titleBtn; //标题
@property (nonatomic, strong) UICollectionView *collectionView; //图片列表

@end

@implementation YXImageChooseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [self initView];
}

#pragma mark - 刷新专辑数据
- (void)refreshAssetData {
    
    [_assetModelArr removeAllObjects];
    [_selectAssetModelArr removeAllObjects];
    
    //第一条数据为相机
    YXChooseImgPhotoAssetModel *model = [[YXChooseImgPhotoAssetModel alloc] init];
    [_assetModelArr addObject:model];
    
    //当前专辑的资产数据
    for (PHAsset *asset in _albumModel.fetchResult) {
        YXChooseImgPhotoAssetModel *model = [[YXChooseImgPhotoAssetModel alloc] init];
        model.asset = asset;
        
        //是否勾选
        if ([_selectAssetArr containsObject:asset]) {
            model.isSelect = YES;
        }
        else {
            model.isSelect = NO;
        }
        
        //勾选计数
        if (model.isSelect) {
            model.selectCount = [_selectAssetArr indexOfObject:asset] + 1;
        }
        else {
            model.selectCount = 0;
        }
        
        //是否激活
        if (_selectCount > 0) {
            //有勾选
            if (_selectMediaType == PHAssetMediaTypeImage && _selectMediaType == model.asset.mediaType && _selectCount < _mediaModel.maxNum) {
                model.isEnabled = YES;
            }
            else if (_selectMediaType == PHAssetMediaTypeImage && _selectCount >= _mediaModel.maxNum && model.isSelect) {
                model.isEnabled = YES;
            }
            else if (_selectMediaType == PHAssetMediaTypeVideo && model.isSelect) {
                model.isEnabled = YES;
            }
            else {
                model.isEnabled = NO;
            }
        }
        else {
            //无勾选
            if (_selectMediaType == PHAssetMediaTypeUnknown) {
                model.isEnabled = YES;
            }
            else if ((_selectMediaType == PHAssetMediaTypeImage || _selectMediaType == PHAssetMediaTypeVideo) && _selectMediaType == model.asset.mediaType) {
                model.isEnabled = YES;
            }
            else {
                model.isEnabled = NO;
            }
        }
        
        //筛选的媒体类型
        if (_filterMediaType == PHAssetMediaTypeUnknown || _filterMediaType == asset.mediaType) {
            [_assetModelArr addObject:model];
            if (model.isSelect) {
                [_selectAssetModelArr addObject:model];
            }
        }
    }
    
    //勾选的资产数据升序
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"selectCount" ascending:YES];
    [_selectAssetModelArr sortUsingDescriptors:@[descriptor]];
    [_collectionView reloadData];
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.assetModelArr.count;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    return 0;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.collectionView.frame.size;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    __weak typeof(self) weakSelf = self;
    YXChooseImgPhotoAssetModel *assetModel = self.assetModelArr[indexPath.row];
    if (assetModel.asset.mediaType == PHAssetMediaTypeImage) {
        YXChooseImgCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([YXChooseImgCell class]) forIndexPath:indexPath];
//        cell.browserVC = self;
//        cell.indexPath = indexPath;
//        cell.assetModel = assetModel;
//        cell.clickCellBlock = ^{
//
//            [weakSelf clickCell];
//        };
        return cell;
    }
    else if (assetModel.asset.mediaType == PHAssetMediaTypeVideo) {
        YXChooseVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([YXChooseVideoCell class]) forIndexPath:indexPath];
//        cell.browserVC = self;
//        cell.indexPath = indexPath;
//        cell.assetModel = assetModel;
//        cell.clickCellBlock = ^{
//
//            [weakSelf clickCell];
//        };
        return cell;
    }
    else {
        return [[UICollectionViewCell alloc] init];
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - 设置专辑数据
- (void)setAlbumModel:(YXChooseImgAlbumModel *)albumModel {
    
    _albumModel = albumModel;
//    _titleLabel.text = _albumModel.albumName;
    [self refreshAssetData];
}

#pragma mark - 初始化视图
- (void)initView {
    
    //资产列表数据
    _assetModelArr = [NSMutableArray array];
    _selectAssetModelArr = [NSMutableArray array];
    _selectAssetArr = [NSMutableArray array];
    
    _selectMediaType = PHAssetMediaTypeUnknown;
}

#pragma mark - 懒加载
- (UIView *)navigationView {
    
    if (!_navigationView) {
        
    }
    return _navigationView;
}
- (UIButton *)backBtn {
    
    if (!_backBtn) {
        
    }
    return _backBtn;
}
- (UIButton *)titleBtn {
    
    if (!_titleBtn) {
        
    }
    return _titleBtn;
}
- (UICollectionView *)collectionView {
    
    if (!_collectionView) {
        //列表布局
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        //列表视图
        _collectionView.collectionViewLayout = layout;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [self.view addSubview:_collectionView];
        
        [_collectionView registerClass:[YXChooseVideoCell class] forCellWithReuseIdentifier:NSStringFromClass([YXChooseVideoCell class])];
        [_collectionView registerClass:[YXChooseImgCell class] forCellWithReuseIdentifier:NSStringFromClass([YXChooseImgCell class])];
    }
    return _collectionView;
}

@end
