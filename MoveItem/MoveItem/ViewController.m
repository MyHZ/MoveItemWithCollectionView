//
//  ViewController.m
//  MoveItem
//
//  Created by 黄震 on 2020/3/17.
//  Copyright © 2020 黄震. All rights reserved.
//

#import "ViewController.h"
#import "HZChannelCollectionViewCell.h"

//菜单列数
static NSInteger ColumnNumber = 4;
//横向和纵向的间距
static CGFloat CellMarginX = 15.0f;
static CGFloat CellMarginY = 10.0f;

@interface ViewController ()
<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) HZChannelCollectionViewCell *dragingItem;

@property (nonatomic, strong) NSIndexPath *dragingIndexPath;

@property (nonatomic, strong) NSIndexPath *targetIndexPath;

@property (nonatomic, strong) NSMutableArray *enabledTitles;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    NSArray *arr1 = @[@"要闻",@"河北",@"财经",@"娱乐",@"体育",@"社会",@"NBA",@"视频",@"汽车",@"图片",@"科技",@"军事",@"国际",@"数码",@"星座",@"电影",@"时尚",@"文化",@"游戏",@"教育",@"动漫",@"政务",@"纪录片",@"房产",@"佛学",@"股票",@"理财"];
    self.enabledTitles = [arr1 mutableCopy];
    
    [self buildUI];

}


-(void)buildUI{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat cellWidth = (self.view.bounds.size.width - (ColumnNumber + 1) * CellMarginX)/ColumnNumber;
    flowLayout.itemSize = CGSizeMake(cellWidth,cellWidth/2.0f);
    flowLayout.sectionInset = UIEdgeInsetsMake(CellMarginY, CellMarginX, CellMarginY, CellMarginX);
    flowLayout.minimumLineSpacing = CellMarginY;
    flowLayout.minimumInteritemSpacing = CellMarginX;
    flowLayout.headerReferenceSize = CGSizeMake(self.view.bounds.size.width, 40);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    self.collectionView.showsHorizontalScrollIndicator = false;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[HZChannelCollectionViewCell class] forCellWithReuseIdentifier:@"XLChannelItem"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressMethod:)];
    longPress.minimumPressDuration = 0.3f;
    [self.collectionView addGestureRecognizer:longPress];
    
    self.dragingItem = [[HZChannelCollectionViewCell alloc] initWithFrame:CGRectMake(0, 0, cellWidth, cellWidth/2.0f)];
    self.dragingItem.hidden = true;
    [self.collectionView addSubview:self.dragingItem];
}

#pragma mark -
#pragma mark LongPressMethod
-(void)longPressMethod:(UILongPressGestureRecognizer*)gesture{
    CGPoint point = [gesture locationInView:self.collectionView];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            [self dragBegin:point];
            break;
        case UIGestureRecognizerStateChanged:
            [self dragChanged:point];
            break;
        case UIGestureRecognizerStateEnded:
            [self dragEnd];
            break;
        default:
            break;
    }
}

//拖拽开始 找到被拖拽的item
-(void)dragBegin:(CGPoint)point{
    self.dragingIndexPath = [self getDragingIndexPathWithPoint:point];
    if (!self.dragingIndexPath) {return;}
    [self.collectionView bringSubviewToFront:self.dragingItem];
    HZChannelCollectionViewCell *item = (HZChannelCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:self.dragingIndexPath];
    item.isMoving = true;
    //更新被拖拽的item
    self.dragingItem.hidden = false;
    self.dragingItem.frame = item.frame;
    self.dragingItem.title = item.title;
    [self.dragingItem setTransform:CGAffineTransformMakeScale(1.1, 1.1)];
}

//正在被拖拽、、、
-(void)dragChanged:(CGPoint)point{
    if (!self.dragingIndexPath) {return;}
    self.dragingItem.center = point;
    self.targetIndexPath = [self getTargetIndexPathWithPoint:point];
    //交换位置 如果没有找到self.targetIndexPath则不交换位置
    if (self.dragingIndexPath && self.targetIndexPath) {
        //更新数据源
        [self rearrangeInUseTitles];
        //更新item位置
        [self.collectionView moveItemAtIndexPath:self.dragingIndexPath toIndexPath:self.targetIndexPath];
        self.dragingIndexPath = self.targetIndexPath;
    }
}

//拖拽结束
-(void)dragEnd{
    if (!self.dragingIndexPath) {return;}
    CGRect endFrame = [self.collectionView cellForItemAtIndexPath:self.dragingIndexPath].frame;
    [self.dragingItem setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
    [UIView animateWithDuration:0.3 animations:^{
        self.dragingItem.frame = endFrame;
    }completion:^(BOOL finished) {
        self.dragingItem.hidden = true;
        HZChannelCollectionViewCell *item = (HZChannelCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:self.dragingIndexPath];
        item.isMoving = false;
    }];
}

#pragma mark -
#pragma mark 辅助方法

//获取被拖动IndexPath的方法
-(NSIndexPath*)getDragingIndexPathWithPoint:(CGPoint)point{
    NSIndexPath* dragIndexPath = nil;
    //最后剩一个怎不可以排序
    if ([self.collectionView numberOfItemsInSection:0] == 1) {return dragIndexPath;}
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForVisibleItems) {
        //下半部分不需要排序
        if (indexPath.section > 0) {continue;}
        //在上半部分中找出相对应的Item
        if (CGRectContainsPoint([self.collectionView cellForItemAtIndexPath:indexPath].frame, point)) {
            if (indexPath.row != 0) {
                dragIndexPath = indexPath;
            }
            break;
        }
    }
    return dragIndexPath;
}

//获取目标IndexPath的方法
-(NSIndexPath*)getTargetIndexPathWithPoint:(CGPoint)point{
    NSIndexPath *targetIndexPath = nil;
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForVisibleItems) {
        //如果是自己不需要排序
        if ([indexPath isEqual:self.dragingIndexPath]) {continue;}
        //第二组不需要排序
        if (indexPath.section > 0) {continue;}
        //在第一组中找出将被替换位置的Item
        if (CGRectContainsPoint([self.collectionView cellForItemAtIndexPath:indexPath].frame, point)) {
            if (indexPath.row != 0) {
                targetIndexPath = indexPath;
            }
        }
    }
    return targetIndexPath;
}

#pragma mark -
#pragma mark CollectionViewDelegate&DataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.enabledTitles.count;
}



-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellId = @"XLChannelItem";
    HZChannelCollectionViewCell* item = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    item.title = self.enabledTitles[indexPath.row] ;
    item.isFixed = indexPath.section == 0 && indexPath.row == 0;
    return  item;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        //只剩一个的时候不可删除
        if ([self.collectionView numberOfItemsInSection:0] == 1) {return;}
        //第一个不可删除
        if (indexPath.row  == 0) {return;}
        id obj = [self.enabledTitles objectAtIndex:indexPath.row];
        
    }
}

#pragma mark -
#pragma mark 刷新方法
//拖拽排序后需要重新排序数据源
-(void)rearrangeInUseTitles
{
    id obj = [self.enabledTitles objectAtIndex:self.dragingIndexPath.row];
    [self.enabledTitles removeObject:obj];
    [self.enabledTitles insertObject:obj atIndex:self.targetIndexPath.row];
}

-(void)reloadData
{
    [self.collectionView reloadData];
}


@end
