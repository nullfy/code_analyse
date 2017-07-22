//
//  MMDragCollectionView.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/22.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "MMDragCollectionView.h"

typedef NS_ENUM(NSUInteger, MMDragCollectionViewScrollDirection) {
    MMDragCollectionViewScrollDirectionNone,
    MMDragCollectionViewScrollDirectionUp,
    MMDragCollectionViewScrollDirectionLeft,
    MMDragCollectionViewScrollDirectionDown,
    MMDragCollectionViewScrollDirectionRight,
};

@interface MMDragCollectionView ()

@property (strong, nonatomic) UIView *snapedView;
@property (strong, nonatomic) CADisplayLink *edgeTimer;
@property (strong, nonatomic) NSIndexPath *currentIndexPath;
@property (strong, nonatomic) NSIndexPath *oldIndexPath;
@property (assign, nonatomic) CGPoint lastPoint;
@property (assign, nonatomic) BOOL isEndDrag;

@property (strong, nonatomic) UILongPressGestureRecognizer *longPress;

@end


@implementation MMDragCollectionView

@dynamic delegate;
@dynamic dataSource;

#pragma mark   LifeCycle
- (void)awakeFromNib {
    [super awakeFromNib];
    [self initConfiguration];
}

- (instancetype)init {
    if (self = [super init]) [self initConfiguration];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) [self initConfiguration];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) [self initConfiguration];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self initConfiguration];
    }
    return self;
}



#pragma mark Setter&&Getter

- (void)setMiniPressDuration:(NSTimeInterval)miniPressDuration {
    _miniPressDuration = miniPressDuration;
    self.longPress.minimumPressDuration = miniPressDuration;
}

- (void)setDragable:(BOOL)dragable {
    _dragable = dragable;
    self.longPress.enabled = dragable;
}

- (UILongPressGestureRecognizer *)longPress {
    if (!_longPress) {
        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        _longPress.minimumPressDuration = _miniPressDuration;
    }
    return _longPress;
}

#pragma mark Private-Method

- (void)initConfiguration {
    _dragable = YES;
    if (!self.miniPressDuration) self.miniPressDuration = 0.5f;
    [self addGestureRecognizer:self.longPress];
}

- (UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [super dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if (self.isEndDrag) {
        cell.hidden = NO;
    } else {
        if (self.oldIndexPath && self.oldIndexPath.item == indexPath.item && self.oldIndexPath.section == indexPath.section) {
            cell.hidden = YES;
        } else {
            cell.hidden = NO;
        }
    }
    return cell;
}

- (NSIndexPath *)_firstNearlyIndexPath {
    __block CGFloat width = MAXFLOAT;
    __block NSIndexPath *index = nil;
    [[self visibleCells] enumerateObjectsUsingBlock:^(__kindof UICollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint p1 = self.snapedView.center;
        CGPoint p2 = obj.center;
        CGFloat distance = sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2));
        if (distance < width) {
            width = distance;
            index = [self indexPathForCell:obj];
        }
    }];
    if (index.item == self.oldIndexPath.item && (index.row == self.oldIndexPath.row)) return nil;
    return index;
}

- (MMDragCollectionViewScrollDirection)_setScrollDirection {
    CGFloat boundsHeight = self.bounds.size.height;
    CGFloat offsetY = self.contentOffset.y;
    CGFloat offsetX = self.contentOffset.x;
    CGFloat boundsWidth = self.bounds.size.width;
    CGFloat snapCenterX = _snapedView.center.x;
    CGFloat snapCenterY = _snapedView.center.y;
    CGFloat snapWidth = _snapedView.size.width;
    CGFloat snapHeight = _snapedView.size.height;
    CGFloat contentHeight = self.contentSize.height;
    CGFloat contentWidth = self.contentSize.width;
    
    if (boundsHeight + offsetY - snapCenterY < snapHeight / 2 && boundsWidth + offsetY < contentHeight) {
        return MMDragCollectionViewScrollDirectionDown;
    }
    
    if (snapCenterY - offsetY < snapHeight/2 && offsetY > 0) {
        return MMDragCollectionViewScrollDirectionUp;
    }
    
    if (boundsWidth + offsetX - snapCenterX < snapWidth/2 && boundsWidth + offsetX < contentWidth) {
        return MMDragCollectionViewScrollDirectionRight;
    }
    
    if (snapCenterX - offsetX < snapWidth/2 && offsetX > 0) {
        return MMDragCollectionViewScrollDirectionLeft;
    }
    
    return MMDragCollectionViewScrollDirectionNone;
}

- (void)_updateSourceData {
    NSMutableArray *array = [self.dataSource dataSourceWithDragCollectionView:self].mutableCopy;
    BOOL dataTypeCheck = self.numberOfSections != 1 || (self.numberOfSections == 1 && [array[0] isKindOfClass:[NSArray class]]);
    if (dataTypeCheck) {
        for (NSInteger i = 0; i < array.count; i++) {
            [array replaceObjectAtIndex:i withObject:[array[i] mutableCopy]];
        }
    }
    
    if (_currentIndexPath.section == _oldIndexPath.section) {
        NSMutableArray *orignalSection = dataTypeCheck ? [array[_oldIndexPath.section] mutableCopy] : array;
        if (_currentIndexPath.item > _oldIndexPath.item) {
            for (NSUInteger i = _oldIndexPath.item; i < _currentIndexPath.item; i++) {
                [orignalSection exchangeObjectAtIndex:i withObjectAtIndex:i + 1];
            }
        } else {
            for (NSUInteger i = _oldIndexPath.item; i > _currentIndexPath.item; i--) {
                [orignalSection exchangeObjectAtIndex:i withObjectAtIndex:i - 1];
            }
        }
    } else {
        NSMutableArray *orignalSection = [array[_oldIndexPath.section] mutableCopy];
        NSMutableArray *currentSection = [array[_currentIndexPath.section] mutableCopy];
        
        [currentSection insertObject:orignalSection[_oldIndexPath.item] atIndex:_currentIndexPath.item];
        [orignalSection removeObject:orignalSection[_oldIndexPath.item]];
    }
    [self.delegate dragCollectionView:self newDataArrayAfterMove:array];
}

- (void)_setEdgeTimer {
    if (!_edgeTimer) {
        _edgeTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(_edgeScroll)];
        [_edgeTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)_stopEdgeTimer {
    if (_edgeTimer) {
        [_edgeTimer invalidate];
        _edgeTimer = nil;
    }
}

- (void)_edgeScroll {
    CGFloat offsetX = self.contentOffset.x;
    CGFloat offsetY = self.contentOffset.y;
    CGFloat snapCenterX = _snapedView.center.x;
    CGFloat snapCenterY = _snapedView.center.y;
    
    MMDragCollectionViewScrollDirection scrollDirection = [self _setScrollDirection];
    switch (scrollDirection) {
        case MMDragCollectionViewScrollDirectionLeft: {
            [self setContentOffset:CGPointMake(offsetX - 4, offsetY) animated:NO];
            _snapedView.center = CGPointMake(snapCenterX - 4, snapCenterY);
            _lastPoint.x -= 4;
        } break;
        case MMDragCollectionViewScrollDirectionRight: {
            [self setContentOffset:CGPointMake(offsetX + 4, offsetY) animated:NO];
            _snapedView.center = CGPointMake(snapCenterX + 4, snapCenterY);
            _lastPoint.x += 4;
        } break;
        case MMDragCollectionViewScrollDirectionUp: {
            [self setContentOffset:CGPointMake(offsetX, offsetY - 4) animated:NO];
            _snapedView.center = CGPointMake(snapCenterX , snapCenterY - 4);
            _lastPoint.y -= 4;
        } break;
        case MMDragCollectionViewScrollDirectionDown: {
            [self setContentOffset:CGPointMake(offsetX, offsetY + 4) animated:NO];
            _snapedView.center = CGPointMake(snapCenterX, snapCenterY + 4);
            _lastPoint.y += 4;
        } break;
        default:
            break;
    }
    
    if (scrollDirection == MMDragCollectionViewScrollDirectionNone) {
        _lastPoint = [self.longPress locationInView:self];
        
        [UIView animateWithDuration:0.1 animations:^{
            _snapedView.center = _lastPoint;
        }];
        
        NSIndexPath *index = [self _firstNearlyIndexPath];
        if (!index) return;
        
        _currentIndexPath = [NSIndexPath indexPathForRow:index.row inSection:index.section];
        [self _updateSourceData];
        
        [self moveItemAtIndexPath:_oldIndexPath toIndexPath:_currentIndexPath];
        
        _oldIndexPath = _currentIndexPath;
        [self reloadItemsAtIndexPaths:@[_oldIndexPath]];
    }
}


#pragma mark    Event

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            _oldIndexPath = [self indexPathForItemAtPoint:[gesture locationInView:self]];
            if (_oldIndexPath == nil) break;
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(dragCollectionViewShouldBeginMove:indexPath:)]) {
                //如果正在执行move操作
                if (![self.delegate dragCollectionViewShouldBeginMove:self indexPath:_oldIndexPath]) {
                    _oldIndexPath = nil;
                    self.longPress.enabled = NO;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        if (self.isDragable) self.longPress.enabled = YES;
                    });
                    break;
                }
            }
            
            self.isEndDrag = NO;
            
            UICollectionViewCell *cell = [self cellForItemAtIndexPath:_oldIndexPath];
            
            _snapedView = [cell snapshotViewAfterScreenUpdates:NO];
            _snapedView.frame = cell.frame;
            [self addSubview:_snapedView];//生成拖动cell的snapView，同时添加到父视图上
            
            cell.hidden = YES;
            
            CGPoint currentPoint = [gesture locationInView:self];
            
            [UIView animateWithDuration:0.25 animations:^{
                _snapedView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
                _snapedView.center = CGPointMake(currentPoint.x, currentPoint.y);
            }];
            
            [self _setEdgeTimer];
        }  break;
            
        case UIGestureRecognizerStateChanged: {
            _lastPoint = [gesture locationInView:self];
            
            [UIView animateWithDuration:0.1 animations:^{
                _snapedView.center = _lastPoint;
            }];
            
            NSIndexPath *index = [self _firstNearlyIndexPath];
            
            if (!index) break;
            
            if ([self.delegate respondsToSelector:@selector(dragCollectionViewShouldBegingExchange:fromIndexPath:toIndexPath:)])  {
                if (![self.delegate dragCollectionViewShouldBegingExchange:self fromIndexPath:_oldIndexPath toIndexPath:index])  break;
            }
            
            _currentIndexPath = index;
            [self _updateSourceData];
            
            [self moveItemAtIndexPath:_oldIndexPath toIndexPath:_currentIndexPath];
            
            _oldIndexPath = _currentIndexPath;
        } break;
        default: {
            if (!self.oldIndexPath) break;
            
            UICollectionViewCell *cell = [self cellForItemAtIndexPath:_oldIndexPath];
            
            self.userInteractionEnabled = NO;
            
            __block BOOL isDragCell = NO;
            [[self indexPathsForVisibleItems] enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.item == self.oldIndexPath.item && obj.section == self.oldIndexPath.section) {
                    isDragCell = YES;
                }
            }];
            
            [UIView animateWithDuration:0.25 animations:^{
                if (isDragCell) {
                    _snapedView.center = cell.center;
                    _snapedView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                } else {
                    _snapedView.alpha = 0.f;
                }
            } completion:^(BOOL finished) {
                [_snapedView removeFromSuperview];
                cell.hidden = NO;
                self.userInteractionEnabled = YES;
                if ([self.delegate respondsToSelector:@selector(dragCollectionViewDidEndDrag:)]) {
                    [self.delegate dragCollectionViewDidEndDrag:self];
                }
            }];
            
            self.isEndDrag = YES;
            self.oldIndexPath = nil;
            [self _stopEdgeTimer];
        }
            break;
    }
}


@end
