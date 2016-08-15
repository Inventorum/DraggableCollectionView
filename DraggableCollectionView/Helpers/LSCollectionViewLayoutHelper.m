//
//  Copyright (c) 2013 Luke Scott
//  https://github.com/lukescott/DraggableCollectionView
//  Distributed under MIT license
//

#import "LSCollectionViewLayoutHelper.h"

@interface LSCollectionViewLayoutHelper ()

@end

@implementation LSCollectionViewLayoutHelper

- (id)initWithCollectionViewLayout:(UICollectionViewLayout<UICollectionViewLayout_Warpable>*)collectionViewLayout {
    self = [super init];
    if (self) {
        _collectionViewLayout = collectionViewLayout;
    }
    return self;
}

- (NSArray *)modifiedLayoutAttributesForElements:(NSArray *)elements {
    UICollectionView *collectionView = self.collectionViewLayout.collectionView;
    NSIndexPath *fromIndexPath = self.fromIndexPath;
    NSIndexPath *toIndexPath = self.toIndexPath;
    NSIndexPath *hideIndexPath = self.hideIndexPath;
    NSIndexPath *indexPathToRemove;
    
    if (toIndexPath == nil) {
        if (hideIndexPath == nil) {
            return elements;
        }
        for (UICollectionViewLayoutAttributes *layoutAttributes in elements) {
            if(layoutAttributes.representedElementCategory != UICollectionElementCategoryCell) {
                continue;
            }
            if ([layoutAttributes.indexPath isEqual:hideIndexPath]) {
                layoutAttributes.hidden = YES;
            }
        }
        return elements;
    }
    
    if (fromIndexPath.section != toIndexPath.section) {
        indexPathToRemove = [NSIndexPath indexPathForItem:[collectionView numberOfItemsInSection:fromIndexPath.section] - 1
                                                inSection:fromIndexPath.section];
    }
    
    for (UICollectionViewLayoutAttributes *layoutAttributes in elements) {
        if(layoutAttributes.representedElementCategory != UICollectionElementCategoryCell) {
            continue;
        }
        if([layoutAttributes.indexPath isEqual:indexPathToRemove]) {
            // Remove item in source section and insert item in target section
            layoutAttributes.indexPath = [NSIndexPath indexPathForItem:[collectionView numberOfItemsInSection:toIndexPath.section]
                                                             inSection:toIndexPath.section];
            if (layoutAttributes.indexPath.item != 0) {
                CGPoint previousCenter = [self.collectionViewLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:[collectionView numberOfItemsInSection:toIndexPath.section] - 2 inSection:toIndexPath.section]].center;
                CGPoint currentCenter = [self.collectionViewLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:[collectionView numberOfItemsInSection:toIndexPath.section] - 1 inSection:toIndexPath.section]].center;

                layoutAttributes.center = CGPointMake(currentCenter.x + currentCenter.x - previousCenter.x, currentCenter.y);

                // If its going outside collection view on left, then move it
                if (layoutAttributes.center.x < 0) {
                    // standart spacing:
                    CGPoint centerMinus3 = [self.collectionViewLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:[collectionView numberOfItemsInSection:toIndexPath.section] - 3 inSection:toIndexPath.section]].center;
                    CGPoint centerMinus2 = [self.collectionViewLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:[collectionView numberOfItemsInSection:toIndexPath.section] - 2 inSection:toIndexPath.section]].center;
                    
                    CGFloat widthMinus2 = [self.collectionViewLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:[collectionView numberOfItemsInSection:toIndexPath.section] - 2 inSection:toIndexPath.section]].size.width;
                    
                    CGFloat spacing = centerMinus2.x - centerMinus3.x - widthMinus2;
                    
                    layoutAttributes.center = CGPointMake(layoutAttributes.center.x + collectionView.frame.size.width + spacing, layoutAttributes.center.y);
                }
                    
            }
        }
        NSIndexPath *indexPath = layoutAttributes.indexPath;
        if ([indexPath isEqual:hideIndexPath]) {
            layoutAttributes.hidden = YES;
        }
        if([indexPath isEqual:toIndexPath]) {
            // Item's new location
            layoutAttributes.indexPath = fromIndexPath;
        }
        else if(fromIndexPath.section != toIndexPath.section) {
            if(indexPath.section == fromIndexPath.section && indexPath.item >= fromIndexPath.item) {
                // Change indexes in source section
                layoutAttributes.indexPath = [NSIndexPath indexPathForItem:indexPath.item + 1 inSection:indexPath.section];
            }
            else if(indexPath.section == toIndexPath.section && indexPath.item >= toIndexPath.item) {
                // Change indexes in destination section
                layoutAttributes.indexPath = [NSIndexPath indexPathForItem:indexPath.item - 1 inSection:indexPath.section];
            }
        }
        else if(indexPath.section == fromIndexPath.section) {
            if(indexPath.item <= fromIndexPath.item && indexPath.item > toIndexPath.item) {
                // Item moved back
                layoutAttributes.indexPath = [NSIndexPath indexPathForItem:indexPath.item - 1 inSection:indexPath.section];
            }
            else if(indexPath.item >= fromIndexPath.item && indexPath.item < toIndexPath.item) {
                // Item moved forward
                layoutAttributes.indexPath = [NSIndexPath indexPathForItem:indexPath.item + 1 inSection:indexPath.section];
            }
        }
    }
    
    return elements;
}

@end
