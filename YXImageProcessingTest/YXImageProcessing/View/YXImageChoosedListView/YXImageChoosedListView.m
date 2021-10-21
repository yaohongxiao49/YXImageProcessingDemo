//
//  YXImageChoosedListView.m
//  FateU
//
//  Created by Believer on 10/14/21.
//  Copyright © 2021 FateU_SYP. All rights reserved.
//

#import "YXImageChoosedListView.h"

@interface YXImageChoosedListView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UICollectionView *collectionView; //图片列表
@property (nonatomic, strong) UIView *stepBgV; //下一步背景视图
@property (nonatomic, strong) UILabel *titleLab; //标题
@property (nonatomic, strong) UIButton *stepBtn; //下一步

@end

@implementation YXImageChoosedListView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"#000000"];
        
        [self initView];
    }
    return self;
}

#pragma mark - 下一步
- (void)progressStepBtn {
    
    if (self.yxImageChoosedListViewNextStepBlock) {
        self.yxImageChoosedListViewNextStepBlock(self.selectedArr);
    }
}

#pragma mark - 移除
- (void)removeValueByDic:(HXPhotoModel *)model {
    
    if (self.yxImageChoosedListViewBlock) {
        self.yxImageChoosedListViewBlock(self.selectedArr, NO, model);
    }
}

#pragma mark - 切换
- (void)moveValueMethodByDic:(HXPhotoModel *)model {

    if (self.yxImageChoosedListViewBlock) {
        self.yxImageChoosedListViewBlock(self.selectedArr, YES, model);
    }
}
- (void)progressLongGesture:(UILongPressGestureRecognizer *)longPress {
    
    [self action:longPress];
}

- (void)action:(UILongPressGestureRecognizer *)longPress {
    
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan: { //手势开始
            //判断手势落点位置是否在row上
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[longPress locationInView:self.collectionView]];
            if (indexPath == nil) break;
            YXChoosedImgListCell *cell = (YXChoosedImgListCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            [self bringSubviewToFront:cell];
            [self.collectionView beginInteractiveMovementForItemAtIndexPath:indexPath];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            [self.collectionView updateInteractiveMovementTargetPosition:[longPress locationInView:self.collectionView]];
            break;
        }
        case UIGestureRecognizerStateEnded: { //手势结束
            [self.collectionView endInteractiveMovement];
            break;
        }
        default:
            [self.collectionView cancelInteractiveMovement];
            break;
    }
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _selectedArr.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    __weak typeof(self) weakSelf = self;
    YXChoosedImgListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([YXChoosedImgListCell class]) forIndexPath:indexPath];
    cell.selectAssetModel = _selectedArr[indexPath.row];
    cell.yxChoosedImgListCellCancelBlock = ^(HXPhotoModel * _Nonnull selectedModel) {
        
        [weakSelf removeValueByDic:selectedModel];
    };
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    HXPhotoModel *model = self.selectedArr[sourceIndexPath.row];

    //从数据源中移除该数据
    [self.selectedArr removeObject:model];
    //将数据插入到数据源中目标位置
    [self.selectedArr insertObject:model atIndex:destinationIndexPath.row];
    
    [self moveValueMethodByDic:model];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger w = 70;
    return CGSizeMake(w, w);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(20, 15, 20, 15);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 10;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    return 10;
}

#pragma mark - setting
- (void)setSelectedArr:(NSMutableArray *)selectedArr {
    
    _selectedArr = selectedArr;
 
    [self.stepBtn setTitle:[NSString stringWithFormat:@"  下一步（%@）", @(_selectedArr.count)] forState:UIControlStateNormal];
    [self.collectionView reloadData];
}

#pragma mark - 初始化视图
- (void)initView {
    
    self.bgView.hidden = self.titleLab.hidden = NO;
    [self.collectionView reloadData];
}

#pragma mark - 懒加载
- (UIView *)bgView {
    
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor colorWithHexString:@"#1C1D1E"];
        [self addSubview:_bgView];
        
        [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.edges.equalTo(self);
        }];
    }
    
    return _bgView;
}
- (UICollectionView *)collectionView {
    
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        [self.bgView addSubview:_collectionView];
        
        [_collectionView registerClass:[YXChoosedImgListCell class] forCellWithReuseIdentifier:NSStringFromClass([YXChoosedImgListCell class])];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(progressLongGesture:)];
        [_collectionView addGestureRecognizer:longPress];
        
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {

            make.left.and.right.and.top.equalTo(self.bgView);
            make.height.mas_equalTo(110);
        }];
    }
    return _collectionView;
}
- (UIView *)stepBgV {
    
    if (!_stepBgV) {
        _stepBgV = [[UIView alloc] init];
        _stepBgV.backgroundColor = [UIColor clearColor];
        [self.bgView addSubview:_stepBgV];
        
        [_stepBgV mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.top.equalTo(self.collectionView.mas_bottom);
            make.left.and.right.equalTo(self.collectionView);
            make.height.mas_equalTo(28);
        }];
    }
    return _stepBgV;
}
- (UILabel *)titleLab {
    
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textColor = [UIColor colorWithHexString:@"#999999"];
        _titleLab.textAlignment = NSTextAlignmentLeft;
        _titleLab.font = [UIFont systemFontOfSize:14];
        _titleLab.text = @"长按排列顺序";
        [self.stepBgV addSubview:_titleLab];
        
        [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.equalTo(self.stepBgV).with.offset(15);
            make.top.and.bottom.equalTo(self.stepBtn);
            make.right.lessThanOrEqualTo(self.stepBtn.mas_left).with.offset(-10);
        }];
    }
    return _titleLab;
}
- (UIButton *)stepBtn {
    
    if (!_stepBtn) {
        _stepBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _stepBtn.backgroundColor = [UIColor colorWithHexString:@"#F9DD23"];
        [_stepBtn setTitleColor:[UIColor colorWithHexString:@"#000000"] forState:UIControlStateNormal];
        _stepBtn.titleLabel.font = [UIFont systemFontOfSize:11];
        _stepBtn.layer.cornerRadius = 14;
        _stepBtn.layer.masksToBounds = YES;
        [_stepBtn addTarget:self action:@selector(progressStepBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.stepBgV addSubview:_stepBtn];
        
        [_stepBtn mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.right.equalTo(self.stepBgV).with.offset(-15);
            make.top.and.bottom.equalTo(self.stepBgV);
            make.width.mas_greaterThanOrEqualTo(68);
        }];
    }
    return _stepBtn;
}

@end
