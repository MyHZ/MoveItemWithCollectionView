//
//  ViewController.m
//  MoveItem2
//
//  Created by 黄震 on 2020/3/17.
//  Copyright © 2020 黄震. All rights reserved.
//

#import "ViewController.h"

static NSString * const cellIdentifier = @"cellIdentifier";
static NSString * const headerIdentifier = @"headerIdentifier";
static NSString * const footerIdentifier = @"footerIdentifier";

@interface UIColor (RandomColor)

+ (UIColor *)randomColor;

@end

@implementation UIColor (RandomColor)

+ (UIColor *)randomColor {
    CGFloat red = arc4random_uniform(255)/255.0;
    CGFloat green = arc4random_uniform(255)/255.0;
    CGFloat blue = arc4random_uniform(255)/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

@end

@interface CollectionReusableView : UICollectionReusableView

@property (strong, nonatomic) UILabel *label;


@end

@implementation CollectionReusableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 初始化label，设置文字颜色，最后添加label到重用视图。
        _label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.bounds.size.width-40, self.bounds.size.height)];
        _label.textColor = [UIColor blackColor];
        [self addSubview:_label];
    }
    return self;
}

@end

@interface CollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) UILabel *label;

@end


@implementation CollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 1.初始化imageView、label。
        CGFloat cellWidth = self.bounds.size.width;
        CGFloat cellHeight = self.bounds.size.height;
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, cellHeight * 4/5, cellWidth, cellHeight * 1/5)];
        _label.textAlignment = NSTextAlignmentCenter;
        
        // 2.添加imageView、label到cell。
        [self.contentView addSubview:_label];
        
        self.contentView.backgroundColor = [UIColor randomColor];
    }
    return self;
}

@end

@interface ViewController ()
<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) NSMutableArray *array;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 添加collection view。
    
    
    self.array = [@[@"1",@"2",@"3",@"4",@"3",@"4",@"3",@"4",@"3",@"4",@"3",@"4",@"3",@"4"] mutableCopy];
    
    // 注册cell、headerView。
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    [self.collectionView registerClass:[CollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerIdentifier];
    [self.collectionView registerClass:[CollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerIdentifier];
    [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];

    [self.view addSubview:self.collectionView];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(reorderCollectionView:)];
    [self.collectionView addGestureRecognizer:longPressGesture];
    
}

// 长按手势响应方法。
- (void)reorderCollectionView:(UILongPressGestureRecognizer *)longPressGesture {
    switch (longPressGesture.state) {
        case UIGestureRecognizerStateBegan:{
            // 手势开始。
            CGPoint touchPoint = [longPressGesture locationInView:self.collectionView];
            NSIndexPath *selectedIndexPath = [self.collectionView indexPathForItemAtPoint:touchPoint];
            if (selectedIndexPath) {
                [self.collectionView beginInteractiveMovementForItemAtIndexPath:selectedIndexPath];
            }
            break;
        }
            
        case UIGestureRecognizerStateChanged:{
            // 手势变化。
            CGPoint touchPoint = [longPressGesture locationInView:self.collectionView];
            [self.collectionView updateInteractiveMovementTargetPosition:touchPoint];
            break;
        }
            
        case UIGestureRecognizerStateEnded:{
            // 手势结束。
            [self.collectionView endInteractiveMovement];
            break;
        }
            
        default:{
            [self.collectionView cancelInteractiveMovement];
            break;
        }
    }
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        // 初始化UICollectionViewFlowLayout对象，设置集合视图滑动方向。
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        // 设置集合视图内容区域、layout、背景颜色。
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        
        // 设置代理。
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
    }
    return _collectionView;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.array.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
     CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.label.text = [self.array objectAtIndex:indexPath.item];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    CollectionReusableView *reusableView;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        // 设置header内容。
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerIdentifier forIndexPath:indexPath];
        reusableView.label.textAlignment = NSTextAlignmentCenter;
        reusableView.label.text = [NSString stringWithFormat:@"Section %li",indexPath.section];
    } else {
        // 设置footer内容。
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerIdentifier forIndexPath:indexPath];
        reusableView.label.textAlignment = NSTextAlignmentNatural;
        reusableView.label.text = [NSString stringWithFormat:@"Section %li have %li items",indexPath.section,[collectionView numberOfItemsInSection:indexPath.section]];
    }
    return reusableView;
}

// 设置item大小。
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(153, 128);
}
// 设置section header大小。
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return section == 0 ? CGSizeMake(40, 40) : CGSizeMake(45, 45);
}

// 设置section footer大小。
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(35, 35);
}
// 设置item间距。
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 20;
}
// 设置行间距。
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 20;
}
// 设置页边距。
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 20, 0, 20);
}

// 是否允许移动item。
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// 更新数据源。
- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSString *sourceObject = [self.array objectAtIndex:sourceIndexPath.item];
    [self.array removeObjectAtIndex:sourceIndexPath.item];
    [self.array insertObject:sourceObject atIndex:destinationIndexPath.item];
    // 重新加载当前显示的item。
    [collectionView reloadItemsAtIndexPaths:[collectionView indexPathsForVisibleItems]];
}

@end
