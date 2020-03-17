//
//  HZChannelCollectionViewCell.h
//  MoveItem
//
//  Created by 黄震 on 2020/3/17.
//  Copyright © 2020 黄震. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HZChannelCollectionViewCell : UICollectionViewCell

//标题
@property (nonatomic, copy) NSString *title;

//是否正在移动状态
@property (nonatomic, assign) BOOL isMoving;

//是否被固定
@property (nonatomic, assign) BOOL isFixed;


@end

NS_ASSUME_NONNULL_END
