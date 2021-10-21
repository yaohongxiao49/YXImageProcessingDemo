//
//  YXImageChooseVC.m
//  YXImageProcessingTest
//
//  Created by Believer on 10/12/21.
//

#import "YXImageChooseVC.h"
#import "YXChooseImgCell.h"
#import "YXImageAlbumListView.h"
#import "YXImageAmplificationVC.h"
#import "YXImageChoosedListView.h"
#import "YXVideoEditVC.h"
#import "YXImageEditVC.h"
#import "HXVideoEditViewController.h"

@interface YXImageChooseVC () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) NSMutableArray *assetModelArr; //资产列表数据
@property (nonatomic, assign) PHAssetMediaType filterMediaType; //筛选的媒体类型
@property (nonatomic, assign) PHAssetMediaType selectMediaType; //勾选的媒体类型
@property (nonatomic, strong) NSMutableArray *selectAssetModelArr; //勾选的资产数据
@property (nonatomic, strong) NSMutableArray *selectAssetArr;
@property (nonatomic, assign) NSInteger selectCount; //勾选计数

@property (nonatomic, strong) UIView *navigationView; //导航栏
@property (nonatomic, strong) UIButton *backBtn; //返回按钮
@property (nonatomic, strong) UIButton *titleBtn; //标题
@property (nonatomic, strong) UIImageView *unfoldImageView; //箭头
@property (nonatomic, strong) UICollectionView *collectionView; //图片列表
@property (nonatomic, strong) YXImageAlbumListView *albumListView; //专辑列表

@property (nonatomic, strong) UIImagePickerController *imgPickerVC; //照片选择器
@property (nonatomic, strong) YXImageChoosedListView *choosedListView; //已选中照片列表

@property (nonatomic, assign) PHImageRequestID imageRequestID; //视频请求ID
@property (nonatomic, strong) HXPhotoManager *manager;
@property (nonatomic, assign) BOOL isMemmber; //是不是会员

@end

@implementation YXImageChooseVC

- (UIView *)listView {
    
    return self.view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"#000000"];
    
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _isMemmber = [NSUserDf_Get(kUserMember) boolValue];
    [self judgeImgChoosedListView];
}

#pragma mark - 刷新专辑数据
- (void)refreshAssetData {
    
    [_assetModelArr removeAllObjects];
    [_selectAssetModelArr removeAllObjects];
    
    //第一条数据为相机
    YXChooseImgPhotoAssetModel *model = [[YXChooseImgPhotoAssetModel alloc] init];
    [_assetModelArr insertObject:model atIndex:0];
    
    //当前专辑的资产数据
    for (PHAsset *asset in self.albumModel.fetchResult) {
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
        if (_selectCount > 0) { //有勾选
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
        else { //无勾选
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
            [_assetModelArr insertObject:model atIndex:0];
            if (model.isSelect) {
                [_selectAssetModelArr addObject:model];
            }
        }
    }
    
    //勾选的资产数据升序
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"selectCount" ascending:YES];
    [_selectAssetModelArr sortUsingDescriptors:@[descriptor]];
        
    [self.collectionView reloadData];
    
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [weakSelf.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.assetModelArr.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    });
    
    
    [self judgeImgChoosedListView];
}

#pragma mark - 判断图片选中视图显示
- (void)judgeImgChoosedListView {
    
    if (_selectAssetModelArr.count != 0) {
        [self imgChoosedListViewShowByBoolShow:YES];
    }
    else {
        [self imgChoosedListViewShowByBoolShow:NO];
    }
}

#pragma mark - 图片选中视图的出现与隐藏
- (void)imgChoosedListViewShowByBoolShow:(BOOL)boolShow {
    
    __weak typeof(self) weakSelf = self;
//    self.choosedListView.selectAssetModelArr = _selectAssetModelArr;
    if (boolShow) {
        self.categoryView.hidden = YES;
        [self.collectionView.superview layoutIfNeeded];
        [UIView animateWithDuration:0.3 animations:^{
           
            weakSelf.choosedListView.y = kScreenHeight - weakSelf.choosedListView.height;
            [weakSelf.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {

                make.bottom.equalTo(self.view).with.offset(-self.choosedListView.height -20);
            }];
            [weakSelf.collectionView.superview layoutIfNeeded];
        }];
    }
    else {
        [self.collectionView.superview layoutIfNeeded];
        [UIView animateWithDuration:0.3 animations:^{
           
            weakSelf.choosedListView.y = kScreenHeight;
            [weakSelf.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
               
                make.bottom.equalTo(self.view).with.offset(-self.yc_tabBarHeight);
            }];
            [weakSelf.collectionView.superview layoutIfNeeded];
        }];
        self.categoryView.hidden = NO;
    }
}

#pragma mark - 跳转拍照
- (void)pushToTakePic {
    
    [self imgChoosedListViewShowByBoolShow:NO];
    [self presentViewController:self.imgPickerVC animated:YES completion:nil];
}

#pragma mark - 跳转照片浏览
- (void)pushToImgShowByAssetModelArr:(NSMutableArray *)assetModelArr currentIndex:(NSInteger)currentIndex {
    
    __weak typeof(self) weakSelf = self;
    
    [self imgChoosedListViewShowByBoolShow:NO];
    
    YXImageAmplificationVC *vc = [[YXImageAmplificationVC alloc] init];
    vc.assetModelArr = assetModelArr;
    vc.currentIndex = currentIndex;
    vc.clickSelectBlock = ^(NSInteger currentIndex) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentIndex + 1 inSection:0];
        [weakSelf clickSelectAtIndexPath:indexPath];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 跳转至视频编辑
- (void)pushToVideoEditByModel:(YXChooseImgPhotoAssetModel *)model {
    
//    YXVideoEditVC *vc = [[YXVideoEditVC alloc] init];
//    vc.originalAssetModel = model;
//    [self.navigationController pushViewController:vc animated:YES];
    
    //取消上次的视频请求
    if (_imageRequestID != 0) {
        [[PHImageManager defaultManager] cancelImageRequest:_imageRequestID];
        _imageRequestID = 0;
    }

    //视频请求
    __weak typeof(self) weakSelf = self;
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionCurrent; //原始或编辑后的视频
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat; //最高质量
    options.networkAccessAllowed = YES; //网络下载

    _imageRequestID = [[PHImageManager defaultManager] requestAVAssetForVideo:model.asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {

        dispatch_async(dispatch_get_main_queue(), ^{
            HXVideoEditViewController *vc = [[HXVideoEditViewController alloc] init];
//            vc.model = [self.modelArray objectAtIndex:self.currentModelIndex];
            vc.avAsset = asset;
            vc.delegate = self;
            vc.manager = self.manager;
            vc.isInside = YES;
//            vc.outside = self.outside;
            vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
            vc.modalPresentationCapturesStatusBarAppearance = YES;
            [self presentViewController:vc animated:YES completion:nil];
        });
    }];
    
}

#pragma mark - 跳转图片编辑
- (void)progressNextStepBySelectedAssetModelArr:(NSMutableArray *)seletextAssetModelArr {
    
    YXImageEditVC *vc = [[YXImageEditVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - progress
#pragma mark - 返回按钮事件
- (void)progressBackBtn {
    
    [self imgChoosedListViewShowByBoolShow:NO];
    if (self.yxImageChooseVCBackBlock) {
        self.yxImageChooseVCBackBlock();
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - 点击选择相册按钮
- (void)progressTitleBtn:(UIButton *)sender {
    
    sender.selected =! sender.selected;
    if (sender.selected) {
        [self.albumListView showInView:self.view];
        self.unfoldImageView.transform = CGAffineTransformMakeRotation(180 * (M_PI / 180));
    }
    else {
        [self.albumListView close];
        self.unfoldImageView.transform = CGAffineTransformMakeRotation(0 * (M_PI / 180));
    }
}

#pragma mark - 点击勾选
- (void)clickSelectAtIndexPath:(NSIndexPath *)indexPath {
    
    YXChooseImgPhotoAssetModel *assetModel = _assetModelArr[indexPath.row];
    
    //勾选禁止
    if (!assetModel.isEnabled) {
        NSString *title = nil;
        if (_selectMediaType == PHAssetMediaTypeImage) {
            if (assetModel.asset.mediaType == PHAssetMediaTypeImage) {
                title = [NSString stringWithFormat:@"最多只能选择%@张照片", @(_mediaModel.maxNum)];
            }
            else if (assetModel.asset.mediaType == PHAssetMediaTypeVideo) {
                title = @"照片和视频不能同时选择";
            }
        }
        else if (_selectMediaType == PHAssetMediaTypeVideo) {
            if (assetModel.asset.mediaType == PHAssetMediaTypeImage) {
                title = @"照片和视频不能同时选择";
            }
            else if (assetModel.asset.mediaType == PHAssetMediaTypeVideo) {
                title = [NSString stringWithFormat:@"最多只能选择%@个视频", @(1)];
            }
        }
        if (title.length > 0) {
            [self showMessage:title];
        }
        return;
    }
    
    if (assetModel.asset.mediaType == PHAssetMediaTypeVideo) {
        [self pushToVideoEditByModel:assetModel];
    }
    else {
        [self chooseMethodByAssetModel:assetModel];
    }
}

#pragma mark - 勾选处理
- (void)chooseMethodByAssetModel:(YXChooseImgPhotoAssetModel *)assetModel {
    
    //是否勾选
    if (assetModel.isSelect) {
        _selectCount --;
        assetModel.selectCount = 0;
        assetModel.isSelect = NO;
        [_selectAssetModelArr removeObject:assetModel];
        [_selectAssetArr removeObject:assetModel.asset];
    }
    else {
        _selectCount ++;
        assetModel.selectCount = _selectCount;
        assetModel.isSelect = YES;
        [_selectAssetModelArr addObject:assetModel];
        [_selectAssetArr addObject:assetModel.asset];
    }
    
    //是否激活
    if (_selectCount == 0) {
        _selectMediaType = PHAssetMediaTypeUnknown;
        for (YXChooseImgPhotoAssetModel *model in _assetModelArr) {
            if (_selectMediaType == PHAssetMediaTypeUnknown || _selectMediaType == model.asset.mediaType) {
                model.isEnabled = YES;
            }
            else {
                model.isEnabled = NO;
            }
        }
    }
    else if (_selectCount == 1) {
        _selectMediaType = assetModel.asset.mediaType;
        for (YXChooseImgPhotoAssetModel *model in _assetModelArr) {
            if (_selectMediaType == PHAssetMediaTypeImage && _selectMediaType == model.asset.mediaType) {
                //图片可以选择
                model.isEnabled = YES;
            }
            else if (_selectMediaType == PHAssetMediaTypeVideo && model.isSelect) {
                //选中的这个视频可以选择，视频只能选择一个
                model.isEnabled = YES;
            }
            else {
                //其他不能选择
                model.isEnabled = NO;
            }
        }
    }
    
    //勾选图片最大数
    if (_selectMediaType == PHAssetMediaTypeImage) {
        for (YXChooseImgPhotoAssetModel *model in _assetModelArr) {
            if (_selectCount >= _mediaModel.maxNum && model.isSelect) {
                model.isEnabled = YES;
            }
            else if (_selectCount < _mediaModel.maxNum && _selectMediaType == model.asset.mediaType) {
                model.isEnabled = YES;
            }
            else {
                model.isEnabled = NO;
            }
        }
    }
    
    //刷新勾选计数
    NSInteger selectCount = 1;
    for (YXChooseImgPhotoAssetModel *model in _selectAssetModelArr) {
        model.selectCount = selectCount;
        selectCount ++;
    }
    
    [self.collectionView reloadData];
    
    [self judgeImgChoosedListView];
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _assetModelArr.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    __weak typeof(self) weakSelf = self;
    YXChooseImgCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([YXChooseImgCell class]) forIndexPath:indexPath];
    cell.assetModel = _assetModelArr[indexPath.row];
    cell.clickSelectBlock = ^{
        
        [weakSelf clickSelectAtIndexPath:indexPath];
    };
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    YXChooseImgPhotoAssetModel *assetModel = _assetModelArr[indexPath.row];
    if (assetModel.asset == nil) { //拍照
        [self pushToTakePic];
    }
    else { //相册浏览器
        NSMutableArray *assetModelArr = [NSMutableArray arrayWithArray:_assetModelArr];
        [assetModelArr removeObjectAtIndex:0];
        [self pushToImgShowByAssetModelArr:assetModelArr currentIndex:indexPath.row - 1];
    }
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger w = (NSInteger)((self.view.frame.size.width - 20) / 3.f);
    return CGSizeMake(w, w);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 10;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    return 10;
}

#pragma mark - <UIImagePickerControllerDelegate>
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    __weak typeof(self) weakSelf = self;
    //获取图片
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [[WMZPermission shareInstance] permissonType:PermissionTypePhoto withHandle:^(BOOL granted, id data) {
    
        if (granted) {
            NSMutableArray *imageIds = [NSMutableArray array];
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                
                //写入图片到相册
                PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
                //记录本地标识，等待完成后取到相册中的图片对象
                [imageIds addObject:req.placeholderForCreatedAsset.localIdentifier];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                
                if (success) { //成功后取相册中的图片对象
                    __block PHAsset *imageAsset = nil;
                    PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:imageIds options:nil];
                    [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        
                        imageAsset = obj;
                        *stop = YES;
                    }];
                    
                    if (imageAsset) {
                        weakSelf.selectCount ++;
                        weakSelf.selectMediaType = imageAsset.mediaType;
                        [weakSelf.selectAssetArr addObject:imageAsset];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [weakSelf.albumListView getAlbumListData];
                            [weakSelf.albumListView valueReloadByBoolReloadTitle:NO];
                        });
                    }
                }
            }];
        }
    }];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - setting
#pragma mark - 设置专辑数据
- (void)setAlbumModel:(YXChooseImgAlbumModel *)albumModel {
    
    _albumModel = albumModel;
    
    [self.titleBtn setTitle:_albumModel.albumName forState:UIControlStateNormal];
    [self refreshAssetData];
}
- (void)setMediaModel:(YXChooseMediaModel *)mediaModel {
    
    _mediaModel = mediaModel;
}

#pragma mark - 初始化视图
- (void)initView {
    
    //资产列表数据
    _assetModelArr = [NSMutableArray array];
    _selectAssetModelArr = [NSMutableArray array];
    _selectAssetArr = [NSMutableArray array];
    
    _selectMediaType = PHAssetMediaTypeUnknown;
    
    self.navigationView.hidden = self.backBtn.hidden = self.titleBtn.hidden = self.unfoldImageView.hidden = NO;
    self.albumModel = self.albumListView.selectAlbumModel;
    self.choosedListView.hidden = NO;
}

#pragma mark - 懒加载
- (UIView *)navigationView {
    
    if (!_navigationView) {
        CGFloat height = self.yc_naHeight + 20;
        _navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, height)];
        _navigationView.backgroundColor = [UIColor colorWithHexString:@"#000000"];
        [self.view addSubview:_navigationView];
        
        [_navigationView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.and.top.and.right.equalTo(self.view);
            make.height.mas_equalTo(height);
        }];
    }
    return _navigationView;
}
- (UIButton *)backBtn {
    
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UIImage imageNamed:@"YXImageChooseBackImg"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(progressBackBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationView addSubview:_backBtn];
        
        [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.and.bottom.equalTo(self.navigationView);
            make.width.and.height.mas_equalTo(64);
        }];
    }
    return _backBtn;
}
- (UIButton *)titleBtn {
    
    if (!_titleBtn) {
        _titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_titleBtn setTitle:@"最近项目 " forState:UIControlStateNormal];
        [_titleBtn setTitleColor:[UIColor colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
        _titleBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_titleBtn addTarget:self action:@selector(progressTitleBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationView addSubview:_titleBtn];
        
        [_titleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.bottom.equalTo(self.navigationView);
            make.height.mas_equalTo(64);
            make.centerX.equalTo(self.navigationView);
        }];
    }
    return _titleBtn;
}
- (UIImageView *)unfoldImageView {
    
    if (!_unfoldImageView) {
        _unfoldImageView = [[UIImageView alloc] init];
        [_unfoldImageView setImage:[UIImage imageNamed:@"YXImageChooseDownArrowImg"]];
        [self.navigationView addSubview:_unfoldImageView];
        
        [_unfoldImageView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.equalTo(self.titleBtn.mas_right);
            make.centerY.equalTo(self.titleBtn);
            make.width.mas_equalTo(11);
            make.height.mas_equalTo(6);
        }];
    }
    return _unfoldImageView;
}
- (UICollectionView *)collectionView {
    
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_collectionView];
        
        [_collectionView registerClass:[YXChooseImgCell class] forCellWithReuseIdentifier:NSStringFromClass([YXChooseImgCell class])];
        
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {

            make.left.and.right.equalTo(self.view);
            make.top.equalTo(self.navigationView.mas_bottom);
            make.bottom.equalTo(self.view).with.offset(-self.yc_tabBarHeight);
        }];
    }
    return _collectionView;
}
- (YXImageAlbumListView *)albumListView {
    
    if (!_albumListView) {
        _albumListView = [[YXImageAlbumListView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        
        __weak typeof(self) weakSelf = self;
        _albumListView.clickAlbumBlock = ^(YXChooseImgAlbumModel * _Nonnull albumModel, BOOL boolBlank, BOOL boolReloadTitle) {

            if (!boolBlank) {
                weakSelf.albumModel = albumModel;
            }
            if (boolReloadTitle) {
                [weakSelf progressTitleBtn:weakSelf.titleBtn];
            }
        };
    }
    return _albumListView;
}
- (UIImagePickerController *)imgPickerVC {
    
    if (!_imgPickerVC) {
        _imgPickerVC = [[UIImagePickerController alloc] init];
        _imgPickerVC.delegate = self;
        _imgPickerVC.modalPresentationStyle = UIModalPresentationFullScreen;
        _imgPickerVC.allowsEditing = YES;
        _imgPickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    return _imgPickerVC;
}
- (YXImageChoosedListView *)choosedListView {
    
    if (!_choosedListView) {
        _choosedListView = [[YXImageChoosedListView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 146 + self.yc_xBarHeight)];
        [self.view addSubview:_choosedListView];
        [self.view bringSubviewToFront:_choosedListView];
        
//        __weak typeof(self) weakSelf = self;
//        _choosedListView.yxImageChoosedListViewBlock = ^(YXChooseImgPhotoAssetModel * _Nullable assetModel, BOOL boolMove) {
//
//            if (boolMove) { //移动位置
//                [weakSelf.collectionView reloadData];
//            }
//            else { //移除勾选
//                [weakSelf chooseMethodByAssetModel:assetModel];
//            }
//        };
//        _choosedListView.yxImageChoosedListViewNextStepBlock = ^(NSMutableArray * _Nonnull selectedAssetModelArr) {
//
//            [weakSelf progressNextStepBySelectedAssetModelArr:selectedAssetModelArr];
//        };
    }
    return _choosedListView;
}
- (HXPhotoManager *)manager {
    if (!_manager) {
        _manager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypeVideo];
        _manager.configuration.lookLivePhoto = YES;
        _manager.configuration.photoMaxNum = 1;
        _manager.configuration.videoMaxNum = 1;
        _manager.configuration.maxNum = 1;
        _manager.configuration.saveSystemAblum = NO;
        //视频能选择的最大秒数  -  默认 3分钟/180秒
        if (_isMemmber == YES) {
            _manager.configuration.videoMaximumSelectDuration = 60*3;
            _manager.configuration.maxVideoClippingTime = 60*3;
        }else {
            _manager.configuration.videoMaximumSelectDuration = 30;
            _manager.configuration.maxVideoClippingTime = 30;
        }
        _manager.configuration.videoMinimumSelectDuration = 0;//最小时间
        // 相机视频录制最大秒数  -  默认60s
        //        _manager.configuration.videoMaximumDuration = 15.f;
        _manager.configuration.creationDateSort = NO;
        _manager.configuration.saveSystemAblum = YES;
        _manager.configuration.showOriginalBytes = YES;
        // 图片和视频是否能够同时选择 默认 NO
        _manager.configuration.selectTogether = NO;
        _manager.configuration.selectVideoBeyondTheLimitTimeAutoEdit = YES;
        _manager.configuration.requestImageAfterFinishingSelection = YES;
        _manager.configuration.specialModeNeedHideVideoSelectBtn = YES;
        _manager.videoSelectedType = HXPhotoManagerVideoSelectedTypeSingle;
        
    }
    return _manager;
}

@end
