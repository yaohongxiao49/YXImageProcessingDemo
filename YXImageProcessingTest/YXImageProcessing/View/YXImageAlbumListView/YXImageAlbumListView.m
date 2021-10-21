//
//  YXImageAlbumListView.m
//  FateU
//
//  Created by Believer on 10/13/21.
//  Copyright © 2021 FateU_SYP. All rights reserved.
//

#import "YXImageAlbumListView.h"

@interface YXImageAlbumListView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *albumModelArr; //专辑列表数据
@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, assign) NSInteger currentIndex; //当前下标

@end

@implementation YXImageAlbumListView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [[UIColor colorWithHexString:@"#000000"] colorWithAlphaComponent:0.7];
        [self initView];
    }
    return self;
}

#pragma mark - 获取专辑列表数据
- (void)getAlbumListData {
    
    //系统智能专辑
    PHFetchResult *smartCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    NSMutableArray *allCollections = [NSMutableArray array];
    PHAssetCollection *mainAssetCollection = nil;
    for (PHAssetCollection *assetCollection in smartCollections) {
        if ([self isMainAlbumWithAssetCollection:assetCollection]) {
            mainAssetCollection = assetCollection;
        }
        else {
            [allCollections addObject:assetCollection];
        }
    }
    if (mainAssetCollection != nil) {
        [allCollections insertObject:mainAssetCollection atIndex:0];
    }
    
    //用户创建的专辑
    PHFetchResult *userCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    for (PHAssetCollection *assetCollection in userCollections) {
        [allCollections addObject:assetCollection];
    }
    
    //专辑资产
    [_albumModelArr removeAllObjects];
    for (PHAssetCollection *assetCollection in allCollections) {
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        
        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
        if (fetchResult.count > 0) {
            YXChooseImgAlbumModel *model = [[YXChooseImgAlbumModel alloc] init];
            model.albumName = assetCollection.localizedTitle;
            model.fetchResult = fetchResult;
            [_albumModelArr addObject:model];
        }
    }
    
    //默认选择第一个专辑数据
    if (_selectAlbumModel == nil && _albumModelArr.count > 0) {
        _selectAlbumModel = [_albumModelArr firstObject];
    }
    
    [self.tableView reloadData];
}

#pragma mark - 判断是主专辑
- (BOOL)isMainAlbumWithAssetCollection:(PHAssetCollection *)assetCollection {
    
    NSString *versionStr = [[UIDevice currentDevice].systemVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (versionStr.length <= 1) {
        versionStr = [versionStr stringByAppendingString:@"00"];
    }
    else if (versionStr.length <= 2) {
        versionStr = [versionStr stringByAppendingString:@"0"];
    }
    
    CGFloat version = versionStr.floatValue;
    if (version >= 800 && version <= 802) {
        return assetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumRecentlyAdded;
    }
    else {
        return assetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary;
    }
}

#pragma mark - 显示
- (void)showInView:(UIView *)view {
    
    __weak typeof(self) weakSelf = self;
    CGFloat height = kScreenHeight - self.yc_naHeight;
    self.frame = CGRectMake(0, self.yc_naHeight + 20, kScreenWidth, height);
    [view addSubview:self];
    
    self.maskView.height = self.height - ((kScreenHeight - self.yc_naHeight) / 2);
    [UIView animateWithDuration:0.2 animations:^{
        
        weakSelf.tableView.height = ((kScreenHeight - weakSelf.yc_naHeight) / 2);
    } completion:^(BOOL finished) {}];
}

#pragma mark - 关闭
- (void)close {
    
    __weak typeof(self) weakSelf = self;
    self.height = 1;
    self.maskView.height = 1;
    [UIView animateWithDuration:0.2 animations:^{
        
        weakSelf.tableView.height = 1;
    } completion:^(BOOL finished) {
        
        [weakSelf removeFromSuperview];
    }];
}

#pragma mark - 数据更新
- (void)valueReloadByBoolReloadTitle:(BOOL)boolReloadTitle {
    
    self.selectAlbumModel = _albumModelArr[_currentIndex];
    if (self.clickAlbumBlock) {
        self.clickAlbumBlock(self.selectAlbumModel, NO, boolReloadTitle);
    }
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _albumModelArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YXImageAlbumListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YXImageAlbumListCell class])];
    cell.albumModel = _albumModelArr[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    _currentIndex = indexPath.row;
    [self valueReloadByBoolReloadTitle:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0.0001;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.0001;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 70;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    return [[UIView alloc] init];
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    return [[UIView alloc] init];
}

#pragma mark - 初始化视图
- (void)initView {
    
    //专辑列表数据
    _albumModelArr = [NSMutableArray array];
    [self getAlbumListData];
}

#pragma mark - 懒加载
- (UITableView *)tableView {
    
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 70;
        _tableView.backgroundColor = [UIColor colorWithHexString:@"#000000"];
        [self addSubview:_tableView];
        
        [_tableView registerClass:YXImageAlbumListCell.class forCellReuseIdentifier:NSStringFromClass([YXImageAlbumListCell class])];
    }
    return _tableView;
}
- (UIView *)maskView {
    
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, (kScreenHeight - self.yc_naHeight) / 2, kScreenWidth, 1)];
        _maskView.backgroundColor = [UIColor clearColor];
        [self addSubview:_maskView];
        
        __weak typeof(self) weakSelf = self;
        [_maskView addTapGestureWithBlock:^(UIView *view) {
           
            if (weakSelf.clickAlbumBlock) {
                weakSelf.clickAlbumBlock(weakSelf.selectAlbumModel, YES, YES);
            }
        }];
    }
    return _maskView;
}

@end
