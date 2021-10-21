//
//  YXImageAmplificationVC.m
//  FateU
//
//  Created by Believer on 10/13/21.
//  Copyright © 2021 FateU_SYP. All rights reserved.
//

#import "YXImageAmplificationVC.h"
#import "YXImageAmplificationImgCell.h"
#import "YCMediaPhotoBrowserVideoCell.h"

@interface YXImageAmplificationVC () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIButton *backBtn; //返回按钮
@property (nonatomic, strong) UIButton *chooseBtn; //选择按钮
@property (nonatomic, strong) UICollectionView *collectionView; //图片列表

@end

@implementation YXImageAmplificationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    [self initView];
}

#pragma mark - 布局
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self scrollToCurrentIndex];
    [self scrollViewDidScroll:self.collectionView];
}

#pragma mark - 滚动到显示的位置
- (void)scrollToCurrentIndex {
    
    NSInteger index = ((self.collectionView.contentOffset.x / self.collectionView.width) + 0.5);
    if (index == self.currentIndex) {
        return;
    }
    
    if (self.currentIndex < self.assetModelArr.count) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    }
}

#pragma mark - progress
#pragma mark - 返回
- (void)progressBackBtn {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 选择按钮事件
- (void)progressChooseBtn:(UIButton *)sender {
    
    [self scrollViewDidScroll:self.collectionView];
    [self.navigationController popViewControllerAnimated:YES];
    
    if (self.clickSelectBlock) {
        self.clickSelectBlock(self.currentIndex);
    }
}

#pragma mark - 点击cell
- (void)clickCell {
    
    self.navigationView.hidden =! self.navigationView.hidden;
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.assetModelArr.count - 1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    __weak typeof(self) weakSelf = self;
    YXChooseImgPhotoAssetModel *assetModel = self.assetModelArr[indexPath.row];
    if (assetModel.asset.mediaType == PHAssetMediaTypeImage) {
        YXImageAmplificationImgCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([YXImageAmplificationImgCell class]) forIndexPath:indexPath];
        cell.browserVC = self;
        cell.indexPath = indexPath;
        cell.assetModel = assetModel;
        cell.clickCellBlock = ^{
            
            [weakSelf clickCell];
        };
        return cell;
    }
    else if (assetModel.asset.mediaType == PHAssetMediaTypeVideo) {
        YCMediaPhotoBrowserVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([YCMediaPhotoBrowserVideoCell class]) forIndexPath:indexPath];
        cell.browserVC = self;
        cell.indexPath = indexPath;
        cell.assetModel = assetModel;
        cell.clickCellBlock = ^{
            
            [weakSelf clickCell];
        };
        return cell;
    }
    return [[UICollectionViewCell alloc] init];
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.collectionView.size;
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

#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
        
    //显示的位置
    NSInteger index = ((self.collectionView.contentOffset.x / self.collectionView.width) + 0.5);
    if (index >= 0 && index < self.assetModelArr.count) {
        self.currentIndex = index;
    }
    
    //是否勾选
    YXChooseImgPhotoAssetModel *assetModel = self.assetModelArr[self.currentIndex];
    if (assetModel.isSelect) {
        [self.chooseBtn setTitle:[NSString stringWithFormat:@"%@", @(assetModel.selectCount)] forState:UIControlStateNormal];
        self.chooseBtn.backgroundColor = [UIColor colorWithHexString:@"#F9DD23"];
        self.chooseBtn.layer.borderWidth = 0;
    }
    else {
        [self.chooseBtn setTitle:@"" forState:UIControlStateNormal];
        self.chooseBtn.backgroundColor = [[UIColor colorWithHexString:@"#999999"] colorWithAlphaComponent:0.5];
        self.chooseBtn.layer.borderWidth = 1;
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    [self scrollViewDidEndDecelerating:scrollView];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kMediaPhotoBrowserDidScrollNotice" object:nil];
}

#pragma mark - 初始化视图
- (void)initView {
    
    self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.chooseBtn.hidden = NO;
}

#pragma mark - 懒加载
- (UIView *)navigationView {
    
    if (!_navigationView) {
        _navigationView = [[UIView alloc] init];
        _navigationView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_navigationView];
        
        [_navigationView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.and.top.and.right.equalTo(self.view);
            make.height.mas_equalTo(self.yc_naHeight);
        }];
    }
    return _navigationView;
}
- (UIButton *)backBtn {
    
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UIImage imageNamed:@"back_white"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(progressBackBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationView addSubview:_backBtn];
        
        [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.and.bottom.equalTo(self.navigationView);
            make.width.and.height.mas_equalTo(44);
        }];
    }
    return _backBtn;
}
- (UIButton *)chooseBtn {
    
    if (!_chooseBtn) {
        _chooseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _chooseBtn.layer.borderWidth = 1;
        _chooseBtn.layer.borderColor = [UIColor colorWithHexString:@"#FFFFFF"].CGColor;
        _chooseBtn.layer.cornerRadius = 10;
        _chooseBtn.layer.masksToBounds = YES;
        _chooseBtn.backgroundColor = [[UIColor colorWithHexString:@"#999999"] colorWithAlphaComponent:0.5];
        [_chooseBtn setTitleColor:[UIColor colorWithHexString:@"#000000"] forState:UIControlStateNormal];
        [_chooseBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [_chooseBtn addTarget:self action:@selector(progressChooseBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationView addSubview:_chooseBtn];
        
        [_chooseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.right.equalTo(self.navigationView).with.offset(-15);
            make.width.and.height.mas_equalTo(20);
            make.centerY.equalTo(self.backBtn);
        }];
    }
    return _chooseBtn;
}
- (UICollectionView *)collectionView {
    
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.pagingEnabled = YES;
        [self.view addSubview:_collectionView];
        
        [_collectionView registerClass:[YXImageAmplificationImgCell class] forCellWithReuseIdentifier:NSStringFromClass([YXImageAmplificationImgCell class])];
        [_collectionView registerNib:[UINib nibWithNibName: [YCMediaPhotoBrowserVideoCell.class description] bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([YCMediaPhotoBrowserVideoCell class])];
        
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {

            make.edges.equalTo(self.view);
        }];
        
        [_collectionView setNeedsLayout];
        [_collectionView layoutIfNeeded];
    }
    return _collectionView;
}

@end
