//
//  MMDragCollectionView.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/22.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMDragCollectionView;
@protocol MMDragCollectionViewDataSource<UICollectionViewDataSource>

@required
- (NSArray *)dataSourceWithDragCollectionView:(MMDragCollectionView *)collectionView;
@end


@protocol MMDragCollectionViewDelegate<UICollectionViewDelegate>

@required
- (void)dragCollectionView:(MMDragCollectionView *)collectionView newDataArrayAfterMove:(NSArray *)newDataArray;

@optional

- (BOOL)dragCollectionViewShouldBeginMove:(MMDragCollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

- (BOOL)dragCollectionViewShouldBegingExchange:(MMDragCollectionView *)collectionView fromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;

- (void)dragCollectionViewDidEndDrag:(MMDragCollectionView *)collectionView;

@end
@interface MMDragCollectionView : UICollectionView

@property (nonatomic, assign) NSTimeInterval miniPressDuration;
@property (nonatomic, assign, getter=isDragable) BOOL dragable;
@property (nonatomic, weak) id<MMDragCollectionViewDelegate> delegate;
@property (nonatomic, weak) id<MMDragCollectionViewDataSource> dataSource;
@end
