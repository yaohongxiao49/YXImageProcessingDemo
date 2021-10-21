//
//  YXImageEditVC.m
//  FateU
//
//  Created by Believer on 10/16/21.
//  Copyright © 2021 FateU_SYP. All rights reserved.
//

#import "YXImageEditVC.h"
#import "YXImageEditBottomMenuView.h"

#import "LiveBgImgCell.h"

@interface YXImageEditVC ()<UICollectionViewDelegate,UICollectionViewDataSource,YXImageEditBottomMenuViewDelegate>
///
@property (nonatomic, strong) UIView *topView;
@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (strong, nonatomic) UICollectionView *collectionView;
///底部图片的菜单视图
@property (strong, nonatomic) YXImageEditBottomMenuView *bottomMenuView;

///当前展示的数据的下标
@property (assign, nonatomic) NSInteger currentModelIndex;

@end

@implementation YXImageEditVC

- (void)viewDidLoad {
    [super viewDidLoad];

}

#pragma mark ——— 底部菜单按钮的点击事件
- (void)clickImageEditBottomMenutBtnAction:(NSInteger)index {
    if (index == 100) {
        NSLog(@"点击滤镜");
    }
    else if (index == 101) {
        NSLog(@"点击文字");
    }
    else if (index == 102) {
        NSLog(@"点击贴纸");
    }
    else if (index == 103) {
        NSLog(@"点击标签");
    }
    else if (index == 104) {
        NSLog(@"点击裁剪");
    }
}

#pragma mark ——— 初始化UI
- (void)initializeUserInterface {
    self.view.backgroundColor = KMRC;
    
    self.topView = [self addTitleViewWithTitle:@"3/5"];
    self.titleLabel.textColor = White_Color;
    self.topView.backgroundColor = [UIColor blackColor];
    self.rightButton.hidden = NO;
    self.lineView.hidden = YES;
    [self.backButton setImage:[UIImage imageNamed:@"back_white"] forState:UIControlStateNormal];
    [self.backButton setTintColor:White_Color];
    [self.rightButton setTitle:@"下一步" forState:UIControlStateNormal];
    self.rightButton.backgroundColor = [UIColor colorWithHexString:@"#F9DD23"];
    self.rightButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12];
    [self.rightButton setTitleColor:[UIColor colorWithHexString:@"#111111"] forState:UIControlStateNormal];
    self.rightButton.layer.cornerRadius = 14;
    
    [self.rightButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.bottom.mas_equalTo (-8);
        make.height.mas_equalTo(28);
        make.width.mas_equalTo(52);
    }];
    
    [self.view addSubview:self.bottomMenuView];
    [self.view addSubview:self.collectionView];
    
    self.bottomMenuView.sd_layout
    .bottomSpaceToView(self.view, KSafeBottomHeight)
    .widthIs(Width_Screen)
    .centerXEqualToView(self.view)
    .heightIs(90);
    
    self.collectionView.sd_layout
    .topSpaceToView(self.topView, 0)
    .widthIs(Width_Screen)
    .bottomSpaceToView(self.bottomMenuView, 0);

}
#pragma mark ——— 点击下一步的按钮事件
- (void)rightButtonClick:(UIButton *)sender {
    NSLog(@"点击下一步");
}


#pragma mark - collectionView data source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 8;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LiveBgImgCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([LiveBgImgCell class]) forIndexPath:indexPath];
    cell.bgImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"voice-room-theme%ld",indexPath.row]];
    
    return cell;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetx = self.collectionView.contentOffset.x;
//    NSInteger currentIndex = offsetx / Width_Screen;
    NSInteger currentIndex = (offsetx + Width_Screen * 0.5) / Width_Screen;
    if (currentIndex > 7) {
        currentIndex = 7;
    }
    if (currentIndex < 0) {
        currentIndex = 0;
    }
    NSLog(@"当前的偏移量== %f 当前的页码== %ld", offsetx, currentIndex);
    self.titleLabel.text = [NSString stringWithFormat:@"%zd/8",currentIndex+1];
    
    //赋值
    self.currentModelIndex = currentIndex;
}
#pragma mark ——— 懒加载
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        //整页滑动
        _collectionView.pagingEnabled = YES;
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_collectionView registerNib:[UINib nibWithNibName:@"LiveBgImgCell" bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([LiveBgImgCell class])];
        
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        // 设置UICollectionView为横向滚动
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        // 每一行cell之间的间距
        _flowLayout.minimumLineSpacing = 0;
        // 每一列cell之间的间距
        _flowLayout.minimumInteritemSpacing = 0;
        // 设置第一个cell和最后一个cell,与父控件之间的间距
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        // 设置每个cell的大小
        _flowLayout.itemSize = CGSizeMake(Width_Screen, Height_Screen);
    }
    return _flowLayout;
}

- (YXImageEditBottomMenuView *)bottomMenuView {
    if (!_bottomMenuView) {
        _bottomMenuView = [YXImageEditBottomMenuView viewFromXIB];
        _bottomMenuView.delegate = self;
    }
    return _bottomMenuView;
}

@end
